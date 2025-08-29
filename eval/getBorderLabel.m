function borderLabel = getBorderLabel(labelImage)
    % 从标签图像获取边界标签
    % 参数:
    %   labelImage: 标签图像
    % 返回:
    %   borderLabel: 边界标签图像
    
    % 创建结构元素
    se = strel('disk', 1);
    
    % 初始化边界标签图
    borderLabel = zeros(size(labelImage), 'like', labelImage);
    
    % 对每个标签生成边界
    for i = 1:max(labelImage(:))
        % 提取当前标签区域
        region = (labelImage == i);
        
        % 提取边界
        border = region & ~imerode(region, se);
        
        % 将标签赋值给边界
        borderLabel(border) = i;
    end
end