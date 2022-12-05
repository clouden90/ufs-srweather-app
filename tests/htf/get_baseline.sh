#!/usr/bin/env bash
#
set -e -u -x



#
[[ ! -f ./Indy-Severe-Weather.tgz ]] && wget https://noaa-ufs-srw-pds.s3.amazonaws.com/sample_cases/release-public-v2.1.0/Indy-Severe-Weather.tgz
[[ ! -d ./Indy-Severe-Weather ]] && tar -zxvf Indy-Severe-Weather.tgz
