#include "CurveObject.hpp"
using namespace MTMCT;
using namespace std;


CodeHandler::CodeHandler() {
    mvCodes.reserve(8);
}

void CodeHandler::update(int code) 
{
    if (mvCodes.size() == 0) {
        mvCodes.push_back(code);
    }
    else if (!count(mvCodes.begin(), mvCodes.end(), code)) {
        int diff = code - *mvCodes.rbegin();
        int prev_code = *mvCodes.rbegin();

        if (diff < -1) {
            int diff7 = 7 - prev_code;
            for (int i = 0; i < diff7; i++)
                mvCodes.push_back(prev_code + i + 1);
            
            for (int i = 0; i <= code; i++)
                mvCodes.push_back(i);
        }
        else if (diff > 0) {
            for (int i = 0; i < diff; i++)
                mvCodes.push_back(prev_code + i + 1);
        }
    }
}

std::vector<int> CodeHandler::split(int code)
{
    std::vector<int> prev_codes;
    std::vector<int> curr_codes;

    
    int split_code = -1;
    
    if (inside(code)) {
        int idx = 0;
        for (; idx < mvCodes.size(); idx++) {
            int curr = mvCodes[idx];
            if (code == curr) split_code = curr;
            else {
                if (idx == mvCodes.size()-1)
                    break;
                int next = mvCodes[idx+1];
                if (code > curr && code < next) {
                    split_code = curr;
                    break;
                }
            }
        }
        cout << "split_code inside: " << split_code << endl;
    }
    else {
        if (code < mvCodes[0]) split_code = mvCodes[0];
        else if (code > mvCodes.back()) split_code = mvCodes.back();
        cout << "split_code outside: " << split_code << endl;
    }

    
    
    auto it = mvCodes.begin();
    for (; it!= mvCodes.end(); it++)
    {
        prev_codes.push_back(*it);
        if (*it == split_code) break;
    }
    for (; it != mvCodes.end(); it++)
    {
        curr_codes.push_back(*it);
    }

    mvCodes.swap(curr_codes);
    return prev_codes;
}

bool CodeHandler::match(CodeHandler &c)
{
    std::set<int> s_intersect;
    std::set_intersection(mvCodes.begin(), mvCodes.end(), 
                            c.begin(), c.end(), 
                            std::inserter(s_intersect, s_intersect.begin()));
    

    bool avaliable = true;

    
    if (mvCodes.size() > 2) {
        for (auto &e : s_intersect) {
            if (e != *mvCodes.begin() && e != *mvCodes.rbegin()) {
                avaliable = false;
                break;
            }
        }
    }
    else if (mvCodes.size() == 2) {
        if (s_intersect.size() == 2)
            avaliable = false;
    }
    else {  
        if (s_intersect.size() && 
            mvCodes[0] != *c.begin() && 
            mvCodes[0] != *c.rbegin()  )
            avaliable = false;
    }

    return avaliable;
}

void CodeHandler::fuse(CodeHandler &c) 
{
    auto it = c.begin();
    for (; it != c.end(); it++) 
        update(*it);
}

int CodeHandler::getFusedCodeSize(CodeHandler &c)
{
    
    std::set<int> s_union;
    std::set_union(mvCodes.begin(), mvCodes.end(),
                    c.begin(), c.end(),
                    std::inserter(s_union, s_union.begin()));
 
    int sz = s_union.size();

    if (s_union.size() == c.size() + mvCodes.size())
    {
        
        int code_front = mvCodes.back();
        int code_back = *c.begin();
        int diff = code_back - code_front;

        diff > 0 ? sz += diff - 1 : sz += 7 + diff;
    }

    return sz;
}


t_curve::t_curve(int cid): id(cid) 
{
    hist = boost::histogram::make_histogram(boost::histogram::axis::regular<>(16, -PI, PI));
}

























bool t_curve::matchByIntercept(const t_curve &curve, bool isLeftOnBorder, bool isRightOnBorder) 
{
    auto pt2_bg = curve.begin_seg->M->homo;
    auto pt2_end = curve.last_seg->M->homo;

    float d1,d2,d3,d4;
    if (begin_seg->isOutside(pt2_bg) ||
        last_seg->isOutside(pt2_end)) 
    {return false;}

    if (!isRightOnBorder && begin_seg->isOutside(pt2_end))
        return false;
    
    if (!isLeftOnBorder && last_seg->isOutside(pt2_bg))
        return false;

    return true;
}


