# Build test for the UFS Short-Range Weather App

## Description

This script builds the executables for the UFS Short-Range Weather Application (SRW App)
for the current code in the users ufs-srweather-app directory.  It consists of the following steps:

* Build all of the executables for the supported compilers on the given machine

* Check for the existence of all executables

* Print out a PASS/FAIL message

Currently, the following configurations are supported:

Machine     | Cheyenne    | Hera   | Jet    | Orion  | wcoss_cray  | wcoss_dell_p3  |
------------| ------------|--------|--------|--------|-------------|----------------|
Compiler(s) | Intel, GNU  | Intel  | Intel  | Intel  | Intel       | Intel          |

The CMake build is done in the ``build_${compiler}`` directory.
The executables for each build are installed under the ``bin_${compiler}`` directory.

NOTE:  To run the regional workflow using these executables, the ``EXECDIR`` variable in the
``${SR_WX_APP_TOP_DIR}/regional_workflow/ush/setup.sh`` file must be set to the
appropiate directory, for example:  ``EXECDIR="${SR_WX_APP_TOP_DIR}/bin_intel/bin"``,
where ``${SR_WX_APP_TOP_DIR}`` is the top-level directory of the cloned ufs-srweather-app repository.

## Usage

To run the tests, specify the machine name on the command line, for example:

On cheyenne:

```
cd test
./build.sh cheyenne >& build.out &
```

Check the ``${SR_WX_APP_TOP_DIR}/test/build_test$PID.out`` file for PASS/FAIL.

## ctest (for Hierarchical Testing Framework, HTF)

Currently, the following configurations are supported/tested:

Machine     | Orion       | NOAA Cloud (GCPv2)   |
------------| ------------|--------|
Compiler(s) | Intel, GNU  | Intel  |

## How to use

Currently there are totally 12 tests (after build step, you can type ``ctest -N`` to see the list) existed.
System requirements: at least 12-core cpus, 16gb memory, and 60gb disk space

```
[Yi-cheng.Teng@aznoaa-6 test]$ ctest -N
Test project /home/Yi-cheng.Teng/ufs-srweather-app/build/test
  Test  #1: test_ccpp
  Test  #2: test_fv3_regional_noquilt
  Test  #3: test_fv3_regional_control
  Test  #4: test_fv3_regional_stoch
  Test  #5: test_fv3_global_control
  Test  #6: test_regional_workflow_initial
  Test  #7: test_regional_grid
  Test  #8: test_regional_orog
  Test  #9: test_regional_sfc_climo
  Test #10: test_regional_ic_bc
  Test #11: test_regional_fcst
  Test #12: test_regional_post

Total Tests: 12
```

On NOAA Cloud (gcp for example):


```
git clone -b ctest https://github.com/clouden90/ufs-srweather-app.git
cd ufs-srweather-app
./manage_externals/checkout_externals -o
source test/machines/noaacloud_intel.env
mkdir build
cd build
cmake -DBUILD_CCPP-SCM=ON .. -DCMAKE_INSTALL_PREFIX=..
make -j4
cd test
sh get_data.sh
sbatch job_card
```
And You can check your slurm output. It should contain something like:

```
Test project /home/Yi-cheng.Teng/ufs-srweather-app/build/test
      Start  1: test_ccpp
 1/12 Test  #1: test_ccpp ........................   Passed   29.57 sec
      Start  2: test_fv3_regional_noquilt
 2/12 Test  #2: test_fv3_regional_noquilt ........   Passed  156.11 sec
      Start  3: test_fv3_regional_control
 3/12 Test  #3: test_fv3_regional_control ........   Passed  130.41 sec
      Start  4: test_fv3_regional_stoch
 4/12 Test  #4: test_fv3_regional_stoch ..........   Passed  1099.44 sec
      Start  5: test_fv3_global_control
 5/12 Test  #5: test_fv3_global_control ..........   Passed  137.23 sec
      Start  6: test_regional_workflow_initial
 6/12 Test  #6: test_regional_workflow_initial ...   Passed  522.56 sec
      Start  7: test_regional_grid
 7/12 Test  #7: test_regional_grid ...............   Passed    4.95 sec
      Start  8: test_regional_orog
 8/12 Test  #8: test_regional_orog ...............   Passed  160.57 sec
      Start  9: test_regional_sfc_climo
 9/12 Test  #9: test_regional_sfc_climo ..........   Passed  131.49 sec
      Start 10: test_regional_ic_bc
10/12 Test #10: test_regional_ic_bc ..............   Passed   50.98 sec
      Start 11: test_regional_fcst
11/12 Test #11: test_regional_fcst ...............   Passed   86.89 sec
      Start 12: test_regional_post
12/12 Test #12: test_regional_post ...............   Passed   17.90 sec

100% tests passed, 0 tests failed out of 12

Total Test time (real) = 2528.61 sec
```

Or on Orion:

```
Test project /work/noaa/epic-ps/ycteng/ufs/20220519/ufs-srweather-app/build/test
      Start  1: test_ccpp
 1/12 Test  #1: test_ccpp ........................   Passed   16.32 sec
      Start  2: test_fv3_regional_noquilt
 2/12 Test  #2: test_fv3_regional_noquilt ........   Passed   50.10 sec
      Start  3: test_fv3_regional_control
 3/12 Test  #3: test_fv3_regional_control ........   Passed   47.01 sec
      Start  4: test_fv3_regional_stoch
 4/12 Test  #4: test_fv3_regional_stoch ..........   Passed  1490.87 sec
      Start  5: test_fv3_global_control
 5/12 Test  #5: test_fv3_global_control ..........   Passed   58.04 sec
      Start  6: test_regional_workflow_initial
 6/12 Test  #6: test_regional_workflow_initial ...   Passed   37.96 sec
      Start  7: test_regional_grid
 7/12 Test  #7: test_regional_grid ...............   Passed    5.55 sec
      Start  8: test_regional_orog
 8/12 Test  #8: test_regional_orog ...............   Passed  101.49 sec
      Start  9: test_regional_sfc_climo
 9/12 Test  #9: test_regional_sfc_climo ..........   Passed  126.02 sec
      Start 10: test_regional_ic_bc
10/12 Test #10: test_regional_ic_bc ..............   Passed  136.53 sec
      Start 11: test_regional_fcst
11/12 Test #11: test_regional_fcst ...............   Passed  198.87 sec
      Start 12: test_regional_post
12/12 Test #12: test_regional_post ...............   Passed   18.96 sec

100% tests passed, 0 tests failed out of 12

Total Test time (real) = 2287.75 sec

```
