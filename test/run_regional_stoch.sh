#!/bin/bash

#
rm rt.conf || true
cat << EOF > rt.conf
RUN     | regional_spp_sppt_shum_skeb                                                                                             |                                         | fv3 |
EOF

#
sed -i "17s/write_tasks_per_group:   12/write_tasks_per_group:   8/" ../../src/ufs-weather-model/tests/parm/model_configure_regional_stoch.IN
sed -i "52s/domains_stack_size = 3000000/domains_stack_size = 9000000/" ../../src/ufs-weather-model/tests/parm/regional_stoch.nml.IN
sed -i "39s/INPES=15/INPES=12/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "40s/JNPES=12/JNPES=6/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "44s/TASKS=192/TASKS=80/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
sed -i "42s/THRD=2/THRD=1/" ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
#OUT=$(tail -n 1 ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb)
#if [[ $OUT != "export FHMAX=1" ]]; then
#  echo "reduce runtime to 1hr!"
#  sed -i '$ a export FHMAX=1' ../../src/ufs-weather-model/tests/tests/regional_spp_sppt_shum_skeb
#fi

#
bash rt.sh
