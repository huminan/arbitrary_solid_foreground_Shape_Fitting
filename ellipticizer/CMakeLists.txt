cmake_minimum_required(VERSION 3.10)

project(Test)

# set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_BUILD_TYPE "Debug")

MESSAGE ( STATUS "Operation system is ${CMAKE_SYSTEM}.")

IF (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
ENDIF()

set(BOOST_ROOT "/opt/homebrew/Cellar/boost@1.85/1.85.0_3/lib/cmake/Boost-1.85.0")
set(Boost_NO_SYSTEM_PATHS ON)

#寻找OpenCV库
find_package(OpenCV REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(Boost REQUIRED)
find_package(GLEW REQUIRED)
find_package(matioCpp REQUIRED) # for display with matlab
find_package(nlohmann_json REQUIRED)    # for json

if(Boost_FOUND)
    MESSAGE (STATUS "Boost_INCLUDE_DIRS = ${Boost_INCLUDE_DIRS}.")
    MESSAGE (STATUS "Boost_LIBRARIES = ${Boost_LIBRARIES}.")
    MESSAGE (STATUS "Boost_LIB_VERSION = ${Boost_LIB_VERSION}.")
endif()

set(CMAKE_CXX_STANDARD_REQUIRED FALSE)
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)   # c++14 for boost

IF (COMPILER_SUPPORTS_CXX14)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -pthread -D_GLIBCXX_USE_NANOSLEEP")  # -O3
    set(CMAKE_CXX_STANDARD 14)
ELSE()
    message( STATUS "The comipler ${CMAKE_CXX_COMIPLER} has no C++ 14 suport.")
ENDIF()

message( STATUS "${BOOST_INCLUDE_DIRS}")

#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib)

##### 添加头文件
include_directories(${EIGEN3_INCLUDE_DIR})      # Eigen
include_directories(${OpenCV_INCLUDE_DIRS})     # Opencv
include_directories(${Boost_INCLUDE_DIRS})
include_directories(./)
include_directories(../)
include_directories(../tangentor)

##### 添加程序库
add_library(Test SHARED
 # ellipticizer-test 
./Ellipselizer.cpp
./ContourObject.cpp
./EllipseFitting.cpp
./CliqueObject.cpp
./CliquesHandler.cpp
./DominantRegion.cpp
../tangentor/LineFitter.cpp
../tangentor/Quadrantor.cpp
../tangentor/TangentorBase.cpp
../tangentor/TangentorFFT.cpp
../tangentor/TangentorHT.cpp
 # utils
../PointObject.cpp
../SegmentObject.cpp
../CurveObject.cpp
../ImageProductor.cpp
../DispParadigms.cpp
)


##### 链接库
target_link_libraries(Test ${OpenCV_LIBS} ${Boost_LIBRARIES} ${EIGEN3_LIBS} GLEW::glew matioCpp::matioCpp nlohmann_json::nlohmann_json)

##### 生成执行文件
# ellipticizer-test 
add_executable(ellipticizer-test ./example/EllipticizerTest.cpp)
target_link_libraries(ellipticizer-test Test)

