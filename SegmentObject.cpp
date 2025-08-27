#include "SegmentObject.hpp"

using namespace MTMCT;
using namespace std;

void t_segment::setLineParams(const cv::Point2d &v, const cv::Point2d &pt)
{
    if (isnan(v.x)) vec = cv::Point2d(0, v.y);
    else if (isnan(v.y)) vec = cv::Point2d(v.x, 0);
    else vec = v;

    perp << -vec.y, vec.x;
    perp.normalize();
    
    homo << perp(0), perp(1), -perp.dot(toEigen(pt));
}

float t_segment::getEccentricity(ListIt ptIt, int countourLength)
{
    float a = std::abs(ptIt->id - M->id);
    float b = countourLength - a;
    return  a < b ? a / length : b / length;
}

bool t_segment::isIntersect(const t_segment &seg)
{
    Eigen::Vector3d cross = homo.cross(seg.homo);
    Eigen::Vector2d pt = cross.head<2>() / cross(2);
    if (isnan(pt(0)) || isnan(pt(1))) return false; 

    float x = pt(0), y = pt(1);
    if (x < std::min(L->pt.x, R->pt.x) || x > std::max(L->pt.x, R->pt.x)) return false;
    if (x < std::min(seg.L->pt.x, seg.R->pt.x) || x > std::max(seg.L->pt.x, seg.R->pt.x)) return false;
    if (y < std::min(L->pt.y, R->pt.y) || y > std::max(L->pt.y, R->pt.y)) return false;
    if (y < std::min(seg.L->pt.y, seg.R->pt.y) || y > std::max(seg.L->pt.y, seg.R->pt.y)) return false;
    return true;
}

bool t_segment::isInside(const Eigen::Vector3d &pt_homo)
{
    if (homo.dot(pt_homo) >= 0) return true;
    else return false;
}

bool t_segment::isOutside(const Eigen::Vector3d &pt_homo)
{
    if (homo.dot(pt_homo) < 0) return true;
    else return false;
}

#ifdef ELF_H
DominantSegment::DominantSegment(ListIt l, ListIt r, int id) 
{
    cid = id;
    L = l; R = r;
    cv::Point2d v = R->pt - L->pt;
    setLineParams(v, L->pt);
}

DominantSegment::DominantSegment(lDominantPtIt l, lDominantPtIt r, int id)
{
    cid = id;
    mLeftDominantPtIt = l;
    mRightDominantPtIt = r;

    cv::Point2d v = r->pt - l->pt;
    setLineParams(v, l->pt);
}

void DominantSegment::update()
{
    cv::Point2d v = mRightDominantPtIt->pt - mLeftDominantPtIt->pt;
    setLineParams(v, mLeftDominantPtIt->pt);
}

bool DominantSegment::isIntersect(Eigen::Vector3d pt_homo)
{
    if (homo.dot(pt_homo) < 0) return true;
    else return false;
}

bool DominantSegment::isIntersect(const DominantSegment &seg)
{
    Eigen::Vector3d cross = homo.cross(seg.homo);
    Eigen::Vector2d pt = cross.head<2>() / cross(2);
    if (isnan(pt(0)) || isnan(pt(1))) return false; 

    float x = pt(0), y = pt(1);
    if (x < std::min(L->pt.x, R->pt.x) || x > std::max(L->pt.x, R->pt.x)) return false;
    if (x < std::min(seg.L->pt.x, seg.R->pt.x) || x > std::max(seg.L->pt.x, seg.R->pt.x)) return false;
    if (y < std::min(L->pt.y, R->pt.y) || y > std::max(L->pt.y, R->pt.y)) return false;
    if (y < std::min(seg.L->pt.y, seg.R->pt.y) || y > std::max(seg.L->pt.y, seg.R->pt.y)) return false;
    return true;
}

bool DominantSegment::isIntersect(std::list<DominantSegment>::iterator it1, 
                                  std::list<DominantSegment>::iterator it2) 
{
    bool res = false;
    auto it = it1;

    for ( ; it!= it2; it++)
    {
        if (isIntersect(*it)) return true;
    }
    if (isIntersect(*it))   
        return true;

    return false;
}

void DominantSegment::setCurveIt(lCurveIt it) {mCurveIt = it;}
lCurveIt DominantSegment::getCurveIt() {return mCurveIt;}
lDominantPtIt DominantSegment::getLeftDominantPointIt() {return mLeftDominantPtIt;}
lDominantPtIt DominantSegment::getRightDominantPointIt() {return mRightDominantPtIt;}
std::pair<lDominantPtIt,lDominantPtIt> DominantSegment::getDominantPointIts() {return std::make_pair(mLeftDominantPtIt, mRightDominantPtIt);}
#endif