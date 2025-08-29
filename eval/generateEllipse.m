function [mask, points] = generateEllipse(imageSize, params)
    % 生成椭圆
    % 参数:
    %   imageSize: 图像大小 [height, width]
    %   params: 椭圆参数 [centerX, centerY, a, b, angle]
    % 返回:
    %   mask: 椭圆二值掩码
    %   points: 椭圆边界点
    
    %centerX = params(1);
    %centerY = params(2);
    %a = params(3);
    %b = params(4);
    %angle = -params(5);% * pi/180;  % 转换为弧度
    
    centerX = params.cx;
    centerY = params.cy;
    a = params.a;
    b = params.b;
    angle = -params.phi;

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