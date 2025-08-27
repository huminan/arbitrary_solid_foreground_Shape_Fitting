#ifndef CURVEOBJECT_H
#define CURVEOBJECT_H

#include <iostream>
#include <vector>
#include <set>

#include "SegmentObject.hpp"
#include "EllipseObject.hpp"

#define MIN_SEG_LEN 3 

namespace MTMCT {


class CodeHandler {

    std::vector<int> mvCodes;

public:

    CodeHandler();

    void update(int code);
    inline void setCodes(std::vector<int> &codes) {mvCodes.swap(codes);}

    /** @brief 将codes在code处分割，后半部分作为自己的codes，并返回前半部分
     * @note 若 code 不在 codes中
     *       取 codes 里最近的作为 split_code
     */
    std::vector<int> split(int split_code);

    /** @brief 判断两条曲线在朝向上是否可合并 
     * @return true:匹配成功/false:匹配失败
    */
    bool match(CodeHandler &c);

    
    void fuse(CodeHandler &c);

    /** @brief 获取this与c合并之后的code size
     * @note c一定得在this之后 */
    int getFusedCodeSize(CodeHandler &c);

    
    bool inside(int code) {
        
        if (mvCodes.size() == 1 && mvCodes[0] == code) 
            return true;
        else if (mvCodes[0] < mvCodes.back() && code >= mvCodes[0] && code <= mvCodes.back())
            return true;
        else if (mvCodes[0] > mvCodes.back() && (code >= mvCodes[0] || code <= mvCodes.back()))
            return true;
        else if (mvCodes[0] == mvCodes.back())
            return true;

        return false;
    }


    inline int size() {return mvCodes.size();}
    inline std::vector<int>::iterator begin(){return mvCodes.begin();}
    inline std::vector<int>::iterator end(){return mvCodes.end();}
    inline std::vector<int>::reverse_iterator rbegin(){return mvCodes.rbegin();}
    inline void clear() {std::vector<int>().swap(mvCodes); mvCodes.reserve(8);}
};

class t_point;
typedef std::list<t_point>::iterator ListIt;

class DominantPoint;
typedef std::list<DominantPoint>::iterator lDominantPtIt;

class DominantSegment;
typedef std::list<DominantSegment>::iterator lDominantSegIt;




class DigitalStraightSegment;
typedef std::list<DigitalStraightSegment>::iterator lDssIt;
class t_curve {
    
    int code_disturb = -1;
    

    public:

    enum eSupportLineForm {
        INJECTION,
        DEFLECTION,
        HOOK,
        BORDER
    };

    CodeHandler mCodeHandler;

    
    int id = -1;
    lDssIt begin_seg, last_seg;
    
    ListIt end_pt;

    std::pair<eSupportLineForm,eSupportLineForm> mSupportPair;

    int segs = -1;   
    int segs_effect = -1;   
    int length; 
    float rad;    

    bool unique = true;
    bool fitable = false;    
    t_Eigen3x3_Ellipse ellipse;

    t_curve *mpChildCurve = nullptr;  

    float convexity;    
    boost::histogram::histogram<std::tuple<boost::histogram::axis::regular<>>, 
                                boost::histogram::default_storage> hist;


    enum eConvexityState {
        VERY_CONCAVE = -2,
        LITTLE_CONCAVE = -1,
        LITTLE_CONVEX = 1,
        WELL_CONVEX = 2
    };

    
    t_curve(int cid);
    

    inline bool isWellConvex() {return (convexity > 0 && convexity < CONVEXITY_THRESHOLD);}
    inline bool isLittleConvex() {return convexity > CONVEXITY_THRESHOLD;}
    inline bool isConcave() {return convexity < 0;}
    inline bool isConvex() {return convexity > 0;}
    inline bool isLittleConcave() {return convexity < CONCAVE_THRESHOLD;}
    inline bool isVeryConcave() {return convexity < 0 && convexity > CONCAVE_THRESHOLD;}

