#include "PointObject.hpp"

using namespace MTMCT;
using namespace std;

#ifdef ELF_H
DominantPoint::DominantPoint(DominantSegment &Lseg, DominantSegment &Rseg, lDssIt &Lsupp, lDssIt &Rsupp)
{
    

    pt = Lseg.R->pt;
    homo << pt.x, pt.y, 1;  

    mConvexity = Lseg.vec.cross(Rseg.vec);  
    

    mLeftSupport = Lsupp;
    mRightSupport = Rsupp;
}

Eigen::Vector3d DominantPoint::getSplitLine()
{
    cv::Point2d vec_split;
    Eigen::Vector2d perp;
    Eigen::Vector3d split_homo;
    vec_split = mRightSupport->vec / cv::norm(mRightSupport->vec) - mLeftSupport->vec / cv::norm(mLeftSupport->vec);
    vec_split = mLeftSupport->vec / cv::norm(mLeftSupport->vec) - mRightSupport->vec / cv::norm(mRightSupport->vec);

    perp << -vec_split.y, vec_split.x;
    perp.normalize();
    Eigen::Vector3d l_homo;
    l_homo << perp(0), perp(1), -perp.dot(toEigen(pt));
    return l_homo;
}

Eigen::Vector3d DominantPoint::getSplitLine(Eigen::Matrix3d &H)
{
    cv::Point2d vec_split;
    Eigen::Vector2d perp;
    Eigen::Vector3d split_homo;
    vec_split = mRightSupport->vec - mLeftSupport->vec;

    perp << -vec_split.y, vec_split.x;
    perp.normalize();
    Eigen::Vector3d l_homo;

    auto normalized_homo = H * homo;

    
    l_homo << perp(0), perp(1), -perp.dot(normalized_homo.head<2>());
    return l_homo;
}

bool DominantPoint::isInsideSupportRegion(Eigen::Vector3d pt_homo)
{
    if (mLeftSupport->homo.dot(pt_homo) > 0 && mRightSupport->homo.dot(pt_homo) > 0)
        return true;
}

void DominantPoint::setDominantSegmentIts(lDominantSegIt &l, lDominantSegIt &r) {mLeftDominantSegmentIt = l; mRightDominantSegmentIt = r;}
void DominantPoint::setLeftDominantSegmentIt(lDominantSegIt &l) {mLeftDominantSegmentIt = l;}
void DominantPoint::setRightDominantSegmentIt(lDominantSegIt &r) {mRightDominantSegmentIt = r;}
lDominantSegIt DominantPoint::getLeftDominantSegmentIt() {return mLeftDominantSegmentIt;}
lDominantSegIt DominantPoint::getRightDominantSegmentIt() {return mRightDominantSegmentIt;}
lCurveIt DominantPoint::getLeftCurveIt() {return mLeftDominantSegmentIt->getCurveIt();}
lCurveIt DominantPoint::getRightCurveIt() {return mRightDominantSegmentIt->getCurveIt();}

#endif