##### unit tests

# test for ush/retreve_data.py
add_test(NAME test_retreve_rap_lbcs_from_aws
         COMMAND python -m unittest -b test_retrieve_data.FunctionalTesting.test_rap_lbcs_from_aws 
         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/ush/)
