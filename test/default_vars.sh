#parameters for RT-related ctests
export CTEST_WRITE_TASKS=2
export CTEST_LAYOUTX=5
export CTEST_LAYOUTY=2
export CTEST_TASKS_NOQUILT=$(($CTEST_LAYOUTX*$CTEST_LAYOUTY))
export CTEST_TASKS=$(($CTEST_LAYOUTX*$CTEST_LAYOUTY+$CTEST_WRITE_TASKS))
export CTEST_FHMAX=1

# parameters for SRW apps
#
export EXP_NAME=test_srw

# grid name: RRFS_CONUS_25km, RRFS_CONUS_13km, RRFS_CONUS_3km
export GRID_NAME=RRFS_CONUS_25km

# QUILTING_OPTION: TRUE/FALSE
export QUILTING_OPTION=TRUE

# CCPP_SUITE options: FV3_GFS_v15p2, FV3_GFS_v16
export CCPP_SUITE=FV3_GFS_v16

export FCST_HRS=3
export LBC_INTVL_HR=3

export FIRST_CYCLE=20190615
export LAST_CYCLE=20190615
export CYCLE_HR=00

export MODEL_NAME=FV3_GFS_v16_CONUS_25km

export LAYOUTX=5
export LAYOUTY=2

# ICS FORMAT: grib2, nemsio, netcdf
export ICS_FMT=grib2
export LBCS_FMT=grib2
export DATA_DIR=${PWD}/input-data
export MDL_BASEDIR=${DATA_DIR}/model_data/FV3GFS

# number of cores used by UTILS
export UTILS_TASKS=8

# number of cores used by post process
export POST_TASKS=8 
