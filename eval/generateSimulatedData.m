function [GT, toElli, GTLabels, toElliLabels] = generateSimulatedData()
    % 生成模拟数据
    % 返回:
    %   GT: 真值二值图像
    %   toElli: 椭圆拟合结果二值图像
    %   GTLabels: 真值标签图像
    %   toElliLabels: 椭圆拟合结果标签图像
    
    % 设置随机种子以保证可重复性
    rng(42);
    
    % 创建空白图像
    imageSize = [500, 600];
    GT = false(imageSize);
    toElli = false(imageSize);
    
    % 生成真值椭圆（包含5个椭圆）
    numEllipses = 5;
    GTEllipses = cell(numEllipses, 1);
    
    % 定义椭圆参数 [centerX, centerY, a, b, angle]
    ellipseParams = [
        150, 150, 80, 40, 30;   % 椭圆1
        300, 200, 60, 30, 0;    % 椭圆2
        200, 300, 50, 50, 0;    % 椭圆3 (圆形)
        350, 350, 70, 35, 45;   % 椭圆4
        450, 100, 55, 25, 60;   % 椭圆5
    ];
    
    % 创建真值标签图像
    GTLabels = zeros(imageSize);
    
    % 生成真值椭圆
    for i = 1:numEllipses
        [mask, points] = generateEllipse(imageSize, ellipseParams(i,:));
        GT = GT | mask;
        GTLabels(mask) = i;
        GTEllipses{i} = points;
    end
    
    % 生成椭圆拟合结果（模拟各种拟合情况）
    numFittedEllipses = 6;  % 5个真实椭圆，1个过分割
    toElliLabels = zeros(imageSize);
    
    % 添加一些噪声到真值椭圆参数 - 模拟多种情况：
    % 1. 近似正确拟合
    % 2. 位置偏移拟合
    % 3. 形状不同拟合
    % 4. 多检测/错误检测
    % 5. 漏检测
    noisyEllipseParams = [
        150, 145, 75, 38, 28;    % 近似椭圆1（接近正确）
        305, 203, 62, 31, 5;     % 近似椭圆2（接近正确）
        195, 295, 48, 48, 0;     % 近似椭圆3（接近正确）
        352, 348, 68, 33, 43;    % 近似椭圆4（接近正确）
        425, 105, 50, 30, 55;    % 近似椭圆5（形状不同）
        250, 250, 30, 20, 15;    % 额外的椭圆（错误检测）
    ];
    
    % 生成拟合椭圆
    for i = 1:numFittedEllipses
        [mask, ~] = generateEllipse(imageSize, noisyEllipseParams(i,:));
        toElli = toElli | mask;
        toElliLabels(mask) = i;
    end
end