bool t_curve::contains(const t_curve &curve, Eigen::Vector3d &pt_homo) {
    Eigen::Vector3d line_homo1 = getLineByPoints(curve.begin_seg->M->pt, last_seg->R->pt); 
    Eigen::Vector3d line_homo2 = getLineByPoints(begin_seg->M->pt, curve.last_seg->R->pt); 
    Eigen::Vector3d line_homo3 = getLineByPoints(begin_seg->M->pt, last_seg->R->pt);
    Eigen::Vector3d line_homo4 = getLineByPoints(curve.begin_seg->M->pt, curve.last_seg->R->pt);

    auto cross = line_homo1.cross(line_homo2);  
    if (line_homo3.dot(cross) > 0 && line_homo4.dot(cross) > 0) return true;

    if (line_homo1.dot(pt_homo) < 0 && line_homo2.dot(pt_homo) < 0 && line_homo3.dot(pt_homo) > 0 && line_homo4.dot(pt_homo) > 0) {
        return true;
    }

    return false;
}

t_curve* t_curve::tryToSplit (bool &isForward) {

    if (mCodeHandler.size() > 4) {
        
        
        
        float d = calcLinePtDist(begin_seg->code, begin_seg->M->homo, last_seg->R->homo);
        if (d < 0) {
            
            #ifdef DEBUG_SPLIT
            std::cout << "    Split curve " << id << "." << std::endl;
            #endif

            t_curve *pCurve;
            pCurve = new t_curve(id);
            pCurve->last_seg = last_seg;

            int len = last_seg->length;
            float r = 0.;
            auto it = last_seg;
            --it;
            for (; it != begin_seg; --it) {
                d = calcLinePtDist(begin_seg->code, begin_seg->M->homo, it->R->homo);
                if (d > 0) {
                    pCurve->length = len;
                    pCurve->rad = r;
                    pCurve->begin_seg = it;
                    pCurve->begin_seg++;
                    pCurve->convexity = calcCurveConvexity(len, r);

                    length -= len;
                    rad -= r + it->d_rad;
                    last_seg = it;
                    convexity = calcCurveConvexity(length, rad);

                    isForward = true;
                    return pCurve;
                }

                len += it->length;
                r += it->d_rad_next;
            }
        }

        
        d = calcLinePtDist(last_seg->code, last_seg->R->homo, begin_seg->M->homo);  
        if (d < 0)
        {
            #ifdef DEBUG_SPLIT
            std::cout << "    Split curve " << id << "." << std::endl;
            #endif

            t_curve *pCurve;
            pCurve = new t_curve(id+1);
            pCurve->begin_seg = begin_seg;

            int len = begin_seg->length;
            float r = begin_seg->d_rad;
            auto it = begin_seg;
            it++;
            for (; it != last_seg; it++) {
                d = calcLinePtDist(last_seg->code, last_seg->R->homo, it->M->homo); 
                if (d > 0) {
                    pCurve->length = len;
                    pCurve->rad = r;
                    pCurve->last_seg = it;
                    pCurve->last_seg--;
                    pCurve->convexity = calcCurveConvexity(len, r);

                    length -= len;
                    rad -= r;
                    begin_seg = it;
                    convexity = calcCurveConvexity(length, rad);

                    isForward = false;
                    return pCurve;
                }

                len += it->length;
                r += it->d_rad;
            }
        }
    }

    return nullptr;
}

void t_curve::prepareEntropy() {
    int e_seg = 0;
    hist.reset();

    auto segIt = begin_seg;
    for (; segIt != this->end(); ++segIt)
    {
        if (segIt->length < MIN_SEG_LEN) continue;
        hist(segIt->d_rad);
        ++e_seg;
    }

    segs_effect = e_seg;
}

