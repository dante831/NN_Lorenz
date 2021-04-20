function lambda = lyapunov_exponent(L, dt)
    [~, S_L, ~] = svd(L);
    %lambda = log(S_L(1, 1)) / dt;
    lambda = log(max(diag(S_L))) / dt;
end