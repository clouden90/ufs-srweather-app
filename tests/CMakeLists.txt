# files for htf
set( comp_files
  ${CMAKE_CURRENT_SOURCE_DIR}/htf/run_htf.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/htf/get_baseline.sh
  ${CMAKE_CURRENT_SOURCE_DIR}/htf/config.yaml.template
  ${CMAKE_CURRENT_SOURCE_DIR}/htf/check.py
)

# copy files
foreach(FILENAME ${comp_files})
     get_filename_component(filename ${FILENAME} NAME )
     execute_process( COMMAND ${CMAKE_COMMAND} -E copy
         ${FILENAME}
         ${CMAKE_CURRENT_BINARY_DIR}/${filename} )
endforeach()

# get baseline data
add_test( NAME get_baseline
    COMMAND bash get_baseline.sh )

set_tests_properties( get_baseline PROPERTIES FIXTURES_SETUP srw_db)

#
add_test( NAME test_SUBCONUS_Ind_3km_201906
    COMMAND bash run_htf.sh -p ${CMAKE_CURRENT_SOURCE_DIR} )

set_tests_properties( test_SUBCONUS_Ind_3km_201906
    PROPERTIES                  
    TIMEOUT 9600
    LABELS GST
    FIXTURES_SETUP test_srw
    FIXTURES_REQUIRED srw_db
    )
