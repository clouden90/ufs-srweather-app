#!/bin/bash

if [ -d "./input-data/FV3_fix" ]; then
   echo "FV3_fix existed" 
else
   echo "no input-data/FV3_fix, create now"
   mkdir -p input-data/FV3_fix
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix input-data/FV3_fix --recursive
fi

# additional data for regional_stoch
if [ -d "./input-data/FV3_input_data_regional_stoch" ]; then
   echo "FV3_input_data_regional_stoch existed" 
else
   echo "no input-data/FV3_input_data_regional_stoch, create now"
   mkdir -p input-data/FV3_input_data_regional_stoch
   aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_regional_stoch input-data/FV3_input_data_regional_stoch --recursive
fi

#
rm rt.conf || true
cat << EOF > rt.conf
RUN     | regional_spp_sppt_shum_skeb                                                                                             |                                         | fv3 |
EOF

# arc org regional_spp_sppt_shum_skeb
if [ -f "../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb.arc" ]; then
   echo "regional_spp_sppt_shum_skeb.arc existed!"
   cp ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb.arc ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
else
   echo "no regional_spp_sppt_shum_skeb.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb.arc
fi

# arc org model_configure_regional_stoch.IN
if [ -f "../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN.arc" ]; then
   echo "model_configure_regional.IN.arc existed!"
   cp ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN.arc ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN
else
   echo "no model_configure_regional_stoch.IN.arc! Make archive now!"
   cp ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN.arc
fi

#
sed -i "17s/write_tasks_per_group:   12/write_tasks_per_group:   8/" ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN
sed -i "52s/domains_stack_size = 3000000/domains_stack_size = 9000000/" ../../src/ufs-weather-model/tests/parm/regional_stoch.nml.IN
sed -i "39s/INPES=15/INPES=12/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "40s/JNPES=12/JNPES=6/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "44s/TASKS=192/TASKS=80/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "42s/THRD=2/THRD=1/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb

#
bash rt.sh
