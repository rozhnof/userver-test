cmake_minimum_required(VERSION 3.12)
project(template-service CXX)

set(CMAKE_CXX_STANDARD 20)

#USERVER ARGS
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
SET(USERVER_FEATURE_CRYPTOPP_BLAKE2 0)
SET(USERVER_FEATURE_REDIS_HI_MALLOC 1)
#SERVER ARGS\

include(third_party/userver/cmake/SetupEnvironment.cmake)
include(GNUInstallDirs)

add_subdirectory(third_party/userver)


# Common sources
add_subdirectory(src)
# file(GLOB SOURCE_CPP_FILES src/*.cpp)
# add_library(${PROJECT_NAME}_objs OBJECT SOURCE_CPP_FILES)

# Grpc enable
include(GrpcTargets)
file(GLOB SOURCE_PROTO_FILES proto/*.proto)

add_grpc_library(${PROJECT_NAME}_proto PROTOS 
    ${SOURCE_PROTO_FILES}
)

# target_link_libraries(${PROJECT_NAME}_objs PUBLIC userver-postgresql ${PROJECT_NAME}_proto)

# The Service
add_executable(${PROJECT_NAME} src/main.cc)

target_link_libraries(${PROJECT_NAME} PRIVATE 
    userver-postgresql 
    ${PROJECT_NAME}_proto
    DomainLayer
    InfrastructureLayer
    ApplicationLayer

)
target_link_options(${PROJECT_NAME} PRIVATE "SHELL:-Wl,-no-as-needed -lgrpc++_reflection" )


# Unit Tests
file(GLOB_RECURSE SOURCE_UNITTEST_FILES tests/unit/*.cpp tests/unit/*.hpp)
add_executable(${PROJECT_NAME}_unittest
    ${SOURCE_UNITTEST_FILES}
)
target_link_libraries(${PROJECT_NAME}_unittest PRIVATE 
    ${PROJECT_NAME}_proto
    DomainLayer 
    InfrastructureLayer
    ApplicationLayer
    userver-utest
)
add_google_tests(${PROJECT_NAME}_unittest)


# Benchmarks
file(GLOB SOURCE_BENCH_FILES CONFIGURE_DEPENDS tests/bench/*.cpp)
add_executable(${PROJECT_NAME}_benchmark
    ${SOURCE_BENCH_FILES}
)
target_link_libraries(${PROJECT_NAME}_benchmark PRIVATE userver-ubench)
add_google_benchmark_tests(${PROJECT_NAME}_benchmark)

# Functional Tests
add_subdirectory(tests/func)

if(DEFINED ENV{PREFIX})
    message(STATUS "Set install prefix: $ENV{PREFIX}")
    file(TO_CMAKE_PATH "$ENV{PREFIX}" PREFIX_PATH)
    set(CMAKE_INSTALL_PREFIX ${PREFIX_PATH})
endif()

set(CONFIG_VAR_PATH ${CMAKE_CURRENT_SOURCE_DIR}/configs/config_vars.yaml)
set(CONFIG_FALLBACK_PATH ${CMAKE_CURRENT_SOURCE_DIR}/configs/dynamic_config_fallback.json)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/configs/static_config.yaml.in ${CMAKE_CURRENT_SOURCE_DIR}/configs/static_config.yaml)

FILE(GLOB CONFIGS_FILES ${CMAKE_CURRENT_SOURCE_DIR}/configs/*.yaml ${CMAKE_CURRENT_SOURCE_DIR}/configs/*.json)
# target_compile_options(${PROJECT_NAME} PUBLIC
#        /MP     # multi-processor compilation
# )
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT ${PROJECT_NAME})
install(FILES ${CONFIGS_FILES} DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/${PROJECT_NAME} COMPONENT ${PROJECT_NAME})
