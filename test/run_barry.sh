#!/bin/bash

# load user-defined configs
source atparse.bash
source barry_vars.sh 

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
   echo "clean $EXP_NAME folder!"
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


# check if ICs & LBCS exist
if [ -f "$MDL_BASEDIR/gfs.t${CYCLE_HR}z.atmanl.nemsio" ]; then
   echo "Barry IC data existed" 
else
   echo "get IC data for Barry case!"
   mkdir -p $MDL_BASEDIR
   cd $MDL_BASEDIR
   wget -c https://ufs-case-studies.s3.amazonaws.com/${FIRST_CYCLE}${CYCLE_HR}.gfs.nemsio.tar.gz
   tar -zxvf ${FIRST_CYCLE}${CYCLE_HR}.gfs.nemsio.tar.gz
   mv gfs.atmanl.nemsio gfs.t${CYCLE_HR}z.atmanl.nemsio
   mv gfs.sfcanl.nemsio gfs.t${CYCLE_HR}z.sfcanl.nemsio
   rm ${FIRST_CYCLE}${CYCLE_HR}.gfs.nemsio.tar.gz
   cd $CTEST_DIR 
fi
#
it=$(printf "%03d" $LBC_INTVL_HR)
if [ -f "$MDL_BASEDIR/gfs.t${CYCLE_HR}z.atmf${it}.nemsio" ]; then
   echo "Barry LBCs data existed"
else
   echo "get LBCS data for Barry case"
   mkdir -p $MDL_BASEDIR
   cd $MDL_BASEDIR
   START=$((LBC_INTVL_HR))
   END=$((FCST_HRS))
   INTVL=$((LBC_INTVL_HR))
   for i in $(eval echo "{$START..$END..$INTVL}")
   do
     it=$(printf "%03d" $i)
     echo $it
     wget -c https://ufs-case-studies.s3.amazonaws.com/2019071200_bc.atmf$it.nemsio.tar.gz
     tar -zxvf 2019071200_bc.atmf$it.nemsio.tar.gz
     mv gfs.atmf${it}.nemsio gfs.t${CYCLE_HR}z.atmf${it}.nemsio
     rm 2019071200_bc.atmf$it.nemsio.tar.gz
   done
   cd $CTEST_DIR
fi

#
atparse < config.sh.tmp > config.sh
atparse < linux.sh.tmp > linux.sh
mv config.sh $WORK_DIR
mv linux.sh $WORK_DIR/machine/

#
cd $WORK_DIR
echo $PWD
bash generate_FV3LAM_wflow.sh
export EXPTDIR="${CTEST_DIR}/$EXP_NAME"

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

# covert grib output to regular grid
#wgrib2 rrfs.t00z.prslev.f000.rrfs_conus_25km.grib2 -set_grib_type same -new_grid_winds earth -new_grid_interpolation bilinear -if ':(CSNOW|CRAIN|CFRZR|CICEP|ICSEV):' -new_grid_interpolation neighbor -fi -set_bitmap 1 -set_grib_max_bits 16 -if ':(APCP|ACPCP|PRATE|CPRAT):' -set_grib_max_bits 25 -fi -if ':(APCP|ACPCP|PRATE|CPRAT|DZDT):' -new_grid_interpolation budget -fi -new_grid latlon 0:1440:0.25 90:721:-0.25 pgb2file_000_0p25
