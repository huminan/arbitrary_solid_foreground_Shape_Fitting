#ifndef SEGMENTOBJECT_H
#define SEGMENTOBJECT_H

#include <iostream>
#include <vector>
#include <list>
#include <Eigen/Dense>
#include <opencv2/core/core.hpp>


#include "PointObject.hpp"

#include "utils_base.hpp"

#ifdef ELF_H

#endif

namespace MTMCT {

class t_point;
typedef std::list<t_point>::iterator ListIt;



class t_segment {
    
    public:

    ListIt L, R, M;
    long mSegID = -1;
    int curveID = -1;     
    int length;
    cv::Point2d vec;      
    Eigen::Vector2d perp; 
    Eigen::Vector3d homo; 
    int code = -1;        

    
    float d_rad = 0.;      
    float d_rad_next = 0.;
    int prev_0_cnt = 0;   

    
    void setLineParams(const cv::Point2d &v, const cv::Point2d &pt);

    inline float getTangent() {return vec.y / vec.x;}

    
    float getEccentricity(ListIt ptIt, int countourLength);

    /** @brief 判断两条线段(L,R)和(seg.L,seg.R)之间是否有交点
     * @note 判断交点是否在两条线段上
     */
    bool isIntersect(const t_segment &seg);

    /** @brief 判断pt是否在线段的内部
     * @note 若pt在直线上，也认为在内部
     */
    bool isInside(const Eigen::Vector3d &pt_homo);
    bool isOutside(const Eigen::Vector3d &pt_homo);
};

typedef std::vector<t_segment>::iterator vSegIt;
typedef std::list<t_segment>::iterator lSegIt;


class DigitalStraightSegment: public t_segment {
    public:
    
    int prev_0_cnt = 0;   
};
typedef DigitalStraightSegment Dss;
typedef std::vector<DigitalStraightSegment>::iterator vDssIt;
typedef std::list<DigitalStraightSegment>::iterator lDssIt;

#ifdef ELF_H

class DominantPoint;
typedef std::list<DominantPoint>::iterator lDominantPtIt;

class t_curve;
typedef std::list<t_curve>::iterator lCurveIt;

class DominantSegment: public t_segment {
    public:
    DominantSegment() {};
    DominantSegment(ListIt l, ListIt r, int id);
    DominantSegment(lDominantPtIt l, lDominantPtIt r, int id);

    
    
    int cid;    
    int supp_bg = -1;
    int supp_end = -1;
    std::vector<std::list<DominantSegment>::iterator> mviIntersectSegments;

    void update();

    
    bool isIntersect(const DominantSegment &seg);

    
    
    bool isIntersect(Eigen::Vector3d pt_homo);

    
    bool isIntersect(std::list<DominantSegment>::iterator it1, 
                     std::list<DominantSegment>::iterator it2);

    void setCurveIt(lCurveIt it);
    inline void setDominantPoints(lDominantPtIt left, lDominantPtIt right) {mLeftDominantPtIt = left; mRightDominantPtIt = right;}
    inline void setLeftDominantPointIt(lDominantPtIt left) {mLeftDominantPtIt = left;}
    inline void setRightDominantPointIt(lDominantPtIt right) {mRightDominantPtIt = right;}
    lCurveIt getCurveIt();
    lDominantPtIt getLeftDominantPointIt();
    lDominantPtIt getRightDominantPointIt();
    std::pair<lDominantPtIt,lDominantPtIt> getDominantPointIts();

    private:
    
    lCurveIt mCurveIt;
    lDominantPtIt mLeftDominantPtIt, mRightDominantPtIt;
};
typedef std::vector<DominantSegment>::iterator vDominantSegIt;
typedef std::list<DominantSegment>::iterator lDominantSegIt;
#endif

} 

#endif