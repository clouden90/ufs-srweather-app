#!/usr/bin/env python3
import numpy as np
import sys

base_score=[]
with open("Indy-Severe-Weather/metprd/grid_stat/grid_stat_FV3_GFS_v16_SUBCONUS_3km_APCP_06h_CCPA_060000L_20190615_060000V.stat", 'r') as file_data:
    for line in file_data:
        data = line.split()
        if (data[23] == "NBRCNT" and data[20] == ">=0.254"):
                base_score.append(float(data[28]))


test_score=[]
with open("expt_dirs/test_community/2019061500/metprd/grid_stat/grid_stat_FV3_RRFS_v1beta_SUBCONUS_3km_APCP_06h_CCPA_060000L_20190615_060000V.stat", 'r') as file_data:
    for line in file_data:
        data = line.split()
        if (data[23] == "NBRCNT" and data[20] == ">=0.254"):
                test_score.append(float(data[28]))

base_score = round(np.mean(base_score),2)
print(base_score)

test_score = round(np.mean(test_score),2)
print(test_score)

try:
	if (test_score < base_score):
		raise Exception('!!!Warning!!! no improvment, STOP!!!')
	else:
		print('Precipitation prediction improved!!!')
except Exception as warm_inst:
	print(warm_inst);sys.exit(1)
