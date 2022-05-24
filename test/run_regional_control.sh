#!/bin/bash

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
