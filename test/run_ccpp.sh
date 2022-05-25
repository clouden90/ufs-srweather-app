#!/bin/bash
#
echo "top src folder is located at: $1"
export SCM_ROOT=$1/src/ccpp-scm
echo $SCM_ROOT
#
#get data for ccpp-scm
if [ -d "../../src/ccpp-scm/scm/data/physics_input_data" ]; then
   echo "data for ccpp-scm existed!"
else
   echo "no data for ccpp-scm, download now!"
   sh ../../src/ccpp-scm/contrib/get_all_static_data.sh
fi
#
#ln -fs $SCM_ROOT/scm/src/run_scm.py ./
#ln -fs $SCM_ROOT/scm/src/suite_info.py ./
cp $SCM_ROOT/scm/src/run_scm.py ./
cp $SCM_ROOT/scm/src/suite_info.py ./
cp $SCM_ROOT/scm/src/supported_cases.py ./
module load nco || true
#
cp ../../test/data/fv3_model_point_noah.nc $SCM_ROOT/scm/data/processed_case_input/fv3_model_point_noah.nc
#
sed -i 's/scm\/run/..\/..\/\/build\/test\/run/g' run_scm.py
sed -i 's/scm\/bin/..\/..\/bin/g' run_scm.py
# run two cases
python3 run_scm.py -c fv3_model_point_noah --levels 64
python3 run_scm.py -c fv3_model_point_noah --levels 64 --suite SCM_GFS_v16
#
cat << EOF > ./run/fv3_test.ini
scm_datasets = output_fv3_model_point_noah_SCM_GFS_v15p2/output.nc, output_fv3_model_point_noah_SCM_GFS_v16/output.nc
scm_datasets_labels = GFS_v15p2, GFS_v16
plot_dir = plots_noahmp/
obs_file = ../data/raw_case_input/twp180iopsndgvarana_v2.1_C3.c1.20060117.000000.cdf
obs_compare = False
plot_ind_datasets = False
time_series_resample = True

[time_slices]
  [[total]]
    start = 2016, 10, 3, 0
    end = 2016, 10, 4, 0

[time_snapshots]

[plots]
  [[profiles_mean]]
    vars = qc, qv, T
    vars_labels = 'qc', 'qv', 'T'
    vert_axis = pres_l
    vert_axis_label = 'p (Pa)'
    y_inverted = True
    y_log = False
    y_min_option = min             #min, max, val (if val, add y_min = float value)
    y_max_option = max              #min, max, val (if val, add y_max = float value)

  [[profiles_mean_multi]]

  [[profiles_instant]]

  [[time_series]]
    vars = 'pres_s','lhf','shf'
    vars_labels = 'surface pressure','lhf','shf'

  [[contours]]
    vars = qv,
    vars_labels = 'qv',
    vert_axis = pres_l
    vert_axis_label = 'p (Pa)'
    y_inverted = True
    y_log = False
    y_min_option = val             #min, max, val (if val, add y_min = float value)
    y_min = 10000.0
    y_max_option = val              #min, max, val (if val, add y_max = float value)
    y_max = 100000.0
    x_ticks_num = 10
    y_ticks_num = 10
EOF
#
cd run && python3 scm_analysis.py fv3_test.ini 

