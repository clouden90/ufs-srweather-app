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
if [ -d "$CTEST_DIR/test_srw" ]; then
   echo "clean test_srw folder!"
   rm -rf $CTEST_DIR/test_srw
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
export EXPTDIR="${CTEST_DIR}/test_srw"

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
