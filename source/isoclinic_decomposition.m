function [Q_l, Q_r] = isoclinic_decomposition(A)
    
    % see wiki page:
    % https://en.wikipedia.org/wiki/Rotations_in_4-dimensional_Euclidean_space

    M = zeros(size(A));
    M(1, 1) = A(1, 1) + A(2, 2) + A(3, 3) + A(4, 4);
    M(1, 2) = A(2, 1) - A(1, 2) - A(4, 3) + A(3, 4);
    M(1, 3) = A(3, 1) + A(4, 2) - A(1, 3) - A(2, 4);
    M(1, 4) = A(4, 1) - A(3, 2) + A(2, 3) - A(1, 4);
    
    M(2, 1) = A(2, 1) - A(1, 2) + A(4, 3) - A(3, 4);
    M(2, 2) =-A(1, 1) - A(2, 2) + A(3, 3) + A(4, 4);
    M(2, 3) = A(4, 1) - A(3, 2) - A(2, 3) + A(1, 4);
    M(2, 4) =-A(3, 1) - A(4, 2) - A(1, 3) - A(2, 4);
    
    M(3, 1) = A(3, 1) - A(4, 2) - A(1, 3) + A(2, 4);
    M(3, 2) =-A(4, 1) - A(3, 2) - A(2, 3) - A(1, 4);
    M(3, 3) =-A(1, 1) + A(2, 2) - A(3, 3) + A(4, 4);
    M(3, 4) = A(2, 1) + A(1, 2) - A(4, 3) - A(3, 4);
    
    M(4, 1) = A(4, 1) + A(3, 2) - A(2, 3) - A(1, 4);
    M(4, 2) = A(3, 1) - A(4, 2) + A(1, 3) - A(2, 4);
    M(4, 3) =-A(2, 1) - A(1, 2) - A(4, 3) - A(3, 4);
    M(4, 4) =-A(1, 1) + A(2, 2) + A(3, 3) - A(4, 4);
    
    M = M / 4;
    
    temp1 = M(:, 1)/sqrt(M(:, 1)'*M(:, 1));
    Q_l = [temp1(1), - temp1(2), - temp1(3), - temp1(4); ...
           temp1(2),   temp1(1), - temp1(4),   temp1(3); ...
           temp1(3),   temp1(4),   temp1(1), - temp1(2); ...
           temp1(4), - temp1(3),   temp1(2),   temp1(1)];
       
    temp2 = M(1, :)/sqrt(M(1, :)*M(1, :)');
    Q_r = [temp2(1), - temp2(2), - temp2(3), - temp2(4); ...
           temp2(2),   temp2(1),   temp2(4), - temp2(3); ...
           temp2(3), - temp2(4),   temp2(1),   temp2(2); ...
           temp2(4),   temp2(3), - temp2(2),   temp2(1)];
       
    if sum(sum(abs(Q_l * Q_r - A))) > 1e-10
        Q_l = - Q_l;
    end
    
       
       
    