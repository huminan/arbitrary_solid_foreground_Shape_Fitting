function createEnhancedVisualization(GT, toElli, GTLabels, toElliLabels, GTBorderLabel, ClustBorderLabel, shapeMetrics, ellipseMetrics, contourMetrics)
    % 创建增强的可视化效果
    % 参数:
    %   GT: 真值二值图像
    %   toElli: 椭圆拟合结果二值图像
    %   GTLabels: 真值标签图像
    %   toElliLabels: 椭圆拟合结果标签图像
    %   ...各种指标
    
    % 创建一个新的大图形窗口
    figure('Position', [50, 50, 1200, 900], 'Name', '椭圆拟合评估可视化结果', 'Color', 'white');
    
    % 设置配色
    gtColor = [0.8500, 0.3250, 0.0980]; % 橙色
    estColor = [0, 0.4470, 0.7410];     % 蓝色
    
    % 1. 显示原始图像和标签图像
    subplot(3, 4, 1);
    imshow(GT);
    title('真值二值图像', 'FontSize', 12, 'FontWeight', 'bold');
    
    subplot(3, 4, 2);
    imshow(toElli);
    title('椭圆拟合结果二值图像', 'FontSize', 12, 'FontWeight', 'bold');
    
    subplot(3, 4, 5);
    imshow(label2rgb(GTLabels, 'jet', 'k', 'shuffle'));
    title('真值标签图像', 'FontSize', 12, 'FontWeight', 'bold');
    
    subplot(3, 4, 6);
    imshow(label2rgb(toElliLabels, 'jet', 'k', 'shuffle'));
    title('椭圆拟合结果标签图像', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 2. 显示重叠区域 - 带透明度的彩色可视化
    subplot(3, 4, [3, 4, 7, 8]);
    % 创建RGB图像
    overlayImg = zeros([size(GT), 3]);
    overlayImg(:,:,1) = double(GT) * 0.8;           % 红色通道用于真值
    overlayImg(:,:,2) = double(toElli) * 0.8;       % 绿色通道用于拟合结果
    overlayImg(:,:,3) = double(GT & toElli) * 0.9;  % 蓝色通道用于交集
    
    imshow(overlayImg);
    hold on;
    
    % 提取真值椭圆的中心点
    gtStats = regionprops(GTLabels, 'Centroid');
    estStats = regionprops(toElliLabels, 'Centroid');
    
    % 绘制真值椭圆中心
%     for i = 1:length(gtStats)
%         plot(gtStats(i).Centroid(1), gtStats(i).Centroid(2), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', gtColor, 'MarkerFaceColor', gtColor, 'LineWidth', 2);
%         text(gtStats(i).Centroid(1)+10, gtStats(i).Centroid(2), sprintf('GT-%d', i), 'Color', gtColor, 'FontSize', 10, 'FontWeight', 'bold');
%     end
    
    % 绘制拟合椭圆中心
%     for i = 1:length(estStats)
%         plot(estStats(i).Centroid(1), estStats(i).Centroid(2), 's', 'MarkerSize', 10, 'MarkerEdgeColor', estColor, 'MarkerFaceColor', estColor, 'LineWidth', 2);
%         text(estStats(i).Centroid(1)+10, estStats(i).Centroid(2), sprintf('Est-%d', i), 'Color', estColor, 'FontSize', 10, 'FontWeight', 'bold');
%     end
    
    % 绘制匹配线
%     threshold = 8; % 阈值
%     for i = 1:length(estStats)
%         for j = 1:length(gtStats)
%             dist = norm([estStats(i).Centroid(1) - gtStats(j).Centroid(1), estStats(i).Centroid(2) - gtStats(j).Centroid(2)]);
%             if dist <= threshold
%                 plot([estStats(i).Centroid(1), gtStats(j).Centroid(1)], [estStats(i).Centroid(2), gtStats(j).Centroid(2)], '--', 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2);
%             end
%         end
%     end
%     
%     title('椭圆匹配可视化结果 (红=真值, 绿=拟合, 蓝=交集)', 'FontSize', 12, 'FontWeight', 'bold');
%     legend('真值中心', '拟合中心', '匹配连线', 'Location', 'best');
    
    % 3. 显示边界轮廓
    subplot(3, 4, 9);
    % 创建边界图像
    borderImg = zeros([size(GT), 3]);
    borderImg(:,:,1) = double(GTBorderLabel > 0);      % 红色通道用于真值边界
    borderImg(:,:,2) = double(ClustBorderLabel > 0);   % 绿色通道用于拟合边界
    imshow(borderImg);
    title('边界轮廓 (红=真值边界, 绿=拟合边界)', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 4. 显示指标可视化 - 使用条形图和饼图
    % 形状指标饼图
    subplot(3, 4, 10);
    pieData = [shapeMetrics.coverageRate, 1-shapeMetrics.coverageRate];
    labels = {sprintf('覆盖率: %.2f%%', shapeMetrics.coverageRate*100), sprintf('未覆盖: %.2f%%', (1-shapeMetrics.coverageRate)*100)};
    pie(pieData, labels);
    title('形状覆盖情况', 'FontSize', 12, 'FontWeight', 'bold');
    colormap(gca, [0.4660, 0.6740, 0.1880; 0.6350, 0.0780, 0.1840]); % 绿色和红色
    
    % Dice指标条形图
    subplot(3, 4, 11);
    barData = [shapeMetrics.DiceFP, shapeMetrics.DiceFN];
    barh(barData);
    set(gca, 'YTick', 1:2, 'YTickLabel', {'Dice FP', 'Dice FN'});
    title('Dice假阳性和假阴性', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([0 1]);
    grid on;
    
    % 椭圆指标条形图
    subplot(3, 4, 12);
    barData = [ellipseMetrics.TPR, ellipseMetrics.PPV, ellipseMetrics.AJSC];
    bar(barData, 'FaceColor', [0.3010, 0.7450, 0.9330]);
    set(gca, 'XTick', 1:3, 'XTickLabel', {'TPR', 'PPV', 'AJSC'});
    title('椭圆匹配指标', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0 1]);
    grid on;
    
    % 添加额外的总体信息
    annotation('textbox', [0.02, 0.02, 0.96, 0.06], 'String', sprintf('评估总结: 真值椭圆=%d, 检测椭圆=%d, TP=%d, FP=%d, FN=%d, MAD=%.2f', ...
        max(GTLabels(:)), max(toElliLabels(:)), ellipseMetrics.TP, ellipseMetrics.FP, ellipseMetrics.FN, contourMetrics.MAD), ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end