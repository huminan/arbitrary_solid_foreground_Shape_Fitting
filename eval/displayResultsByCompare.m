function displayResultsByCompare(shapeMetrics, ellipseMetrics, contourMetrics, rfove)

    % 显示评估结果
    % 参数:
    %   shapeMetrics: 形状指标结构体
    %   ellipseMetrics: 椭圆指标结构体
    %   contourMetrics: 轮廓指标结构体
    
    fprintf('\n%s\n', repmat('=', 1, 50));
    fprintf('             椭圆拟合评估结果             \n');
    fprintf('%s\n', repmat('=', 1, 50));
    
    % 显示形状指标
    fprintf('\n%s\n', repmat('-', 1, 20));
    fprintf(' 形状指标 (CFE <-> RFOVE) \n');
    fprintf('%s\n', repmat('-', 1, 20));
    fprintf('形状覆盖率 (αE)    : %.4f (%.2f%%) <-> %.4f (%.2f%%)\n', shapeMetrics.coverageRate, shapeMetrics.coverageRate*100, rfove.shapeMetrics.coverageRate, rfove. shapeMetrics.coverageRate*100);
    fprintf('AIC                : ');
    for id = 1:length(shapeMetrics.AIC)
        fprintf('%.4f <-> %.4f,', shapeMetrics.AIC(id), rfove.shapeMetrics.AIC(id));
    end
    fprintf('\n');
    fprintf('真阳性 (TP)        : %d <-> %d\n', shapeMetrics.TP, rfove.shapeMetrics.TP);
    fprintf('假阳性 (FP)        : %d <-> %d\n', shapeMetrics.FP, rfove.shapeMetrics.FP);
    fprintf('假阴性 (FN)        : %d <-> %d\n', shapeMetrics.FN, rfove.shapeMetrics.FN);
    fprintf('Dice假阴性 (FN)    : %.4f <-> %.4f\n', shapeMetrics.DiceFN, rfove.shapeMetrics.DiceFN);
    fprintf('Dice假阳性 (FP)    : %.4f <-> %.4f\n', shapeMetrics.DiceFP, rfove.shapeMetrics.DiceFP);
    fprintf('Precision          : %.4f <-> %.4f\n', shapeMetrics.Precision, rfove.shapeMetrics.Precision);
    fprintf('Recall             : %.4f <-> %.4f\n', shapeMetrics.Recall, rfove.shapeMetrics.Recall);
    fprintf('f1-score           : %.4f <-> %.4f\n', shapeMetrics.f1, rfove.shapeMetrics.f1);
    fprintf('椭圆数量 (k)       : %d <-> %d\n', shapeMetrics.numEllipses, rfove.shapeMetrics.numEllipses);
    
    % 显示椭圆指标
    fprintf('\n%s\n', repmat('-', 1, 20));
    fprintf(' 椭圆指标 \n');
    fprintf('%s\n', repmat('-', 1, 20));
    fprintf('真阳性率 (TPR)     : %.4f (%.2f%%) <-> %.4f (%.2f%%)\n', ellipseMetrics.TPR, ellipseMetrics.TPR*100, rfove.ellipseMetrics.TPR, rfove.ellipseMetrics.TPR*100);
    fprintf('阳性预测值 (PPV)   : %.4f (%.2f%%) <-> %.4f (%.2f%%)\n', ellipseMetrics.PPV, ellipseMetrics.PPV*100, rfove.ellipseMetrics.PPV, rfove.ellipseMetrics.PPV*100);
    fprintf('平均杰卡德相似系数 (AJSC): %.4f (%.2f%%) <-> %.4f (%.2f%%)\n', ellipseMetrics.AJSC, ellipseMetrics.AJSC*100, rfove.ellipseMetrics.AJSC, rfove.ellipseMetrics.AJSC*100);
    fprintf('平均距离 (AD)      : %.4f <-> %.4f 像素\n', ellipseMetrics.AD, rfove.ellipseMetrics.AD);
    fprintf('边界位移误差 (BDE) : %.4f <-> %.4f 像素\n', ellipseMetrics.BDE, rfove.ellipseMetrics.BDE);
    fprintf('真阳性 (TP)        : %d <-> %d\n', ellipseMetrics.TP, rfove.ellipseMetrics.TP);
    fprintf('假阳性 (FP)        : %d <-> %d\n', ellipseMetrics.FP, rfove.ellipseMetrics.FP);
    fprintf('假阴性 (FN)        : %d <-> %d\n', ellipseMetrics.FN, rfove.ellipseMetrics.FN);
    
    % 显示轮廓指标
    fprintf('\n%s\n', repmat('-', 1, 20));
    fprintf(' 轮廓指标 \n');
    fprintf('%s\n', repmat('-', 1, 20));
    fprintf('JSC                : %.4f (%.2f%%)\n', contourMetrics.JSC, contourMetrics.JSC*100);
    fprintf('平均绝对轮廓距离 (MAD): %.4f 像素\n', contourMetrics.MAD);
    fprintf('Hausdorff距离      : %.4f 像素\n', contourMetrics.HausdorffDist);
    
    fprintf('\n%s\n\n', repmat('=', 1, 50));
    
    % 计算总体评估结果
    precisionScore = (ellipseMetrics.PPV + contourMetrics.JSC) / 2;
    recallScore = (ellipseMetrics.TPR + (1-shapeMetrics.DiceFN)) / 2;
    f1 = 2*(precisionScore * recallScore)/(precisionScore + recallScore);
    
    fprintf('总体评估结果：\n');
    fprintf('精确性（Precision）: %.4f (%.2f%%)\n', precisionScore, precisionScore*100);
    fprintf('召回率（Recall）   : %.4f (%.2f%%)\n', recallScore, recallScore*100);
    fprintf('F1-score         : %.4f (%.2f%%)\n', f1, f1*100);

end