    inline lDssIt begin() {return begin_seg;}
    inline lDssIt end() {
        auto end_seg = last_seg;
        ++end_seg;
        return end_seg;
    }
    inline lDssIt last() {return last_seg;}
    inline lDssIt mid() {
        lDssIt mid_seg = begin_seg;
        
        int i = 0;
        for (auto it = begin_seg; it != end(); it++,i++) {
            if (i) {
                ++mid_seg;
                i = 0;
            }
        }

        return mid_seg;
    }

    Eigen::Vector3d getBeginSupportline();
    Eigen::Vector3d getEndSupportline();

    std::vector<cv::Point2f> getSparsePoints();

    std::vector<Eigen::Vector3d> getHomoLines();

    eConvexityState getConvexity();

    
    void prepareEntropy();

    inline float getLocalComplexity() {
        float complexity = 0.0;
        
        for (auto&& x : boost::histogram::indexed(hist))
        {
            if (*x == 0) continue;
            
            complexity -= *x / segs_effect * log(*x / segs_effect);
            
        }
        

        return complexity;
    }


    

    
    
    
    
    
    
    

    
    
    
    
                
    
    
    
    
    
    
    
    
    

    
    


    
    
    
                
    
    
    


    /** @brief 根据curve端点是否在本曲线范围域内判断是否可合并 
     * @return true:匹配成功/false:匹配失败
    */
    bool matchByIntercept(const t_curve &curve, bool isLeftOnBorder=false, bool isRightOnBorder=false);

    bool contains(const t_curve &curve, Eigen::Vector3d &pt_homo);

    /** @brief 勾形检测
     * @note
     * 触发条件：
     * 1. 首尾code的差值大于4，i.e. 这是一条转弯超过180度的曲线（引理）
     * 2. 存在首尾LR(尾首RL)连线不在首(尾)垂向半平面内，i.e. 是所形成闭合曲线非凸的充要条件（引理）
     * 注：称为尾(首)部超出
     * 
     * 分割操作：
     * - 若尾部超出，就从尾部R往回寻找未超出的点P，并返回LP曲线对应的指针
     * - 若首部超出，就从首部L往后寻找未超出的点P，并返回PR曲线对应的指针
     * - TODO: 若均超出，那么首尾均需要寻找Pl和Pr，需要分割为三条曲线
     * 
     * 解释：
     * - 若单侧超出，以尾部超出举例，如果从首部L往后寻找未超出R的点P，
     *   那么PR所形成的凸包一定包含LP所形成的凸包（引理）
     *   PR只能与其它曲线结合，所以只需找到LP即可
     * - 若均超出，那么各自寻找的LPl和PrR一定互相不包含（前提：LR不相交），PlPr与其它曲线形成凸包
     * 
     * @param isForward    T: 尾巴超了; F: 首部超了
     * @return 未超出那部分的curve指针，若无则返回nullptr
    */
    t_curve *tryToSplit (bool &isForward);

    
    bool isDominantSegmentIntersect(std::list<t_curve>::iterator cit);

    
    bool isDominantSegmentIntersect(std::list<t_curve>::iterator cit1,
                                    std::list<t_curve>::iterator cit2);

    bool isIntersectWithLine(Eigen::Vector3d line);

    inline void dispCodes() {
        std::cout << "#" << id << ": ";
        auto it = mCodeHandler.begin();
        for (; it != mCodeHandler.end(); it++) {
            std::cout << *it << " ";
        }
        std::cout << std::endl;
    }

    void setDominantSegmentIt(lDominantSegIt it);
    void setLeftDominantPointIt(lDominantPtIt it);
    void setRightDominantPointIt(lDominantPtIt it);
    lDominantSegIt getDominantSegmentIt();
    lDominantPtIt getLeftDominantPointIt();
    lDominantPtIt getRightDominantPointIt();

    
    ListIt bgpt();
    
    ListIt edpt();
    
private:
    lDominantSegIt miDominantSegment;
};
typedef std::list<t_curve>::iterator l_CurveIt;
typedef std::list<l_CurveIt>::iterator l_CurveIt2;
typedef const std::list<t_curve>::iterator cl_CurveIt;

}   

#endif