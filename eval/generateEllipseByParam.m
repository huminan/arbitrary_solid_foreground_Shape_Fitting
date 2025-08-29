function [mask, points] = generateEllipseByParam(imageSize, Elli, offset, resizeRatio)

    centerX = Elli.C(1);
    centerY = Elli.C(2);
    a = Elli.a;
    b = Elli.b;
    angle = Elli.phi;  % 转换为弧度
    
    % 偏移坐标（apoX, apoY 是子图左上角在整图中的位置）
    bbox = offset;  % [apoX eosX apoY eosY]
    apoX = bbox(1);
    apoY = bbox(3);

    % 调整椭圆边界
    if resizeRatio < 1
        apoX = round(apoX / resizeRatio);  % 调整坐标，缩小因子应除以 resizeFactor
        apoY = round(apoY / resizeRatio);  % 同样调整 Y 坐标
        a = a / resizeRatio;  % 椭圆的长半轴和短半轴根据缩放因子调整
        b = b / resizeRatio;
    
    
        % 缩放椭圆的中心坐标
        centerX = centerX / resizeRatio;
        centerY = centerY / resizeRatio;
    end

    centerX = centerX + apoX;
    centerY = centerY + apoY;
    
    % 创建网格
    [X, Y] = meshgrid(1:imageSize(2), 1:imageSize(1));
    
    % 平移到原点
    Xt = X - centerX;
    Yt = Y - centerY;
    
    % 旋转
    Xr = Xt * cos(angle) + Yt * sin(angle);
    Yr = -Xt * sin(angle) + Yt * cos(angle);
    
    % 计算椭圆方程
    ellipse = (Xr.^2)/(a^2) + (Yr.^2)/(b^2);
    
    % 创建掩码
    mask = ellipse <= 1;
    
    % 生成椭圆边界点
    t = linspace(0, 2*pi, 200);
    points = zeros(length(t), 2);
    
    for i = 1:length(t)
        % 参数方程
        x = a * cos(t(i));
        y = b * sin(t(i));
        
        % 旋转
        xr = x * cos(-angle) - y * sin(-angle);
        yr = x * sin(-angle) + y * cos(-angle);
        
        % 平移回中心
        points(i, 1) = xr + centerX;
        points(i, 2) = yr + centerY;
    end
end
