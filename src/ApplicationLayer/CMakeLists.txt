cmake_minimum_required(VERSION 3.12)
project(ApplicationLayer)

file(GLOB_RECURSE SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
)

file(GLOB_RECURSE HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp
)

add_library(${PROJECT_NAME} STATIC ${SOURCES} ${HEADERS})


target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_link_libraries(${PROJECT_NAME} PUBLIC
    DomainLayer
    InfrastructureLayer
    template-service_proto
    userver-core
)

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)