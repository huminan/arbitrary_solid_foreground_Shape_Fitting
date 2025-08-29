function saveResults(shapeMetrics, ellipseMetrics, contourMetrics, output_path)
    % 保存评估结果到文件
    % 参数:
    %   shapeMetrics: 形状指标结构体
    %   ellipseMetrics: 椭圆指标结构体
    %   contourMetrics: 轮廓指标结构体
    %   output_path: 输出文件路径
    
    % 创建一个包含所有指标的结构体
    results = struct();
    results.shapeMetrics = shapeMetrics;
    results.ellipseMetrics = ellipseMetrics;
    results.contourMetrics = contourMetrics;
    
    % 计算总体评估结果
    results.precisionScore = (ellipseMetrics.PPV + contourMetrics.JSC) / 2;
    results.recallScore = (ellipseMetrics.TPR + (1-shapeMetrics.DiceFN)) / 2;
    results.overallScore = (results.precisionScore + results.recallScore) / 2;
    
    % 保存为MAT文件
    save(output_path, 'results');
    
    % 也生成一个文本报告
    [filepath, name, ~] = fileparts(output_path);
    txtFilePath = fullfile(filepath, [name, '.txt']);
    
    fid = fopen(txtFilePath, 'w');
    if fid ~= -1
        fprintf(fid, '椭圆拟合评估结果报告\n');
        fprintf(fid, '生成时间: %s\n\n', datestr(now));
        
        fprintf(fid, '形状指标:\n');
        fprintf(fid, '  形状覆盖率 (αE): %.4f (%.2f%%)\n', shapeMetrics.coverageRate, shapeMetrics.coverageRate*100);
        fprintf(fid, '  AIC: %.4f\n', shapeMetrics.AIC);
        fprintf(fid, '  Dice假阳性 (FP): %.4f\n', shapeMetrics.DiceFP);
        fprintf(fid, '  Dice假阴性 (FN): %.4f\n', shapeMetrics.DiceFN);
        fprintf(fid, '  椭圆数量 (k): %d\n\n', shapeMetrics.numEllipses);
        
        fprintf(fid, '椭圆指标:\n');
        fprintf(fid, '  真阳性率 (TPR): %.4f (%.2f%%)\n', ellipseMetrics.TPR, ellipseMetrics.TPR*100);
        fprintf(fid, '  阳性预测值 (PPV): %.4f (%.2f%%)\n', ellipseMetrics.PPV, ellipseMetrics.PPV*100);
        fprintf(fid, '  平均杰卡德相似系数 (AJSC): %.4f (%.2f%%)\n', ellipseMetrics.AJSC, ellipseMetrics.AJSC*100);
        fprintf(fid, '  平均距离 (AD): %.4f 像素\n', ellipseMetrics.AD);
        fprintf(fid, '  边界位移误差 (BDE): %.4f 像素\n', ellipseMetrics.BDE);
        fprintf(fid, '  TP: %d, FP: %d, FN: %d\n\n', ellipseMetrics.TP, ellipseMetrics.FP, ellipseMetrics.FN);
        
        fprintf(fid, '轮廓指标:\n');
        fprintf(fid, '  JSC: %.4f (%.2f%%)\n', contourMetrics.JSC, contourMetrics.JSC*100);
        fprintf(fid, '  平均绝对轮廓距离 (MAD): %.4f 像素\n', contourMetrics.MAD);
        fprintf(fid, '  Hausdorff距离: %.4f 像素\n\n', contourMetrics.HausdorffDist);
        
        fprintf(fid, '总体评估结果:\n');
        fprintf(fid, '  精确性（Precision）: %.4f (%.2f%%)\n', results.precisionScore, results.precisionScore*100);
        fprintf(fid, '  召回率（Recall）: %.4f (%.2f%%)\n', results.recallScore, results.recallScore*100);
        fprintf(fid, '  总体得分: %.4f (%.2f%%)\n', results.overallScore, results.overallScore*100);
        
        fclose(fid);
        fprintf('文本报告已保存到: %s\n', txtFilePath);
    end
    
    fprintf('结果已保存到: %s\n', output_path);
    
    % 生成Excel报告
    try
        xlsFilePath = fullfile(filepath, [name, '.xlsx']);
        
        % 创建表格数据
        shapeData = {'指标', '值', '百分比';
                    '形状覆盖率 (αE)', shapeMetrics.coverageRate, shapeMetrics.coverageRate*100;
                    'AIC', shapeMetrics.AIC, '';
                    'Dice假阳性 (FP)', shapeMetrics.DiceFP, shapeMetrics.DiceFP*100;
                    'Dice假阴性 (FN)', shapeMetrics.DiceFN, shapeMetrics.DiceFN*100;
                    '椭圆数量 (k)', shapeMetrics.numEllipses, ''};
        
        ellipseData = {'指标', '值', '百分比';
                    '真阳性率 (TPR)', ellipseMetrics.TPR, ellipseMetrics.TPR*100;
                    '阳性预测值 (PPV)', ellipseMetrics.PPV, ellipseMetrics.PPV*100;
                    '平均杰卡德相似系数 (AJSC)', ellipseMetrics.AJSC, ellipseMetrics.AJSC*100;
                    '平均距离 (AD)', ellipseMetrics.AD, '';
                    '边界位移误差 (BDE)', ellipseMetrics.BDE, '';
                    '真阳性 (TP)', ellipseMetrics.TP, '';
                    '假阳性 (FP)', ellipseMetrics.FP, '';
                    '假阴性 (FN)', ellipseMetrics.FN, ''};
        
        contourData = {'指标', '值', '百分比';
                    'JSC', contourMetrics.JSC, contourMetrics.JSC*100;
                    '平均绝对轮廓距离 (MAD)', contourMetrics.MAD, '';
                    'Hausdorff距离', contourMetrics.HausdorffDist, ''};
        
        overallData = {'指标', '值', '百分比';
                    '精确性（Precision）', results.precisionScore, results.precisionScore*100;
                    '召回率（Recall）', results.recallScore, results.recallScore*100;
                    '总体得分', results.overallScore, results.overallScore*100};
        
        % 写入Excel文件
        writecell(shapeData, xlsFilePath, 'Sheet', '形状指标');
        writecell(ellipseData, xlsFilePath, 'Sheet', '椭圆指标');
        writecell(contourData, xlsFilePath, 'Sheet', '轮廓指标');
        writecell(overallData, xlsFilePath, 'Sheet', '总体评估');
        
        fprintf('Excel报告已保存到: %s\n', xlsFilePath);
    catch
        fprintf('无法生成Excel报告。请确保您的MATLAB版本支持writecell函数，或者已安装相关工具箱。\n');
    end
    
    % 尝试生成HTML报告
    try
        htmlFilePath = fullfile(filepath, [name, '.html']);
        
        fid = fopen(htmlFilePath, 'w');
        if fid ~= -1
            fprintf(fid, '<!DOCTYPE html>\n');
            fprintf(fid, '<html>\n');
            fprintf(fid, '<head>\n');
            fprintf(fid, '<title>椭圆拟合评估结果报告</title>\n');
            fprintf(fid, '<style>\n');
            fprintf(fid, 'body { font-family: Arial, sans-serif; margin: 20px; }\n');
            fprintf(fid, 'h1 { color: #2c3e50; }\n');
            fprintf(fid, 'h2 { color: #3498db; }\n');
            fprintf(fid, 'table { border-collapse: collapse; width: 60%%; margin-bottom: 20px; }\n');
            fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n');
            fprintf(fid, 'th { background-color: #f2f2f2; }\n');
            fprintf(fid, 'tr:nth-child(even) { background-color: #f9f9f9; }\n');
            fprintf(fid, '.highlight { background-color: #e6f7ff; font-weight: bold; }\n');
            fprintf(fid, '</style>\n');
            fprintf(fid, '</head>\n');
            fprintf(fid, '<body>\n');
            
            fprintf(fid, '<h1>椭圆拟合评估结果报告</h1>\n');
            fprintf(fid, '<p>生成时间: %s</p>\n', datestr(now));
            
            % 形状指标表格
            fprintf(fid, '<h2>形状指标</h2>\n');
            fprintf(fid, '<table>\n');
            fprintf(fid, '<tr><th>指标</th><th>值</th><th>百分比</th></tr>\n');
            fprintf(fid, '<tr><td>形状覆盖率 (αE)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', shapeMetrics.coverageRate, shapeMetrics.coverageRate*100);
            fprintf(fid, '<tr><td>AIC</td><td>%.4f</td><td>-</td></tr>\n', shapeMetrics.AIC);
            fprintf(fid, '<tr><td>Dice假阳性 (FP)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', shapeMetrics.DiceFP, shapeMetrics.DiceFP*100);
            fprintf(fid, '<tr><td>Dice假阴性 (FN)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', shapeMetrics.DiceFN, shapeMetrics.DiceFN*100);
            fprintf(fid, '<tr><td>椭圆数量 (k)</td><td>%d</td><td>-</td></tr>\n', shapeMetrics.numEllipses);
            fprintf(fid, '</table>\n');
            
            % 椭圆指标表格
            fprintf(fid, '<h2>椭圆指标</h2>\n');
            fprintf(fid, '<table>\n');
            fprintf(fid, '<tr><th>指标</th><th>值</th><th>百分比</th></tr>\n');
            fprintf(fid, '<tr><td>真阳性率 (TPR)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', ellipseMetrics.TPR, ellipseMetrics.TPR*100);
            fprintf(fid, '<tr><td>阳性预测值 (PPV)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', ellipseMetrics.PPV, ellipseMetrics.PPV*100);
            fprintf(fid, '<tr><td>平均杰卡德相似系数 (AJSC)</td><td>%.4f</td><td>%.2f%%</td></tr>\n', ellipseMetrics.AJSC, ellipseMetrics.AJSC*100);
            fprintf(fid, '<tr><td>平均距离 (AD)</td><td>%.4f</td><td>-</td></tr>\n', ellipseMetrics.AD);
            fprintf(fid, '<tr><td>边界位移误差 (BDE)</td><td>%.4f</td><td>-</td></tr>\n', ellipseMetrics.BDE);
            fprintf(fid, '<tr><td>真阳性 (TP)</td><td>%d</td><td>-</td></tr>\n', ellipseMetrics.TP);
            fprintf(fid, '<tr><td>假阳性 (FP)</td><td>%d</td><td>-</td></tr>\n', ellipseMetrics.FP);
            fprintf(fid, '<tr><td>假阴性 (FN)</td><td>%d</td><td>-</td></tr>\n', ellipseMetrics.FN);
            fprintf(fid, '</table>\n');
            
            % 轮廓指标表格
            fprintf(fid, '<h2>轮廓指标</h2>\n');
            fprintf(fid, '<table>\n');
            fprintf(fid, '<tr><th>指标</th><th>值</th><th>百分比</th></tr>\n');
            fprintf(fid, '<tr><td>JSC</td><td>%.4f</td><td>%.2f%%</td></tr>\n', contourMetrics.JSC, contourMetrics.JSC*100);
            fprintf(fid, '<tr><td>平均绝对轮廓距离 (MAD)</td><td>%.4f</td><td>-</td></tr>\n', contourMetrics.MAD);
            fprintf(fid, '<tr><td>Hausdorff距离</td><td>%.4f</td><td>-</td></tr>\n', contourMetrics.HausdorffDist);
            fprintf(fid, '</table>\n');
            
            % 总体评估表格
            fprintf(fid, '<h2>总体评估结果</h2>\n');
            fprintf(fid, '<table>\n');
            fprintf(fid, '<tr><th>指标</th><th>值</th><th>百分比</th></tr>\n');
            fprintf(fid, '<tr class="highlight"><td>精确性（Precision）</td><td>%.4f</td><td>%.2f%%</td></tr>\n', results.precisionScore, results.precisionScore*100);
            fprintf(fid, '<tr class="highlight"><td>召回率（Recall）</td><td>%.4f</td><td>%.2f%%</td></tr>\n', results.recallScore, results.recallScore*100);
            fprintf(fid, '<tr class="highlight"><td>总体得分</td><td>%.4f</td><td>%.2f%%</td></tr>\n', results.overallScore, results.overallScore*100);
            fprintf(fid, '</table>\n');
            
            fprintf(fid, '</body>\n');
            fprintf(fid, '</html>\n');
            
            fclose(fid);
            fprintf('HTML报告已保存到: %s\n', htmlFilePath);
        end
    catch
        fprintf('无法生成HTML报告。\n');
    end
end