#!/bin/bash

#
rm rt.conf || true
cat << EOF > rt.conf
RUN     | regional_noquilt                                                                                                        |                                         | fv3 |
EOF

#
#sed -i "19s/TASKS=60/TASKS=2/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
#sed -i "36s/INPES=10/INPES=2/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
#sed -i "37s/JNPES=6/JNPES=1/" ../../src/ufs-weather-model/tests/tests/regional_noquilt
OUT=$(tail -n 1 ../../src/ufs-weather-model/tests/tests/regional_noquilt)
if [[ $OUT != "export FHMAX=1" ]]; then
  echo "reduce runtime to 1hr!"
  sed -i '$ a export FHMAX=1' ../../src/ufs-weather-model/tests/tests/regional_noquilt
fi
#
bash rt.sh