bool t_curve::isDominantSegmentIntersect(std::list<t_curve>::iterator cit)
{
    auto ds1it = getDominantSegmentIt();
    auto ds2it = cit->getDominantSegmentIt();
    Eigen::Vector3d cross = ds1it->homo.cross(ds2it->homo);
    Eigen::Vector2d pt = cross.head<2>() / cross(2);
    if (isnan(pt(0)) || isnan(pt(1))) return false; 

    float x = pt(0), y = pt(1);
    auto L = miDominantSegment->getLeftDominantPointIt();
    auto R = miDominantSegment->getRightDominantPointIt();
    auto segL = ds2it->L;
    auto segR = ds2it->R;
    if (x < std::min(L->pt.x, R->pt.x) || x > std::max(L->pt.x, R->pt.x)) return false;
    if (x < std::min(segL->pt.x, segR->pt.x) || x > std::max(segL->pt.x, segR->pt.x)) return false;
    if (y < std::min(L->pt.y, R->pt.y) || y > std::max(L->pt.y, R->pt.y)) return false;
    if (y < std::min(segL->pt.y, segR->pt.y) || y > std::max(segL->pt.y, segR->pt.y)) return false;
    return true;
}

bool t_curve::isDominantSegmentIntersect(std::list<t_curve>::iterator cit1,
                                         std::list<t_curve>::iterator cit2)
{
    bool res = false;
    auto it = cit1;

    for ( ; it!= cit2; it++)
    {
        if (isDominantSegmentIntersect(it)) return true;
    }
    if (isDominantSegmentIntersect(it))   
        return true;

    return false;
}

bool t_curve::isIntersectWithLine(Eigen::Vector3d line)
{
    if (begin_seg->M->homo.dot(line) * last_seg->R->homo.dot(line) < 0) return true;
    
    return false;
}

Eigen::Vector3d t_curve::getBeginSupportline() {return begin_seg->M->homo;}
Eigen::Vector3d t_curve::getEndSupportline() {return last_seg->M->homo;}

std::vector<cv::Point2f> t_curve::getSparsePoints() {

    std::vector<cv::Point2f> pts;
    auto it = begin_seg;
    for (; it != this->end(); it++) {
        if (it->length < MIN_SEG_LEN) continue;
        pts.push_back(it->M->pt);
    }
    return pts;
}

std::vector<Eigen::Vector3d> t_curve::getHomoLines() {

    std::vector<Eigen::Vector3d> lines;
    auto it = begin_seg;
    for (; it != this->end(); it++) {
        if (it->length < MIN_SEG_LEN) continue;
        lines.push_back(it->homo);
    }
    return lines;
}

t_curve::eConvexityState t_curve::getConvexity() {
    if (convexity < 0) {
        if (convexity < CONCAVE_THRESHOLD) return VERY_CONCAVE;
        else return LITTLE_CONCAVE;
    }
    else {
        if (convexity < CONVEXITY_THRESHOLD) {
            if (segs < 5) return LITTLE_CONVEX;
            else if (segs < 10) 
            {
                Eigen::Vector3d l = begin_seg->M->homo.cross(last_seg->M->homo);
                l /= sqrt(l(0)*l(0) + l(1)*l(1));
                auto dist = l.dot(mid()->M->homo);
                auto length = norm(begin_seg->M->pt - last_seg->M->pt);
                if (abs(dist)/length > 0.1) return WELL_CONVEX;
                else return LITTLE_CONVEX;
            }
            else return WELL_CONVEX;
        }
        else return LITTLE_CONVEX;
    }
}

void t_curve::setDominantSegmentIt(lDominantSegIt it) {miDominantSegment = it;}
void t_curve::setLeftDominantPointIt(lDominantPtIt it) {miDominantSegment->setLeftDominantPointIt(it);}
void t_curve::setRightDominantPointIt(lDominantPtIt it) {miDominantSegment->setRightDominantPointIt(it);}
lDominantSegIt t_curve::getDominantSegmentIt() {return miDominantSegment;}
lDominantPtIt t_curve::getLeftDominantPointIt() {return miDominantSegment->getLeftDominantPointIt();}
lDominantPtIt t_curve::getRightDominantPointIt() {return miDominantSegment->getRightDominantPointIt();}

ListIt t_curve::bgpt() {return begin_seg->M;}
ListIt t_curve::edpt() {return last_seg->M;}