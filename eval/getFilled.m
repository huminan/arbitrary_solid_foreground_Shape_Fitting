function [Filled] = getFilled(Contour)

lines = size(Contour,1);
cols = size(Contour,2);

% GT0 是在Contour的图像边界加了围起来的一圈
GT0 = Contour;
for i=1:cols
    GT0(1,i) = 1;
end
for i=1:lines
    GT0(i,cols) = 1;
end
for i=1:cols
    GT0(lines,i) = 1;
end
GTH0 = imfill(GT0,'holes');

GT1 = Contour;
for i=1:cols
    GT1(1,i) = 1;
end
for i=1:lines
    GT1(i,1) = 1;
end
for i=1:cols
    GT1(lines,i) = 1;
end
GTH1 = imfill(GT1,'holes');
Filled = max(GTH0,GTH1);
Filled(Contour == 1) = 0;

for i=1:cols
    if Filled(2,i) == 0
        Filled(1,i) = 0;
    end
end
for i=1:lines
    if Filled(i,cols-1) == 0
        Filled(i,cols) = 0;
    end
end
for i=1:lines
    if Filled(i,2) == 0
        Filled(i,1) = 0;
    end
end
for i=1:cols
    if Filled(lines-1,i) == 0
        Filled(lines,i) = 0;
    end
end



end
