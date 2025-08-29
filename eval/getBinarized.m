function A = getBinarized(B)
    A = zeros(size(B));
    for i = 1:size(B,1)
        for j = 1:size(B,2)
            if B(i,j) > 0
                A(i,j) = 1;
            end
        end
    end

end

