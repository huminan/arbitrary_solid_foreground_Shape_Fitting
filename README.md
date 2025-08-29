# arbitrary_solid_foreground_Shape_Fitting
This code is built for paper "Fast and Robust Low-Overlap Multi-Ellipse Contour Fitting for Arbitrary Solid Foreground Shapes", aims to efficiently and robustly fit arbitrary solid shapes with multiple ellipses while minimizing overlap. 

# Prerequisites

## Matlab
## C++ 14 and newer version

OpenCV4+

Eigen3

Boost

nlohmann_json

matioCpp

# Implementation

## Run

The code is recommended built in Linux/MacOs systems.

```
cd <workspace>/ellipticizer
mkdir build && cd build
cmake ..
make -j8
./ellipticizer-test ../../test_img/<image>
```

The program produces `.mat` files that contain fitting results, move these results to the `eval` folder. 

## Evaluation

run the file `eval/runCompares.m` in Matlab.

# Note

The repo will be accomplished soon. Any problems please issue or email huminant@163.com
