#!/bin/bash

# load user-defined configs
source atparse.bash
source default_vars.sh

#
echo "top src folder is located at: $1"
export WORK_DIR=$1/regional_workflow/ush

#
echo "ctest folder is located at: $2"
export CTEST_DIR=$2

# clean old runs
if [ -d "$CTEST_DIR/${USER}" ]; then
   echo "clean RT case folder!"
   rm -rf $CTEST_DIR/${USER}
fi
if [ -d "$CTEST_DIR/$EXP_NAME" ]; then
   echo "clean $EXP_NAME  folder!"
   rm -rf $CTEST_DIR/$EXP_NAME
fi

# check if fix data exist
if [ -d "$DATA_DIR/fix_am" ]; then
   echo "$DATA_DIR/fix_am existed!"
else
   mkdir -p $DATA_DIR
   cd $DATA_DIR 
   wget https://ufs-data.s3.amazonaws.com/public_release/ufs-srweather-app-v1.0.0/fix/fix_files.tar.gz
   tar -zxvf fix_files.tar.gz
   rm -rf fix_files.tar.gz
   cd $CTEST_DIR
fi
#
if [ -f "$DATA_DIR/fix_am/global_albedo4.1x1.grb" ]; then
   echo "$DATA_DIR/fix_am/global_albedo4.1x1.grb  existed" 
else
   echo "no $DATA_DIR/fix_am/global_albedo4.1x1.grb, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix/global_albedo4.1x1.grb $DATA_DIR/fix_am/
fi
#
if [ -f "$DATA_DIR/fix_am/global_tg3clim.2.6x1.5.grb" ]; then
   echo "$DATA_DIR/fix_am/global_tg3clim.2.6x1.5.grb  existed" 
else
   echo "no $DATA_DIR/fix_am/global_tg3clim.2.6x1.5.grb, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix/global_tg3clim.2.6x1.5.grb $DATA_DIR/fix_am/
fi
#
if [ -f "$DATA_DIR/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc" ]; then
   echo "$DATA_DIR/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc  existed" 
else
   echo "no $DATA_DIR/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/fix/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc $DATA_DIR/fix_am/
fi
#
if [ -f "$DATA_DIR/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc" ]; then
   echo "$DATA_DIR/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc  existed" 
else
   echo "no $DATA_DIR/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/fix/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc $DATA_DIR/fix_am/
fi

#IC BC data for srw workflow (2019061500)
if [ -d "$MDL_BASEDIR" ]; then
   echo "$MDL_BASEDIR existed!"
else
   mkdir -p $MDL_BASEDIR
   START=0
   END=$((FCST_HRS))
   INTVL=$((LBC_INTVL_HR))
   for i in $(eval echo "{$START..$INTVL..$END}")
   do
     it=$(printf "%03d" $i)
     echo $it
     aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/input_model_data/FV3GFS/grib2/${FIRST_CYCLE}${CYCLE_HR}/gfs.t${CYCLE_HR}z.pgrb2.0p25.f${it} $MDL_BASEDIR/gfs.t${CYCLE_HR}z.pgrb2.0p25.f${it}
   done  
fi

#
atparse < config.sh.tmp > config.sh
atparse < linux.sh.tmp > linux.sh
mv config.sh $WORK_DIR
mv linux.sh $WORK_DIR/machine/

#
if [ -f "/contrib/GST/miniconda3/modulefiles/miniconda3/4.10.3" ]; then
   echo "on AWS cloud! load miniconda3!"
   export PATH=/contrib/GST/miniconda/envs/regional_workflow/bin:$PATH
fi

#
cd $WORK_DIR
echo $PWD
bash generate_FV3LAM_wflow.sh
export EXPTDIR="${CTEST_DIR}/${EXP_NAME}"

#
cd $WORK_DIR/wrappers
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_get_ics.sh
bash run_get_ics.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_get_lbcs.sh
bash run_get_lbcs.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_make_grid.sh
bash run_make_grid.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_make_orog.sh
bash run_make_orog.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_make_sfc_climo.sh
bash run_make_sfc_climo.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_make_ics.sh
bash run_make_ics.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_make_lbcs.sh
bash run_make_lbcs.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_fcst.sh
bash run_fcst.sh
#
sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/bash/g' run_post.sh
bash run_post.sh
