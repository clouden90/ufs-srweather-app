# parameters for SRW apps
#
export EXP_NAME=test_barry

# grid name: RRFS_CONUS_25km, RRFS_CONUS_13km, RRFS_CONUS_3km
export GRID_NAME=RRFS_CONUS_25km

# QUILTING_OPTION: TRUE/FALSE
export QUILTING_OPTION=TRUE

# CCPP_SUITE options: FV3_GFS_v15p2, FV3_GFS_v16
export CCPP_SUITE=FV3_GFS_v16

export FCST_HRS=6
export LBC_INTVL_HR=6

export FIRST_CYCLE=20190712
export LAST_CYCLE=20190712
export CYCLE_HR=00

export MODEL_NAME=FV3_GFS_v16_CONUS_25km

export LAYOUTX=12
export LAYOUTY=6

# ICS FORMAT: grib2, nemsio, netcdf
export ICS_FMT=nemsio
export LBCS_FMT=nemsio
export DATA_DIR=/contrib/Yi-cheng.Teng/input-data
export MDL_BASEDIR=${DATA_DIR}/model_data/BARRY

# number of cores used by UTILS
export UTILS_TASKS=8

# number of cores used by post process
export POST_TASKS=8 
