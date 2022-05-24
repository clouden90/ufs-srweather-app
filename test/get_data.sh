#!/bin/bash

#
source default_vars.sh

#get data for ccpp-scm
sh ../../src/ccpp-scm/contrib/get_all_static_data.sh

# data for regional test
if [ -d "./input-data/fv3_regional_control" ]; then
   echo "fv3_regional_control existed" 
else
   echo "no input-data/fv3_regional_control, create now"
   mkdir -p input-data/fv3_regional_control
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/fv3_regional_control input-data/fv3_regional_control --recursive
fi

if [ -d "./input-data/FV3_regional_input_data" ]; then
   echo "FV3_regional_input_data existed" 
else
   echo "no input-data/FV3_regional_input_data, create now"
   mkdir -p input-data/FV3_regional_input_data
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_regional_input_data input-data/FV3_regional_input_data --recursive
fi

if [ -d "./input-data/FV3_fix" ]; then
   echo "FV3_fix existed" 
else
   echo "no input-data/FV3_fix, create now"
   mkdir -p input-data/FV3_fix
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix input-data/FV3_fix --recursive
fi

echo $GET_STOCH_INPUT
if [ $GET_STOCH_INPUT == "ON" ]; then
   # additional data for regional_stoch
   if [ -d "./input-data/FV3_input_data_regional_stoch" ]; then
      echo "FV3_input_data_regional_stoch existed" 
   else
      echo "no input-data/FV3_input_data_regional_stoch, create now"
      mkdir -p input-data/FV3_input_data_regional_stoch
      aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_regional_stoch input-data/FV3_input_data_regional_stoch --recursive
   fi
else
   echo "We do not download stoch input data"
fi

#IC BC data for srw workflow (2019061500)
if [ -d "./input-data/model_data" ]; then
   echo "model_data existed!"
else
   cd ./input-data
   mkdir -p ./model_data/FV3GFS
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/input_model_data/FV3GFS/grib2/2019061500/gfs.t00z.pgrb2.0p25.f000 ./model_data/FV3GFS/gfs.t00z.pgrb2.0p25.f000
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/input_model_data/FV3GFS/grib2/2019061500/gfs.t00z.pgrb2.0p25.f003 ./model_data/FV3GFS/gfs.t00z.pgrb2.0p25.f003
   cd ../
fi

# fix data for srw workflow
if [ -d "./input-data/fix_am" ]; then
   echo "fix_am existed!"
else
   cd ./input-data
   wget https://ufs-data.s3.amazonaws.com/public_release/ufs-srweather-app-v1.0.0/fix/fix_files.tar.gz
   tar -zxvf fix_files.tar.gz
   rm -rf fix_files.tar.gz
   cd ../
fi

#
if [ -f "./input-data/fix_am/global_albedo4.1x1.grb" ]; then
   echo "input-data/fix_am/global_albedo4.1x1.grb  existed" 
else
   echo "no input-data/fix_am/global_albedo4.1x1.grb, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix/global_albedo4.1x1.grb input-data/fix_am/
fi

#
if [ -f "./input-data/fix_am/global_tg3clim.2.6x1.5.grb" ]; then
   echo "input-data/fix_am/global_tg3clim.2.6x1.5.grb  existed" 
else
   echo "no input-data/fix_am/global_tg3clim.2.6x1.5.grb, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix/global_tg3clim.2.6x1.5.grb input-data/fix_am/
fi

#
if [ -f "./input-data/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc" ]; then
   echo "input-data/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc  existed" 
else
   echo "no input-data/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/fix/fix_am/geo_em.d01.lat-lon.2.5m.HGT_M.nc input-data/fix_am/
fi

#
if [ -f "./input-data/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc" ]; then
   echo "input-data/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc  existed" 
else
   echo "no input-data/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc, download it now"
   aws s3 cp --no-sign-request s3://noaa-ufs-srw-pds/fix/fix_am/HGT.Beljaars_filtered.lat-lon.30s_res.nc input-data/fix_am/
fi
