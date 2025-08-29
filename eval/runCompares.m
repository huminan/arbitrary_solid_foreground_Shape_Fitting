clear;
clc;

methods = ["DTECMA"];

datasets = ["NIH3T3", "synth", "my", "SISHA"];

fileTypes = [".jpg", ".png", ".bmp", ".tif", ".jpeg"];

dir_ids = [1,2,3,4];
fnames = {["dna-0-0"] ...
          ["synthetic", "round2.2", "round2.3", "round3"] ...
          ["jianying1", "shape1", "man"]...
          ["SISHA_28"]};

savepath = 'res/';
colNames = [];

% 真值的椭圆文件用同名xlsx
% 参数矩阵：每行一个椭圆：cx,cy,a,b,theta(angle)

for dir_id = dir_ids

    averageEvaluation = containers.Map();

for fname = fnames{dir_id} 

    cmpRes = {};

    GTElls = [];
    if isfile(sprintf("../test_img/%s.xlsx", fname))
        GTElls = readmatrix(sprintf("../test_img/%s.xlsx", fname));
    end

    folder = sprintf("../test_img");

    imageName = "";
    for k = 1:length(fileTypes)
        imName = dir(fullfile(folder, sprintf("%s%s", fname, fileTypes(k))));
        if ~isempty(imName)
            imageName = imName.name;
            break;
        end
    end


    if isempty(imageName)
        error("未找到前景图像'%s'", folder);
    end

    imageFile = fullfile(folder, imageName);
    GTFilled = imread(imageFile);
    if ndims(GTFilled) == 3
        GTFilled = rgb2gray(GTFilled);
    end
    GTFilled = imbinarize(GTFilled);
    GTBorderLabels = edge(GTFilled, 'Canny');


    cc = bwconncomp(GTFilled);
    stats = regionprops(cc, 'Area', 'Perimeter');
    area_values = arrayfun(@(x) x.Area, stats);
    peri_values = arrayfun(@(x) x.Perimeter, stats);
    area = sum(area_values);
    perimeter = sum(peri_values);


for midx = 1:length(methods)

    folderPath = sprintf("../test_img");
    methodStr = methods(midx);
    fileList = dir(fullfile(folderPath, sprintf('%s_%s*.mat', fname,  methodStr)));


for i = 1:length(fileList)


    resName = fileList(i).name;


    Res = load(fullfile(folderPath, resName));


    varSuffix = strrep(resName, '.mat', '');
    Res.name = string(varSuffix);   % <pic_name>_<method>_<param>
    varSuffix = strrep(varSuffix, sprintf('%s_', fname), '');
    Res.methodStr = string(varSuffix);  % <method>_<param>
    varSuffix = strrep(varSuffix, sprintf('%s_%s_res_', fname, methodStr), '');
    if length(varSuffix)==length(resName)
        Res.param = ''; % <param>
        if length(fileList) > 1
            error('not principle res name!'); %
        end
    else
        
        Res.method = varSuffix;
    end
    


    %Res.segTotalLabels = getBorderLabel(Res.segFilledLabels);


    [Res.segElls, Res.segFilledBinary, Res.segFilledLabels, Res.N_ells] = getEllipsesImage(Res.segElls, size(GTBorderLabels), true);


    Res.shapeMetrics = calculateShapeMetrics(Res.segElls, GTFilled, Res.segFilledBinary, Res.N_ells);
    Res.ellipseMetrics = calculateEllipseMetrics(GTFilled, GTElls, Res.segFilledLabels, Res.segElls, Res.N_ells);
    %Res.contourMetrics = calculateContourMetrics(GTBorderLabels, Res.segTotalLabels);

    cmpRes{end+1} = Res;

end % end res_param
end % end methods


    colNames = ["method", "Precision%(pixel)", "Recall%(pixel)", "F1%", "DiceFP%", "DiceFN%", ...
                "EllCnt", "Precision%(ell)", "Recall%(ell)", "AD", "AJSC%", ...
                "Time(ms)", "Area", "Perimeter" ];
    rowNames = strings(length(cmpRes),1);
    datas = zeros(length(cmpRes),length(colNames)-1);
    
    for i = 1:length(cmpRes)
        rowNames(i) = cmpRes{i}.methodStr;
        datas(i,:) = [cmpRes{i}.shapeMetrics.Precision*100, cmpRes{i}.shapeMetrics.Recall*100, cmpRes{i}.shapeMetrics.f1*100, ...
                      cmpRes{i}.shapeMetrics.DiceFP*100, cmpRes{i}.shapeMetrics.DiceFN*100, ...
                      cmpRes{i}.shapeMetrics.numEllipses, ...
                      cmpRes{i}.ellipseMetrics.TPR*100, cmpRes{i}.ellipseMetrics.PPV*100, ...
                      cmpRes{i}.ellipseMetrics.AD, cmpRes{i}.ellipseMetrics.AJSC*100, ...
                      cmpRes{i}.timeElapsed * 1000, area, perimeter
                      ];
    
        averageEvaluation = addEvaluation(averageEvaluation, cmpRes{i}, datasets(dir_id), area, perimeter);
    
    end
    T = table(rowNames, datas(:,1), datas(:,2), datas(:,3), datas(:,4), datas(:,5), ...
              datas(:,6), datas(:,7), datas(:,8), datas(:,9), datas(:,10), ...
              datas(:,11), datas(:,12), datas(:,13), ...
              'VariableNames', colNames);
    writetable(T, sprintf('%s%s_cmp.xlsx', savepath, datasets(dir_id)), 'Sheet', fname);
    

    for i = 1:length(cmpRes)
        %displayCoverage(GTFilled, GT, cmpRes{i}, '');
        %displayCoverage(GTFilled, GTElls, cmpRes{i}, savepath);
        displayEllipses(GTFilled, GTElls, cmpRes{i}, savepath);
    end

end % end fname

    methodsList = keys(averageEvaluation);
    rowNames = strings(length(methodsList),1);
    datas = zeros(length(methodsList),length(colNames)-1);
    
    for i = 1:length(methodsList)

        key = methodsList{i};
        vals = averageEvaluation(key);
        cnt = vals.cnt;
    
        rowNames(i) = key;
        datas(i,:) = [vals.Precision/cnt*100, vals.Recall/cnt*100, vals.f1/cnt*100, ...
                      vals.DiceFP/cnt*100, vals.DiceFN/cnt*100, ...
                      round(vals.numEllipses/cnt), ...
                      vals.TPR/cnt*100, vals.PPV/cnt*100, ...
                      vals.AD/cnt, vals.AJSC/cnt*100, ...
                      vals.timeElapsed /cnt * 1000, vals.area/cnt, vals.perimeter/cnt
                      ];
    end

    T = table(rowNames, datas(:,1), datas(:,2), datas(:,3), datas(:,4), datas(:,5), ...
              datas(:,6), datas(:,7), datas(:,8), datas(:,9), datas(:,10), ...
              datas(:,11), datas(:,12), datas(:,13), ...
              'VariableNames', colNames);
    writetable(T, sprintf('%s%s_cmp.xlsx', savepath, datasets(dir_id)), 'Sheet', 'average');


end % end datasets