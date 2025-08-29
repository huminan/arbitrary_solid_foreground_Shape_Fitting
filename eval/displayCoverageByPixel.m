% GTBinary: 前景的二值图
% GT: 椭圆真值的参数矩阵：每行一个椭圆：cx,cy,a,b,theta(angle)
function [] = displayCoverageByPixel(GTBinary, GT, segElls, segBinary, RFOVE_res, save)

N_methods = length(RFOVE_res);

%% RFOVE
for i = 1:N_methods
    figure;

    % 创建RGB图像
    overlayImg = zeros([size(GTBinary), 3]);
    overlayImg(:,:,1) = double(GTBinary) * 0.8;           % 红色通道用于真值
    overlayImg(:,:,2) = double(RFOVE_res(i).segFilledBinary) * 0.8;       % 绿色通道用于拟合结果
    overlayImg(:,:,3) = double(GTBinary & RFOVE_res(i).segFilledBinary) * 0.9;  % 蓝色通道用于交集

    imshow(overlayImg);
    axis off; % 关闭坐标轴和边框
    hold on;

    % 用圆标记真值中心
    if GT
        for j = 1:size(GT,1)
            C = [GT(j,1), GT(j,2)];
            a = GT(j,3);
            b = GT(j,4);
            phi = deg2rad(GT(j,5));
    
            plot(C(1), C(2), 'r+', 'MarkerSize', 8, 'LineWidth', 2);
        end
    end

    % 画出所有拟合椭圆，并用圆圈标记估计的中心
    for j = 1:length(RFOVE_res(i).segElls)
        for k = 1:length(RFOVE_res(i).segElls(j).EL)
            a = RFOVE_res(i).segElls(j).EL(k).a;
            b = RFOVE_res(i).segElls(j).EL(k).b;
            C = RFOVE_res(i).segElls(j).EL(k).C;
            phi = -RFOVE_res(i).segElls(j).EL(k).phi;
    
            theta = linspace(0, 2*pi, 200);
            
            % 椭圆的参数方程（未旋转）
            x = a * cos(theta);
            y = b * sin(theta);
            
            % 旋转椭圆
            x_rotated = x * cos(phi) - y * sin(phi);
            y_rotated = x * sin(phi) + y * cos(phi);
            
            % 平移椭圆到中心 C
            x_final = round(x_rotated + C(1)); % 取整并平移
            y_final = round(y_rotated + C(2)); % 取整并平移

            plot(x_final, y_final, 'b-', 'LineWidth', 1);
            plot(C(1), C(2), 'bo', 'MarkerSize', 10);
        end
    end
    
    hold off;

    if ~isempty(save)
        % imwrite(overlayImg, sprintf("%s_RFOVE_%s_coverage.tiff", save, RFOVE_res(i).method))
        exportgraphics(gcf, sprintf("%s_RFOVE_%s_coverage.tiff", save, RFOVE_res(i).method), 'Resolution', 300);
    end
end

%% CFE
figure;

% 创建RGB图像
overlayImg = zeros([size(GTBinary), 3]);
overlayImg(:,:,1) = double(GTBinary) * 0.8;           % 红色通道用于真值
overlayImg(:,:,2) = double(segBinary) * 0.8;       % 绿色通道用于拟合结果
overlayImg(:,:,3) = double(GTBinary & segBinary) * 0.9;  % 蓝色通道用于交集

imshow(overlayImg);
axis off; % 关闭坐标轴和边框
hold on;

% 用圆标记真值中心
if GT
    for j = 1:size(GT,1)
        C = [GT(j,1), GT(j,2)];
        a = GT(j,3);
        b = GT(j,4);
        phi = deg2rad(GT(j,5));
    
        plot(C(1), C(2), 'r+', 'MarkerSize', 8, 'LineWidth', 2);
    end
end

% 画出所有拟合椭圆
for j = 1:length(segElls)
    for k = 1:length(segElls(j).ELs)
        a = segElls(j).ELs(k).a;
        b = segElls(j).ELs(k).b;
        C = [segElls(j).ELs(k).cx, segElls(j).ELs(k).cy];
        phi = -segElls(j).ELs(k).phi;

        theta = linspace(0, 2*pi, 200);
        
        % 椭圆的参数方程（未旋转）
        x = a * cos(theta);
        y = b * sin(theta);
        
        % 旋转椭圆
        x_rotated = x * cos(phi) - y * sin(phi);
        y_rotated = x * sin(phi) + y * cos(phi);
        
        % 平移椭圆到中心 C
        x_final = round(x_rotated + C(1)); % 取整并平移
        y_final = round(y_rotated + C(2)); % 取整并平移
        
        plot(x_final, y_final, 'b-', 'LineWidth', 1);
        plot(C(1), C(2), 'bo', 'MarkerSize', 10);
    end
end

hold off;

if ~isempty(save)
    exportgraphics(gcf, sprintf("%s_CFE_coverage.tiff", save), 'Resolution', 300);
%     imwrite(overlayImg, sprintf("%s_CFE_coverage.tiff", save)) %     只会保存矩阵，而不是图像
end

end