#!/usr/bin/env bash
#
set -e -u #-x

error() {
  echo
  echo "$@" 1>&2
  exit 1
}

usage() {
  #set +x
  echo
  echo "Usage: $program -p <SOURCE_TEST_DIR>"
  #set -x
}

usage_and_exit() {
  usage
  exit $1
}

########################################################################
####                       PROGRAM STARTS                           ####
########################################################################
#
readonly program=$(basename $0)
[[ $# -eq 0 ]] && usage_and_exit 1

#
readonly RUN_TEST_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)

# parse command line arguments to fill-in/modify the above default variables
while getopts ":p:h" opt; do
  case $opt in
    p)
     readonly SOURCE_TEST_DIR=$OPTARG
     echo "source test dir: ${SOURCE_TEST_DIR}"
     ;;
    '?')
      error "$program: invalid option -$OPTARG"
      ;;
  esac
done

#
readonly SOURCE_USH_DIR=${SOURCE_TEST_DIR}/../ush
[[ -f ${SOURCE_USH_DIR}/config.yaml ]] && rm -rf ${SOURCE_USH_DIR}/config.yaml && cp config.yaml.template ${SOURCE_USH_DIR}/config.yaml
sed -i 's@SET_MY_PATH@'"${RUN_TEST_DIR}"'@g' ${SOURCE_USH_DIR}/config.yaml

#TODO better way to handle machine name and account
# Now user have to set env vars before run ctest
sed -i 's/SET_MY_MACHINE/'"${HTF_MACHINE}"'/g' ${SOURCE_USH_DIR}/config.yaml
sed -i 's/SET_MY_ACCOUNT/'"${HTF_ACCOUNT}"'/g' ${SOURCE_USH_DIR}/config.yaml
sed -i 's/SET_MY_CCPP/'"${HTF_CCPP}"'/g' ${SOURCE_USH_DIR}/config.yaml

#
[[ -d ${RUN_TEST_DIR}/expt_dirs ]] && rm -rf ${RUN_TEST_DIR}/expt_dirs
cd ${SOURCE_USH_DIR} && ./generate_FV3LAM_wflow.py && cd ${RUN_TEST_DIR} 


# Wait for test to complete.
while true; do

    # Check status of experiment
    ./expt_dirs/test_community/launch_FV3LAM_wflow.sh

    # Exit loop only if there are not tests in progress
    set +e
    grep -q "Workflow status:  IN PROGRESS" ./expt_dirs/test_community/log.launch_FV3LAM_wflow 
    exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
       break
    fi

    # TODO: Create a paremeter that sets the poll frequency.
    sleep 60
    [[ -f expt_dirs/test_community/log.launch_FV3LAM_wflow ]] && rm -rf ./expt_dirs/test_community/log.launch_FV3LAM_wflow
done


grep -q 'Workflow status:  SUCCESS' ./expt_dirs/test_community/log.launch_FV3LAM_wflow
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
   echo "run success! Now check if new innovation improves prediction!"
   ./check.py
fi

