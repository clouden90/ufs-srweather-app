#!/bin/bash

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

#
rm rt.conf || true
cat << EOF > rt.conf
RUN     | regional_control                                                                                                        |                                         | fv3 |
EOF

#
#sed -i "17s/write_tasks_per_group:   8/write_tasks_per_group:   2/" ../../src/ufs-weather-model/tests/parm/model_configure_regional.IN
#sed -i "38s/TASKS=68/TASKS=6/" ../../src/ufs-weather-model/tests/tests/regional_control
#sed -i "39s/INPES=10/INPES=2/" ../../src/ufs-weather-model/tests/tests/regional_control
#sed -i "40s/JNPES=6/JNPES=2/" ../../src/ufs-weather-model/tests/tests/regional_control
OUT=$(tail -n 1 ../../src/ufs-weather-model/tests/tests/regional_control)
if [[ $OUT != "export FHMAX=1" ]]; then
  echo "reduce runtime to 1hr!"
  sed -i '$ a export FHMAX=1' ../../src/ufs-weather-model/tests/tests/regional_control
fi

#
bash rt.sh
