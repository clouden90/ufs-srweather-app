#!/bin/bash
# load user-defined configs
source default_vars.sh

#check input data
# data for regional test
if [ -d "./input-data/FV3_fix" ]; then
   echo "FV3_fix existed" 
else
   echo "no input-data/FV3_fix, create now"
   mkdir -p input-data/FV3_fix
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix input-data/FV3_fix --recursive
fi
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

#
rm rt.conf || true
cat << EOF > rt.conf
RUN     | regional_noquilt                                                                                                        |                                         | fv3 |
EOF

# arc org regional_noquilt
if [ -f "../../src/ufs-weather-model/tests/tests/regional_noquilt.arc" ]; then
   echo "regional_noquilt.arc existed!"
   cp ../../src/ufs-weather-model/tests/tests/regional_noquilt.arc ../../src/ufs-weather-model/tests/tests/regional_noquilt
else
   echo "no regional_noquilt.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/tests/regional_noquilt ../../src/ufs-weather-model/tests/tests/regional_noquilt.arc
fi

#
sed -i "19s/TASKS=60/TASKS=${CTEST_TASKS_NOQUILT}/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
sed -i "36s/INPES=10/INPES=${CTEST_LAYOUTX}/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
sed -i "37s/JNPES=6/JNPES=${CTEST_LAYOUTY}/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
#
OUT=$(tail -n 1 ../../src/ufs-weather-model/tests/tests/regional_noquilt)
if [[ $OUT != "export FHMAX=$(eval echo "${CTEST_FHMAX}")" ]]; then
  echo "reduce runtime to 1hr!"
  sed -i "$ a export FHMAX=$(eval echo "${CTEST_FHMAX}")" ../../src/ufs-weather-model/tests/tests/regional_noquilt
fi
#
bash rt.sh
