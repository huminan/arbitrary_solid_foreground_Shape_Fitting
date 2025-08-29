function metrics = calculateContourMetrics(GTBorderLabel, ClustBorderLabel)
    % 计算轮廓指标
    % 参数:
    %   GTBorderLabel: 真值边界标签图像
    %   ClustBorderLabel: 椭圆拟合结果边界标签图像
    % 返回:
    %   metrics: 轮廓指标结构体
    
    % 获取边界点
    [gtY, gtX, gtLabels] = find(GTBorderLabel);
    [clY, clX, clLabels] = find(ClustBorderLabel);
    
    if isempty(gtY) || isempty(clY)
        % 处理边缘情况
        metrics.JSC = 0;
        metrics.MAD = inf;
        metrics.HausdorffDist = inf;
        return;
    end
    
    gtPoints = [gtY, gtX];
    clPoints = [clY, clX];
    
    % 按标签分组轮廓点
    uniqueGtLabels = unique(gtLabels);
    uniqueClLabels = unique(clLabels);
    
    gtContours = cell(length(uniqueGtLabels), 1);
    clContours = cell(length(uniqueClLabels), 1);
    
    for i = 1:length(uniqueGtLabels)
        idx = (gtLabels == uniqueGtLabels(i));
        gtContours{i} = gtPoints(idx, :);
    end
    
    for i = 1:length(uniqueClLabels)
        idx = (clLabels == uniqueClLabels(i));
        clContours{i} = clPoints(idx, :);
    end
    
    % 计算JSC
    % 创建一个二值掩码来计算并集和交集
    gtMask = GTBorderLabel > 0;
    clMask = ClustBorderLabel > 0;
    
    intersection = sum(gtMask(:) & clMask(:));
    union = sum(gtMask(:) | clMask(:));
    
    JSC = intersection / union;
    
    % 计算MAD (平均绝对轮廓距离)
    sumDist = 0;
    count = 0;
    
    for i = 1:size(gtPoints, 1)
        distances = sqrt(sum((clPoints - repmat(gtPoints(i,:), size(clPoints, 1), 1)).^2, 2));
        sumDist = sumDist + min(distances);
        count = count + 1;
    end
    
    MAD = sumDist / count;
    
    % 计算Hausdorff距离
    maxMinDist1 = 0;
    for i = 1:size(gtPoints, 1)
        distances = sqrt(sum((clPoints - repmat(gtPoints(i,:), size(clPoints, 1), 1)).^2, 2));
        minDist = min(distances);
        maxMinDist1 = max(maxMinDist1, minDist);
    end
    
    maxMinDist2 = 0;
    for i = 1:size(clPoints, 1)
        distances = sqrt(sum((gtPoints - repmat(clPoints(i,:), size(gtPoints, 1), 1)).^2, 2));
        minDist = min(distances);
        maxMinDist2 = max(maxMinDist2, minDist);
    end
    
    HausdorffDist = max(maxMinDist1, maxMinDist2);
    
    % 存储指标到结构体
    metrics.JSC = JSC;
    metrics.MAD = MAD;
    metrics.HausdorffDist = HausdorffDist;
end