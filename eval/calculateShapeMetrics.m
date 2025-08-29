function metrics = calculateShapeMetrics(segElls, oriTotalShapes, segTotalFilled, numEllipses)
    % 计算形状指标
    % 参数:
    %   oriTotalShapes: 剪影的全体
    %   segTotalFilled: 椭圆的全体
    %   segElls: 拟合结构体
    % 返回:
    %   metrics: 形状指标结构体
    
    % 获取形状总面积
    A = sum(oriTotalShapes(:));
    
    % 计算总体形状覆盖率 (αE)
    I = oriTotalShapes > 0; % 原始形状
    UE = segTotalFilled > 0; % 所有椭圆的并集
    coverageRate = sum(I(:) & UE(:)) / A;
    
    % 计算椭圆数量 (k)
    k = numEllipses;
    
    % 计算局部对象的coverage, AIC
    for contour_id = 1:length(segElls)
        Ell_cnt = length(segElls(contour_id).ELs);
        nCompl = getObjectComplexity(segElls(contour_id).IContour);

        Iori = segElls(contour_id).IContour > 0;
        Iell = segElls(contour_id).Iells > 0;
        coverage = sum(Iori(:) & Iell(:)) / sum(Iori(:));

        [AIC,BIC,RES,bestAICBIC,SI] = getAIC_BIC(nCompl, coverage, Ell_cnt, 1); % EL ELLSET no use
        metrics.AIC(contour_id) = AIC;
    end
    
    
    % 计算Dice FP & FN
    TP = sum(I(:) & UE(:));
    FP = sum(~I(:) & UE(:));
    FN = sum(I(:) & ~UE(:));
    
    DiceFP = (2 * FP) / (2 * FP + TP + FN);
    DiceFN = (2 * FN) / (2 * FN + TP + FP);
    Precision = TP / (TP+FP);
    Recall = TP / (TP+FN);
    f1 = 2*(Precision * Recall) / (Precision+Recall);

    % 存储指标到结构体
    metrics.TP = TP;
    metrics.FP = FP;
    metrics.FN = FN;
    metrics.coverageRate = coverageRate; % αE == recall
    metrics.DiceFP = DiceFP;
    metrics.DiceFN = DiceFN;
    metrics.Precision = Precision;
    metrics.Recall = Recall;
    metrics.f1 = f1;
    metrics.numEllipses = k;
end
