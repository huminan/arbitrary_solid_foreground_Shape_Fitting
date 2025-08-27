#ifndef UTILS_BASE_H
#define UTILS_BASE_H







#define ELF_H
#define ELF_DEBUG
#define ELF_DEBUG_DETAIL


#define DEBUG
#define DEBUG_CURVE_GEN      
#define DEBUG_CURVE_FUSION   


#define DEBUG_AIC
#define DEBUG_ELLIPSE_FIT_BY_POINTS
#define DEBUG_ELLIPSE_FIT_BY_LINES
#define DEBUG_ELLIPSE_INFO









#define PIx3 9.42477796
#define PIx2 6.2831853
#define PI   3.1415926
#define PI_HALF 1.5707963268

#include <list>
#include <set>
#include <map>
#include <deque>
#include <Eigen/Dense>
#include <opencv2/core/core.hpp>

namespace MTMCT {


inline Eigen::Vector2d toEigen(const cv::Point2d &pt) {
    Eigen::Vector2d v;
    v << pt.x, pt.y;

    return v;
}

inline Eigen::Vector3d toEigen3d(const Eigen::Vector2d &pt) {
    Eigen::Vector3d v;
    v << pt(0), pt(1), 1;
    return v;
}

inline cv::Point2d toCvpt(const Eigen::Vector2d &pt) {
    cv::Point2d v;
    v.x = pt[0];
    v.y = pt[1];
    return v;
}

inline cv::Point2d toCvpt(const Eigen::Vector3d &pt) {
    cv::Point2d v;
    v.x = pt[0];
    v.y = pt[1];
    return v;
}

inline Eigen::Vector3d CvptToEigenVec3(const cv::Point2d &pt) {
    Eigen::Vector3d v;
    v << pt.x, pt.y, 1;

    return v;
}

inline cv::Point2d calcMiddlePoint(const cv::Point2d &head, const cv::Point2d &tail) {

    return head + (tail - head)/2;
}

inline std::pair<Eigen::Vector3d, Eigen::Vector3d> calcMiddleLine(const cv::Point2d &head, const cv::Point2d &tail) {
    cv::Point2d pt = head + (tail - head)/2;
    cv::Point2d vec = tail - head;
    Eigen::Vector2d perp;
    Eigen::Vector3d homo;

    perp << -vec.y, vec.x;
    perp.normalize();
    homo << perp(0), perp(1), -perp.dot(toEigen(pt));
    return std::make_pair(CvptToEigenVec3(pt),homo);
}




inline float calcCurveConvexity(const int &len, const float &d_rad) {
    
    if (d_rad == 0.) 
        return -1.0/0.0;   
    else
        return log10(len) / d_rad;
}

inline float maxConvexity(const float convexity1, const float convexity2) {

    if (convexity1 < 0 && convexity2 > 0) return convexity2;
    else if (convexity1 > 0 && convexity2 < 0) return convexity1;
    else return fmin(convexity1,convexity2);
}

inline float minConvexity(const float convexity1, const float convexity2) {

    if (convexity1 < 0 && convexity2 > 0) return convexity1;
    else if (convexity1 > 0 && convexity2 < 0) return convexity2;
    else return fmax(convexity1,convexity2);
}


inline bool moreConvexity(const float convexity1, const float convexity2) {
    
    if (convexity1 < 0 && convexity2 > 0) return false; 
    else if (convexity1 > 0 && convexity2 < 0) return true; 
    else if (convexity1 > convexity2) return false; 
    else return true;
}


inline Eigen::Vector3d getLineByPoints(cv::Point2d pt_bg, cv::Point2d pt_end)
{
    cv::Point2d vec = pt_end - pt_bg;
    Eigen::Vector3d homo;
    Eigen::Vector2d perp;

    perp << -vec.y, vec.x;
    perp.normalize();
    homo << perp(0), perp(1), -perp.dot(toEigen(pt_bg));
    
    return homo;
}

}   


#endif