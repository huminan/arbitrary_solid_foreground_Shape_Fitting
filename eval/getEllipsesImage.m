function [segElls, segFilledBinary, segFilledLabels, numEllipses] = getEllipsesImage(segElls, sz, is_RFOVE)
% segFilledBinary：整个图像所有拟合椭圆的并集
% segFilledLabels：对segFilledBinary每个像素编号（没用）
% Iells: 单个轮廓拟合椭圆的并集图
% IContour：单个轮廓对象
% numEllipses：所有椭圆数量

numEllipses = 0;
segFilledBinary = false(sz);
segFilledLabels = zeros(sz);
for contour_id = 1:length(segElls)

    singleContourSegElls = false(sz);

    for ell_id = 1:length(segElls(contour_id).ELs)
        numEllipses = numEllipses + 1;

        [mask, ~] = generateEllipse(size(segFilledLabels), segElls(contour_id).ELs(ell_id));
        segFilledBinary = segFilledBinary | mask;
        singleContourSegElls = singleContourSegElls | mask;
        segFilledLabels(mask) = numEllipses;
        
    end

    segElls(contour_id).Iells = singleContourSegElls;

    % 填充contour并转为logical矩阵
    if ~is_RFOVE
        segElls(contour_id).IContour = getFilled(segElls(contour_id).IContour);
    end
    segElls(contour_id).IContour = logical(segElls(contour_id).IContour);
end

end

