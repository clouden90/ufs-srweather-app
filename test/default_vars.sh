# data download option
export GET_STOCH_INPUT=OFF

# parameters for SRW apps
# grid name: RRFS_CONUS_25km, RRFS_CONUS_13km, RRFS_CONUS_3km
export GRID_NAME=RRFS_CONUS_25km

# QUILTING_OPTION: TRUE/FALSE
export QUILTING_OPTION=TRUE

# CCPP_SUITE options: FV3_GFS_v15p2, FV3_GFS_v16
export CCPP_SUITE=FV3_GFS_v16

export FCST_HRS=3

export FIRST_CYCLE=20190615
export LAST_CYCLE=20190615
export CYCLE_HR=00

export MODEL_NAME=FV3_GFS_v16_CONUS_25km

export LAYOUTX=12
export LAYOUTY=6

# ICS FORMAT: grib2, nemsio, netcdf
export ICS_FMT=grib2
export LBCS_FMT=grib2

# number of cores used by UTILS
export UTILS_TASKS=8

# number of cores used by post process
export POST_TASKS=8 
