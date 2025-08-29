% GTBinary: 前景的二值图
% GT: 椭圆真值的参数矩阵：每行一个椭圆：cx,cy,a,b,theta(angle)
function [] = displayEllipses(GTBinary, GT, res, save)

figure;

% 创建RGB图像
overlayImg = zeros([size(GTBinary), 3]);
overlayImg(:,:,1) = double(GTBinary);           % 真值
overlayImg(:,:,2) = double(GTBinary);           % 真值
overlayImg(:,:,3) = double(GTBinary);           % 真值
overlayImg(:,:,2) = overlayImg(:,:,2) - double(GTBinary & res.segFilledBinary) * 0.2;
overlayImg(:,:,3) = overlayImg(:,:,3) - double(GTBinary & res.segFilledBinary) * 0.1;

imshow(overlayImg);
axis off; % 关闭坐标轴和边框
hold on;

% 用圆标记真值中心
% if GT
%     for j = 1:size(GT,1)
%         C = [GT(j,1), GT(j,2)];
%         a = GT(j,3);
%         b = GT(j,4);
%         phi = deg2rad(GT(j,5));
% 
%         plot(C(1), C(2), 'r+', 'MarkerSize', 8, 'LineWidth', 2);
%     end
% end

% 画出所有拟合椭圆，并用圆圈标记估计的中心
for j = 1:length(res.segElls)
    for k = 1:length(res.segElls(j).ELs)
        a = res.segElls(j).ELs(k).a;
        b = res.segElls(j).ELs(k).b;
        C = [res.segElls(j).ELs(k).cx, res.segElls(j).ELs(k).cy];
        phi = -res.segElls(j).ELs(k).phi;

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

        plot(x_final, y_final, 'b-', 'LineWidth', 2);
    end
end

hold off;

if ~isempty(save)
    % imwrite(overlayImg, sprintf("%s_RFOVE_%s_coverage.tiff", save, res.method))
    exportgraphics(gcf, sprintf("%s%s_fittings.tiff", save, res.name), 'Resolution', 300);
end

end