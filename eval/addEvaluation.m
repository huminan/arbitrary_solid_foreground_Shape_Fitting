function [evaluationMap] = addEvaluation(evaluationMap, res, pic_name, area, perimeter)
% pic_name 图片的名字
% area 图片的前景面积
% perimeter 图片的前景周长

    method = res.methodStr;

    if ~isKey(evaluationMap, method)
        
        eval.Precision = res.shapeMetrics.Precision;
        eval.Recall = res.shapeMetrics.Recall;
        eval.f1 = res.shapeMetrics.f1;
        eval.DiceFP = res.shapeMetrics.DiceFP;
        eval.DiceFN = res.shapeMetrics.DiceFN;
        eval.numEllipses = res.shapeMetrics.numEllipses;
        eval.TPR = res.ellipseMetrics.TPR;
        eval.PPV = res.ellipseMetrics.PPV;
        eval.AD = res.ellipseMetrics.AD;
        eval.AJSC = res.ellipseMetrics.AJSC;
        eval.timeElapsed = res.timeElapsed;
        eval.area = area;
        eval.perimeter = perimeter;
        eval.cnt = 1;
        eval.dataNames = pic_name;

        evaluationMap(method) = eval;
        return;
    end

    eval = evaluationMap(method);
    eval.Precision = eval.Precision + res.shapeMetrics.Precision;
    eval.Recall = eval.Recall + res.shapeMetrics.Recall;
    eval.f1 = eval.f1 + res.shapeMetrics.f1;
    eval.DiceFP = eval.DiceFP + res.shapeMetrics.DiceFP;
    eval.DiceFN = eval.DiceFN + res.shapeMetrics.DiceFN;
    eval.numEllipses = eval.numEllipses + res.shapeMetrics.numEllipses;
    eval.TPR = eval.TPR + res.ellipseMetrics.TPR;
    eval.PPV = eval.PPV + res.ellipseMetrics.PPV;
    eval.AD = eval.AD + res.ellipseMetrics.AD;
    eval.AJSC = eval.AJSC + res.ellipseMetrics.AJSC;
    eval.timeElapsed = eval.timeElapsed + res.timeElapsed;
    eval.area = eval.area + area;
    eval.perimeter = eval.area + perimeter;
    eval.cnt = eval.cnt + 1;
    eval.dataNames = [eval.dataNames pic_name];

    evaluationMap(method) = eval;
end