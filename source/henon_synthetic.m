function a = henon_synthetic(start, Nt)

    alpha = 1.4;
    beta = 0.3;
    a = zeros(Nt, 2);
    a(1, :) = start(:)';
    for i = 2 : Nt
        a(i, 1) = a(i - 1, 2) + 1 - alpha * a(i - 1, 1)^2;
        a(i, 2) = beta * a(i - 1, 1);
    end
