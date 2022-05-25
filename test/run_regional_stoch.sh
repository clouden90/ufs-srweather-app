#!/bin/bash
# load user-defined configs
source default_vars.sh

#
echo "regional control with stoch!"

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
RUN     | regional_control                                                                                                        |                                         | fv3 |
EOF

# arc org regional_control
if [ -f "../../src/ufs-weather-model/tests/tests/regional_control.arc" ]; then
   echo "regional_control.arc existed!"
   cp ../../src/ufs-weather-model/tests/tests/regional_control.arc ../../src/ufs-weather-model/tests/tests/regional_control
else
   echo "no regional_control.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/tests/regional_control ../../src/ufs-weather-model/tests/tests/regional_control.arc
fi

# arc org regional.nml.IN 
if [ -f "../../src/ufs-weather-model/tests/parm/regional.nml.IN.arc" ]; then
   echo "regional.nml.IN.arc existed!"
   cp ../../src/ufs-weather-model/tests/parm/regional.nml.IN.arc ../../src/ufs-weather-model/tests/parm/regional.nml.IN
else
   echo "no regional.nml.IN.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/parm/regional.nml.IN ../../src/ufs-weather-model/tests/parm/regional.nml.IN.arc
fi

# arc org model_configure_regional.IN
if [ -f "../../src/ufs-weather-model/tests/parm/model_configure_regional.IN.arc" ]; then
   echo "model_configure_regional.IN.arc existed!"
   cp ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN.arc ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN
else
   echo "no model_configure_regional.IN.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN.arc
fi

#
sed -i "17s/write_tasks_per_group:   8/write_tasks_per_group:   ${CTEST_WRITE_TASKS}/" ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN
sed -i "28s/RESTART_INTERVAL=\"12 -1\"/RESTART_INTERVAL=0/" ../../src/ufs-weather-model/tests/tests/regional_control
sed -i "38s/TASKS=68/TASKS=${CTEST_TASKS}/" ../../src/ufs-weather-model/tests/tests/regional_control
sed -i "39s/INPES=10/INPES=${CTEST_LAYOUTX}/" ../../src/ufs-weather-model/tests/tests/regional_control
sed -i "40s/JNPES=6/JNPES=${CTEST_LAYOUTY}/" ../../src/ufs-weather-model/tests/tests/regional_control
OUT=$(tail -n 1 ../../src/ufs-weather-model/tests/tests/regional_control)
if [[ $OUT != "export FHMAX=$(eval echo "${CTEST_FHMAX}")" ]]; then
  echo "reduce runtime to 1hr and add stoch parameters!"
  #
  sed -i "$ a export DO_SPPT=.true." ../../src/ufs-weather-model/tests/tests/regional_control
  sed -i "$ a export DO_SHUM=.true." ../../src/ufs-weather-model/tests/tests/regional_control
  sed -i "$ a export DO_SKEB=.true." ../../src/ufs-weather-model/tests/tests/regional_control
  sed -i "$ a export SKEB=0.3" ../../src/ufs-weather-model/tests/tests/regional_control
  sed -i "$ a export SHUM=0.003" ../../src/ufs-weather-model/tests/tests/regional_control
  sed -i "$ a export SPPT=0.2" ../../src/ufs-weather-model/tests/tests/regional_control
  #
  sed -i "$ a export FHMAX=$(eval echo "${CTEST_FHMAX}")" ../../src/ufs-weather-model/tests/tests/regional_control
fi

#
sed -i '/&nam_stochy/r ./data/stoch.nml' ../../src/ufs-weather-model/tests/parm/regional.nml.IN

#
bash rt.sh
