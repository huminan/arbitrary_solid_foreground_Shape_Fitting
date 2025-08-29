function displayImages(GT, toElli, GTLabels, toElliLabels)
    % 显示图像
    % 参数:
    %   GT: 真值二值图像
    %   toElli: 椭圆拟合结果二值图像
    %   GTLabels: 真值标签图像
    %   toElliLabels: 椭圆拟合结果标签图像
    
    figure('Position', [100, 100, 1000, 500]);
    
    % 显示真值图像
    subplot(2, 3, 1);
    imshow(GT);
    title('真值二值图像');
    
    % 显示拟合结果图像
    subplot(2, 3, 2);
    imshow(toElli);
    title('椭圆拟合结果二值图像');
    
    % 显示重叠图像
    subplot(2, 3, 3);
    overlapImg = cat(3, double(GT), double(toElli), zeros(size(GT)));
    imshow(overlapImg);
    title('重叠图像 (红=真值, 绿=拟合)');
    
    % 显示真值标签图像
    subplot(2, 3, 4);
    imshow(label2rgb(GTLabels, 'jet', 'k', 'shuffle'));
    title('真值标签图像');
    
    % 显示拟合结果标签图像
    subplot(2, 3, 5);
    imshow(label2rgb(toElliLabels, 'jet', 'k', 'shuffle'));
    title('椭圆拟合结果标签图像');
    
    % 显示边界图像
    subplot(2, 3, 6);
    GTBorder = getBorderLabel(GTLabels) > 0;
    toElliBorder = getBorderLabel(toElliLabels) > 0;
    borderImg = cat(3, double(GTBorder), double(toElliBorder), zeros(size(GTBorder)));
    imshow(borderImg);
    title('边界图像 (红=真值边界, 绿=拟合边界)');
end