#ifndef COLORPALETTE_H
#define COLORPALETTE_H

#include <opencv2/core/core.hpp>
using namespace std;
namespace MTMCT
{

    static vector<cv::Scalar> vColorPalette = {
        cv::Scalar(0, 255, 0), cv::Scalar(0, 255, 255),
        cv::Scalar(255, 0, 0), cv::Scalar(255, 0, 255), cv::Scalar(255, 255, 0),
        cv::Scalar(0, 0, 128), cv::Scalar(0, 128, 0),
        cv::Scalar(0, 128, 128), cv::Scalar(128, 0, 0), cv::Scalar(128, 0, 128),
        cv::Scalar(128, 128, 0), cv::Scalar(255, 255, 187), cv::Scalar(70, 130, 180),
        cv::Scalar(0, 100, 0), cv::Scalar(50, 205, 50), cv::Scalar(255, 251, 240),
        cv::Scalar(160, 160, 164), cv::Scalar(20, 106, 139), cv::Scalar(8, 139, 101),
        cv::Scalar(193, 193, 255), cv::Scalar(106, 106, 255), cv::Scalar(71, 130, 255),
        cv::Scalar(155, 211, 255), cv::Scalar(80, 127, 255), cv::Scalar(180, 105, 255),
        cv::Scalar(255, 228, 196), cv::Scalar(255, 250, 205), cv::Scalar(240, 255, 240),
        cv::Scalar(230, 230, 250), cv::Scalar(255, 240, 245), cv::Scalar(255, 228, 225),
        cv::Scalar(84 , 255, 159), cv::Scalar(82, 139, 139), cv::Scalar(132, 112, 255),
        cv::Scalar(70 , 130, 180), cv::Scalar(0, 191, 255), cv::Scalar(0, 206, 209)
    };

    static vector<cv::Scalar> vClusterColorPalette = {
        cv::Scalar(0, 0, 255), cv::Scalar(0, 255, 0), cv::Scalar(0, 255, 255),
        cv::Scalar(255, 0, 0), cv::Scalar(255, 0, 255), cv::Scalar(255, 255, 0),
        cv::Scalar(255, 255, 255), cv::Scalar(0, 0, 128), cv::Scalar(0, 128, 0),
        cv::Scalar(0, 128, 128), cv::Scalar(128, 0, 0), cv::Scalar(128, 0, 128),
    };

}
#endif