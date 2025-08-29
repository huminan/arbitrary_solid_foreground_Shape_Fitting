function metrics = calculateEllipseMetrics(GTBinary, GT, segBinary, segElls, numEst)
    % 计算椭圆指标
    % 参数:
    %   GTLabels: 真值标签图像
    %   toElliLabels: 椭圆拟合结果标签图像
    % 返回:
    %   metrics: 椭圆指标结构体
    
    % 获取区域属性

   
    
    numGT = size(GT,1);

     % !一定要存在真值
    if numGT == 0 || numEst == 0
        % 处理边缘情况
        metrics.TPR = 0;
        metrics.PPV = 0;
        metrics.AJSC = 0;
        metrics.AD = -1;
        metrics.TP = 0;
        metrics.FP = numEst;
        metrics.FN = numGT;
        metrics.BDE = -1;
        return;
    end
    
    % 提取参数
    gtParams = repmat(struct('C', [0,0], 'cx',0, 'cy',0, 'a', 0, 'b', 0, 'phi', 0), 1, numGT);
    for i = 1:numGT
        gtParams(i).C = [GT(i,1), GT(i,2)];
        gtParams(i).cx = GT(i,1);
        gtParams(i).cy = GT(i,2);
        gtParams(i).a = GT(i,3);
        gtParams(i).b = GT(i,4);
        gtParams(i).phi = -deg2rad(GT(i,5));
    end

    estParams = repmat(struct('C', [0,0], 'cx',0, 'cy',0, 'a', 0, 'b', 0, 'phi', 0), 1, numEst);
    cnt = 1;
    for i = 1:length(segElls)
        for j = 1:length(segElls(i).ELs)
            estParams(cnt).C = [segElls(i).ELs(j).cx, segElls(i).ELs(j).cy];
            estParams(cnt).cx = segElls(i).ELs(j).cx;
            estParams(cnt).cy = segElls(i).ELs(j).cy;
            estParams(cnt).a = segElls(i).ELs(j).a;
            estParams(cnt).b = segElls(i).ELs(j).b;
            estParams(cnt).phi = segElls(i).ELs(j).phi;
            cnt = cnt + 1;
        end
    end
    
    % 计算距离矩阵
    distMatrix = zeros(numEst, numGT);
    for i = 1:numEst
        for j = 1:numGT
            distMatrix(i,j) = norm(estParams(i).C - gtParams(j).C);
        end
    end
    
    % 使用阈值（8像素）确定匹配
    threshold = 8;
    matched = false(numEst, 1);
    gtMatched = false(numGT, 1);
    matchMap = zeros(numEst, 1);
    
    % 统计TP, FP, FN
    TP = 0;
    FP = 0;
    FN = 0;
    
    % 计算椭圆匹配，中心距离在阈值内的最近椭圆作为匹配，一个gt只能对应一个est
    for i = 1:numEst
        [minDist, bestMatch] = min(distMatrix(i,:));
        if minDist <= threshold && ~gtMatched(bestMatch)
            TP = TP + 1;
            matched(i) = true;
            gtMatched(bestMatch) = true;
            matchMap(i) = bestMatch;
        else
            FP = FP + 1;
        end
    end
    FN = numGT - sum(gtMatched);

    gtMatched = false(numGT, 1);
    matchPair = zeros(numEst+numGT,2,'int8');    % [est_id, gt_id, ...]
    % 计算椭圆匹配，所有gt与所有est都要匹配上（可以1对多）
    for i = 1:numEst
        [minDist, bestMatch] = min(distMatrix(i,:));
        gtMatched(bestMatch) = true;
        matchPair(i,1) = i;
        matchPair(i,2) = bestMatch;
    end

    % 把没匹配到的GT再去匹配一下
    cnt = 1;
    for i = 1:numGT
        if ~gtMatched(i)
            [minDist, bestMatch] = min(distMatrix(:,i));
            matchPair(numEst+cnt, 1) = bestMatch;
            matchPair(numEst+cnt, 2) = i;
            cnt = cnt + 1;
        end
    end

    matchPair = matchPair(1:numEst+cnt-1, :);
    
    % 计算TPR和PPV
    if (TP + FN) > 0
        TPR = TP / (TP + FN);
    else
        TPR = 0;
    end
    
    if (TP + FP) > 0
        PPV = TP / (TP + FP);
    else
        PPV = 0;
    end
    
    % 计算AJSC (平均杰卡德相似系数)
    jscValues = zeros(length(matchPair), 1);
    for i = 1:length(matchPair)
        [segB, ~] = generateEllipse(size(GTBinary), estParams(matchPair(i,1)));
        [gtB, ~] = generateEllipse(size(GTBinary), gtParams(matchPair(i,2)));

        intersection = segB & gtB;
        union = segB | gtB;

        jscValues(i) = sum(intersection(:)) / sum(union(:));
    end
    
    N = (numGT + numEst ) / 2;
    AJSC = sum(jscValues(:)) / N;

    
    % 计算AD (平均距离)
    AD = 0;
    if sum(matched) > 0
        for i = 1:numEst
            if matched(i)
                AD = AD + distMatrix(i, matchMap(i));
            end
        end
        AD = AD / sum(matched);
    else
        AD = inf;
    end
    
    % 计算BDE (边界位移误差)
    BDE = 0;
    bdeCounts = 0;
    
    for i = 1:numEst
        if matched(i)
            gtIdx = matchMap(i);
            
            % 获取椭圆边界点
            estBoundary = bwperim(segBinary == i);
            gtBoundary = bwperim(GTBinary == gtIdx);
            
            [estY, estX] = find(estBoundary);
            [gtY, gtX] = find(gtBoundary);
            
            estPoints = [estY, estX];
            gtPoints = [gtY, gtX];
            
            % 计算边界点之间的最小距离
            sumDist = 0;
            for p = 1:min(size(estPoints, 1), 100) % 限制采样点数量，提高计算效率
                pIdx = round(p * size(estPoints, 1) / min(size(estPoints, 1), 100));
                if pIdx > 0 && pIdx <= size(estPoints, 1)
                    distances = sqrt(sum((gtPoints - repmat(estPoints(pIdx,:), size(gtPoints, 1), 1)).^2, 2));
                    sumDist = sumDist + min(distances);
                end
            end
            
            BDE = BDE + (sumDist / min(size(estPoints, 1), 100));
            bdeCounts = bdeCounts + 1;
        end
    end
    
    if bdeCounts > 0
        BDE = BDE / bdeCounts;
    else
        BDE = inf;
    end
    
    % 存储指标到结构体
    metrics.TPR = TPR;
    metrics.PPV = PPV;
    metrics.AJSC = AJSC;
    metrics.AD = AD;
    metrics.TP = TP;
    metrics.FP = FP;
    metrics.FN = FN;
    metrics.BDE = BDE;
end
