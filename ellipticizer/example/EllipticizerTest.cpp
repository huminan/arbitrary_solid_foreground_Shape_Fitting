
#include "Ellipselizer.hpp"
#include "ImageProductor.hpp"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <chrono>
#include <iostream>
#include <nlohmann/json.hpp>

using namespace std;
using namespace MTMCT;
using json = nlohmann::json;

#include <string>
int main(int argc, char* argv[])
{
    if (argc > 2) {
        std::cerr << "用法: " << argv[0] << " <图片路径>" << std::endl;
        return 1;
    }

    
    string imagePath;
    if (argc == 2) imagePath = argv[1];
    string save_dir = "./build/results/";
    int display_byContour = -1;      
    bool display_MR = true;
    bool display_MM = true;
    bool display_LMR = true;
    bool display_curves = true;
    bool display_curve_orient = true;
    bool save = true;
    int smooth = 0;    
    int morph = 0;     
    
    string tangentor = "FS";
    string curvator = "SW";
    
    bool open_prefuse = false;
    bool open_finalfuse = false;
    bool open_concave_field = false;
    
    
    float concave_th = 0.3;
    float finalfuse_th = 0.3;

    
    try {
        
        std::ifstream config_file("config.json");
        json config = json::parse(config_file);
        
        
        if (imagePath.empty())
            imagePath = config["dataset"];  
        save = config["save"];
        smooth = config["image_preprocess"]["smooth"];
        morph = config["image_preprocess"]["morphology"];
        display_MR = config["display"]["MR"];
        display_MM = config["display"]["MM"];
        display_LMR = config["display"]["LMR"];
        display_curves = config["display"]["curves"];
        display_byContour = config["display"]["contour"];
        display_curve_orient = config["display"]["curveOrient"];
        tangentor = config["curve_operation"]["tangentor"];
        curvator = config["curve_operation"]["curvator"];
        open_prefuse = config["curve_operation"]["prefuse"];
        concave_th = config["curve_operation"]["concave_threshold"];
        open_concave_field = config["curve_operation"]["concave_field"];
        open_finalfuse = config["fitting_operation"]["final_fuse"];
        finalfuse_th = config["fitting_operation"]["coin_threshold"];
    } catch (const std::exception& e) {
        std::cerr << "Error parsing JSON: " << e.what() << std::endl;
        return 1;
    }

    ContourObject::setCurvatorModule(curvator);
    ContourObject::setTangentorModule(tangentor);
    ContourObject::setConcaveFieldModule(open_concave_field);
    ContourObject::setPreFuseModule(open_prefuse);
    ContourObject::setFinalFuseModule(open_finalfuse, finalfuse_th);
    ContourObject::setSegConcaveRadThreshold(concave_th);

    cv::Mat img = cv::imread(imagePath, 0);    
    cv::Mat edge = cv::Mat::zeros(img.size(), CV_8UC1);

    
    ImageProductor dispLMR = ImageProductor(ImageProductor::BLACK, edge.size());
    ImageProductor dispMR = ImageProductor(ImageProductor::BLACK, edge.size());
    ImageProductor dispCurves = ImageProductor(ImageProductor::BLACK, edge.size());
    ImageProductor dispMM = ImageProductor(ImageProductor::BLACK, edge.size());

    auto start_total = std::chrono::system_clock::now();

    
    cv::Mat __;
    Ellipselizer *tf_ptr;

    
    if (morph > 0) {
        
        cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(morph, morph));
        cv::morphologyEx(img, img, cv::MORPH_CLOSE, element);
        cv::morphologyEx(img, img, cv::MORPH_OPEN, element);
    }

    
    if (smooth > 0) {
        cv::GaussianBlur(img, img, cv::Size(smooth, smooth), 0, 0);
    }

    
    cv::Canny( img, edge, 100, 200 );
    tf_ptr = new Ellipselizer(edge, __);

    
    
    
    for (int contour_id = 0; contour_id < tf_ptr->size(); contour_id++) {
        
        bool display = false;
        if (display_byContour == contour_id)
            display = true;
        else if (display_byContour == -1)
            display = true;

        if (display && display_curve_orient) {
            
            auto pContours = tf_ptr->getContoursPtr();
            cv::Mat disp = cv::Mat::zeros(img.rows, img.cols, CV_8UC3);
            cv::drawContours(disp, *pContours, contour_id, cv::Scalar(255, 255, 255), 1);
            
            cv::circle(disp, (*pContours)[contour_id][0], 3, cv::Scalar(0, 0, 255), -1);
            cv::Point2f direction = ((*pContours)[contour_id][1] - (*pContours)[contour_id][0]) * 10;
            cv::Point2f end_point = cv::Point2f((*pContours)[contour_id][0].x  + direction.x, (*pContours)[contour_id][0].y + direction.y);
            cv::arrowedLine(disp, (*pContours)[contour_id][0], end_point, cv::Scalar(0, 255, 0), 1);
            cv::imshow("contour", disp);
            cv::waitKey(0);
        }
        
        auto start = std::chrono::system_clock::now();

        
        tf_ptr->recognizeCurves(contour_id);

        
        if (display && display_MR) {
            dispMR = ImageProductor(ImageProductor::BLACK, edge.size());
            dispMR.setImage( tf_ptr->getSegmentMRMap(edge.rows, edge.cols, contour_id) );
            dispMR.setImage(edge);
            cv::imshow("[M,R) segments", dispMR.getImageWithInfo());
        }
        if (display && display_LMR) {
            dispLMR = ImageProductor(ImageProductor::BLACK, edge.size());
            dispLMR.setImage( tf_ptr->getSegmentLMRMap(edge.rows, edge.cols, contour_id) ); 
            dispLMR.setImage(edge);
            cv::imshow("(L,M,R] segments", dispLMR.getImageWithInfo());
        }
        if (display && display_curves) {
            dispCurves = ImageProductor(ImageProductor::BLACK, edge.size());
            dispCurves.setImage( tf_ptr->dispSegments(edge.rows, edge.cols, contour_id) );
            dispCurves.setImage( tf_ptr->dispCurves(edge.rows, edge.cols, contour_id) );
            dispCurves.setImage(edge);
            dispCurves.setInfo(contour_id, "contour");
            cv::imshow("DISP Curves", dispCurves.getImageWithInfo());
        }
        
        if (display && (display_MR || display_curves || display_LMR))
            cv::waitKey(0);
        
        
        tf_ptr->recognizeDominantRegions(contour_id);

        if (display && display_MM) {
            dispMM = ImageProductor(ImageProductor::BLACK, edge.size());
            dispMM.setImage( tf_ptr->dispSegments(edge.rows, edge.cols, contour_id) );
            dispMM.setImage( tf_ptr->dispCurves(edge.rows, edge.cols, contour_id) );
            dispMM.setImage(edge);
            dispMM.setInfo(contour_id, "contour");

            cv::imshow("DISP Dominant Curves", dispMM.getImageWithInfo());
            cv::waitKey(0);
        }
        

        
        tf_ptr->recognizeEllipses(contour_id);

        
        auto end = std::chrono::system_clock::now();      
        auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);

        if (display) {
            dispMM.setCostTime(duration, "x1");
            dispMM.setImage( tf_ptr->dispEllipseByDominants(edge.rows, edge.cols, contour_id) );

            
            
            cv::imshow("[M,M) segments", dispMM.getImageWithInfo());
            cv::waitKey(0);
        }
    }

    
    std::string::size_type iPos = imagePath.find_last_of('/') + 1;
    std::string filename = imagePath.substr(iPos, imagePath.length() - iPos);
    std::cout << "文件名: " << filename << std::endl;

    
    std::string name = filename.substr(0, filename.rfind("."));
    std::cout << "不带后缀的文件名: " << name << std::endl;
    
    tf_ptr->saveResults(save_dir+name+"_", SAVE_RES_BY_MATIOCPP);

    
    auto end_total = std::chrono::system_clock::now();      
    auto duration_total = chrono::duration_cast<chrono::milliseconds>(end_total - start_total);

    if (display_MM) {
        dispMM = ImageProductor(ImageProductor::BLACK, edge.size());
        dispMM.setCostTime(duration_total, "x1");
        dispMM.setImage( tf_ptr->dispSegments(edge.rows, edge.cols) );
        dispMM.setImage( tf_ptr->dispCurves(edge.rows, edge.cols) );
        dispMM.setImage( tf_ptr->dispEllipseByDominants(edge.rows, edge.cols) );
        dispMM.setImage(edge);

        dispMM.setInfo(tf_ptr->size(), "contours");
        cv::imshow("[M,M) segments", dispMM.getImageWithInfo());
    }
    if (display_MR) {
        dispMR = ImageProductor(ImageProductor::BLACK, edge.size());
        dispMR.setImage( tf_ptr->getSegmentMRMap(edge.rows, edge.cols) );
        dispMR.setImage(edge);
        cv::imshow("[M,R) segments", dispMR.getImageWithInfo());
    }
    if (display_LMR) {
        dispLMR = ImageProductor(ImageProductor::BLACK, edge.size());
        dispLMR.setImage( tf_ptr->getSegmentLMRMap(edge.rows, edge.cols) );
        dispLMR.setImage(edge);
        cv::imshow("(L,M,R] segments", dispLMR.getImageWithInfo());
    }

    if (display_MR || display_MM || display_LMR)
        cv::waitKey(0);
}
