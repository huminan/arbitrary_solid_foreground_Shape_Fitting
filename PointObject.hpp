#ifndef POINTOBJECT_H
#define POINTOBJECT_H

#include <iostream>
#include <vector>
#include <list>
#include <Eigen/Dense>
#include <opencv2/core/core.hpp>

#include "SegmentObject.hpp"
#include "CurveObject.hpp"

#include "utils_base.hpp"

namespace MTMCT {

class DigitalStraightSegment;
class DominantSegment;
typedef std::list<DominantSegment>::iterator lDominantSegIt;


class t_point {
    public:
    int id;
    cv::Point2d pt;
    Eigen::Vector3d homo;

    float lTangent,rTangent;
    std::list<t_point>::iterator lReject, rReject;
    std::vector<std::list<DigitalStraightSegment>::iterator> vpSegs;
    Eigen::Vector2d vec;  

    
    float genCurvature();
};
typedef std::list<t_point> ContourList;
typedef std::list<t_point>::iterator ListIt;

#ifdef ELF_H
class t_curve;
typedef std::list<t_curve>::iterator lCurveIt;

class DominantPoint: public t_point
{
public:
    DominantPoint(DominantSegment &Lseg, DominantSegment &Rseg, 
                  std::list<DigitalStraightSegment>::iterator &Lsupp, 
                  std::list<DigitalStraightSegment>::iterator &Rsupp);
    ~DominantPoint() {}

    std::list<DigitalStraightSegment>::iterator mLeftSupport, mRightSupport;
    Eigen::Vector3d getSplitLine();
    Eigen::Vector3d getSplitLine(Eigen::Matrix3d &H);

    bool isInsideSupportRegion(Eigen::Vector3d pt_homo);
    

    float mConvexity;  

    void setDominantSegmentIts(lDominantSegIt &l, lDominantSegIt &r);
    void setLeftDominantSegmentIt(lDominantSegIt &l);
    void setRightDominantSegmentIt(lDominantSegIt &r);
    lDominantSegIt getLeftDominantSegmentIt();
    lDominantSegIt getRightDominantSegmentIt();
    lCurveIt getLeftCurveIt();
    lCurveIt getRightCurveIt();

private:
    lDominantSegIt mLeftDominantSegmentIt, mRightDominantSegmentIt;  
    
};
typedef std::list<DominantPoint>::iterator lDominantPtIt;
#endif

}

#endif