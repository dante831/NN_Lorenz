function [Z_max, X] = find_max_z(prediction)

    % calculate consecutive maximums of z
    if length(unique(prediction(3, :))) ~= length(prediction(3, :))
        disp('Warning, non-unique values in Z')
    end
    dZ = diff(prediction(3, :));
    ind = 1 + find(dZ(1:end-1) >= 0 & dZ(2:end) <= 0);
    Z_max = prediction(3, ind);
    X = prediction(1, ind);

end