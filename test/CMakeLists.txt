#
set( test_scripts
  atparse.bash
  default_vars.sh 
  run_ccpp.sh
  run_regional_noquilt.sh
  run_regional_control.sh
  run_regional_stoch.sh
  rt.sh
  run_test.sh
  run_srw.sh
  config.sh.tmp
  linux.sh.tmp
  job_card
  job_card_orion
  run_barry.sh
  barry_vars.sh
)

#
set( machine_envs
  ${CMAKE_CURRENT_SOURCE_DIR}/machines/noaacloud_intel.env
  ${CMAKE_CURRENT_SOURCE_DIR}/machines/orion_intel.env
  ${CMAKE_CURRENT_SOURCE_DIR}/machines/orion_gnu.env
)

#
set( test_data
  ${CMAKE_CURRENT_SOURCE_DIR}/data/fv3_model_point_noah.nc
  ${CMAKE_CURRENT_SOURCE_DIR}/data/stoch.nml
  ${CMAKE_CURRENT_SOURCE_DIR}/tcvit_rsmc_storms.txt
  ${CMAKE_CURRENT_SOURCE_DIR}/fort.15
  ${CMAKE_CURRENT_SOURCE_DIR}/input.nml
)

#
foreach(FILENAME ${test_scripts})
    execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
           ${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME}
           ${CMAKE_CURRENT_BINARY_DIR}/${FILENAME} )
endforeach(FILENAME)

# machine envs
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/machines)
foreach(FILENAME ${machine_envs})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/machines/${filename} )
endforeach()

#
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data)
foreach(FILENAME ${test_data})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E create_symlink
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/data/${filename} )
endforeach()

#
if ( BUILD_CCPP-SCM )
  add_test ( NAME test_ccpp
             COMMAND bash run_ccpp.sh ${abs_top_srcdir}
             WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
endif()

#
add_test ( NAME test_fv3_regional_noquilt
           COMMAND bash run_regional_noquilt.sh 
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )

#
add_test ( NAME test_fv3_regional_upp
           COMMAND bash run_regional_control.sh 
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_fv3_regional_upp PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_fv3_regional_stoch
           COMMAND bash run_regional_stoch.sh 
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_fv3_regional_stoch PROPERTIES TIMEOUT 7200)

#
add_test ( NAME test_regional_workflow
           COMMAND bash run_srw.sh ${abs_top_srcdir} ${CMAKE_CURRENT_BINARY_DIR}
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
set_tests_properties(test_regional_workflow PROPERTIES TIMEOUT 7200)

#
if ( TEST_BARRY )
  add_test ( NAME test_barry
             COMMAND bash run_barry.sh ${abs_top_srcdir} ${CMAKE_CURRENT_BINARY_DIR}
             WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test )
  set_tests_properties(test_barry PROPERTIES TIMEOUT 7200)
endif()
