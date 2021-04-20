function [Lambda_ode, Lambda_nn] = FTLE_calculation(net, dt, ...
    D_raw, D_NN, Nt, Np, plot_path, PLOT_FTLE)

    % for reference, see 
    % http://shaddenlab.berkeley.edu/uploads/LCS-tutorial/computation.html

    % sample from D_raw, which is a representation of the attractor
    rng(5);
    center_points_ODE = D_raw(1:3, randsample(length(D_raw(1, :)), Np)); 
    center_points_NN = D_NN(1:3, knnsearch(D_NN(1:3, :)', center_points_ODE'));

    [Lambda_nn, Lambda_ode] = deal(zeros(Np, 1));

    dx = 1e-9;
    n = 1;
    % create a 3D grid of points
    x = (- n : n) * 1 / n;
    N = 2*n+1;
    [X, Y, Z] = ndgrid(x * dx, ...
                       x * dx, ...
                       x * dx);

    [start_points_ODE, start_points_NN] = deal(zeros(3, N^3 * Np));
    for p = 1 : Np
        start_points_ODE(:, N^3 * (p - 1) + 1 : N^3 * p) = ...
                [X(:)' + center_points_ODE(1, p); ...
                 Y(:)' + center_points_ODE(2, p); ...
                 Z(:)' + center_points_ODE(3, p)];
        start_points_NN(:, N^3 * (p - 1) + 1 : N^3 * p) = ...
                [X(:)' + center_points_NN(1, p); ...
                 Y(:)' + center_points_NN(2, p); ...
                 Z(:)' + center_points_NN(3, p)];
    end
    %{
    scatter3(center_points_ODE(1, :), center_points_ODE(2, :), center_points_ODE(3, :))
    hold on
    scatter3(center_points_NN(1, :), center_points_NN(2, :), center_points_NN(3, :))
    %}
    % forward propagate NN and ODE
    full_ode = start_points_ODE;
    full_nn = start_points_NN;
    for t = 1 : Nt
        if mod(t, 100) == 0; disp(t); end
        full_nn = net(full_nn);
    end
    parfor i = 1 : length(full_ode(1, :))
        if mod(i, 1000) == 0; disp(num2str(i)); end
        [~, temp] = lorenz_synthetic(full_ode(:, i), Nt + 1, dt);
        full_ode(:, i) = temp(end, :)';
    end

    for p = 1 : Np    

        % use central difference to calculate finite-time Lyapunov Exponent. The 
        % boundary points are approximated using one-sided finite difference
        start = start_points_ODE(:, N^3 * (p - 1) + 1 : N^3 * p);
        X1_nn  = full_nn (:, N^3 * (p - 1) + 1 : N^3 * p);
        X1_ode = full_ode(:, N^3 * (p - 1) + 1 : N^3 * p);

        [temp_Lambda_nn, temp_Lambda_ode] = deal(zeros(length(start), 1));
        [Ni, Nj, Nk] = deal(N);

        Nij = Ni * Nj;

        for i = 1 : Ni
            for j = 1 : Nj
                for k = 1 : Nk
                    ijk_m = (k - 1)        * Nij + (j - 1)        * Nj + i;     % middle
                    ijk_l = (k - 1)        * Nij + (j - 1)        * Nj + max(i - 1, 1); % left
                    ijk_r = (k - 1)        * Nij + (j - 1)        * Nj + min(i + 1, Ni);% right
                    ijk_f = (k - 1)        * Nij + min(j, Nj - 1) * Nj + i;             % front
                    ijk_b = (k - 1)        * Nij + max(j - 2, 0)  * Nj + i;             % back
                    ijk_u = min(k, Nk - 1) * Nij + (j - 1)        * Nj + i;             % up
                    ijk_d = max(k - 2, 0)  * Nij + (j - 1)        * Nj + i;             % down
                    Jacobian_ode = [(X1_ode(:, ijk_r) - X1_ode(:, ijk_l)) / (start(1, ijk_r) - start(1, ijk_l)), ...
                                    (X1_ode(:, ijk_f) - X1_ode(:, ijk_b)) / (start(2, ijk_f) - start(2, ijk_b)), ...
                                    (X1_ode(:, ijk_u) - X1_ode(:, ijk_d)) / (start(3, ijk_u) - start(3, ijk_d))];
                    % divide by two because the egenvalue of Jacobian'*Jacobian is
                    % squared
                    temp_Lambda_ode(ijk_m) = lyapunov_exponent(Jacobian_ode' * Jacobian_ode, Nt*dt) / 2;
                    %clear('Jacobian_ode');
                    Jacobian_nn  = [(X1_nn (:, ijk_r) - X1_nn (:, ijk_l)) / (start (1, ijk_r) - start (1, ijk_l)), ...
                                    (X1_nn (:, ijk_f) - X1_nn (:, ijk_b)) / (start (2, ijk_f) - start (2, ijk_b)), ...
                                    (X1_nn (:, ijk_u) - X1_nn (:, ijk_d)) / (start (3, ijk_u) - start (3, ijk_d))];
                    temp_Lambda_nn (ijk_m) = lyapunov_exponent(Jacobian_nn'  * Jacobian_nn , Nt*dt) / 2;
                    %clear('Jacobian_nn');
                end
            end
        end
        temp_ind = sub2ind(size(X), n+1, n+1, n+1);
        Lambda_nn (p) = temp_Lambda_nn (temp_ind);
        Lambda_ode(p) = temp_Lambda_ode(temp_ind);
    end

    %{
    if PLOT_FTLE
        min_x = -2;
        max_x = 14;
        figure('pos', [10 10 300 280])
        hold on
        grid on
        title(['Nt = ', num2str(Nt)])
        scatter(Lambda_ode, Lambda_nn, 10, 'filled')
        plot(min_x:max_x, min_x:max_x, '--')
        axis([min_x, max_x, min_x, max_x])
        set(gca, 'xtick', min_x:2:max_x)
        set(gca, 'ytick', min_x:2:max_x)
        xlabel('ODE')
        ylabel('NN')
        hold off
        saveas(gca, [plot_path, 'FTLE_Nt=', num2str(Nt)], 'png')
    end
    %}

    disp(['the average FTLE of ODE = ', num2str(mean(Lambda_ode))])
    disp(['the average FTLE of NN = ', num2str(mean(Lambda_nn))])

end



