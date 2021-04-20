function plot_trajectories(Nt, dt, Np, net, data, plot_path, str, x_threshold)

    % set random seed so that the same trajectories are selected each time
    rng(3);
    
    N_phase = 3;
    N_train = size(data, 2);

    % randomly select a small patch of points centered on the attractor
    %{
    %start2 = [8.0915, 3.0695, 32.1166]';
    start2 = D_Train(1:3, randsample(N_train, 1));
    %start2 = D(1 : N_p, randperm(length(D(1, :)), 1));
    
    % sample a group of points from a distribution centered around start2
    sigma = 0.1;
    pdx = makedist('normal', 'mu', 0, 'sigma', sigma);
    pdy = makedist('normal', 'mu', 0, 'sigma', sigma);
    pdz = makedist('normal', 'mu', 0, 'sigma', sigma);
    %}
    % randomly select points in the phase space from the training data
    
    startp = zeros(N_phase, Np);
    for n = 1 : Np
        %startp(:, n) = start2' + [random(pdx), random(pdy), random(pdz)];
        startp(:, n) = data(1:3, randsample(N_train, 1));
    end
    [prediction, D2] = deal(zeros(N_phase, Np, Nt));
    prediction(:, :, 1) = startp;

    % do predictions from NN
    for t = 2 : Nt
        if(mod(t, 100) == 0);disp(t);end
        prediction(:, :, t) = net(prediction(:, :, t - 1));
    end
    % do predictions from L63
    for n = 1 : Np
        [~, a2] = lorenz_synthetic(startp(:, n), Nt, dt);
        D2(:, n, :) = a2';
    end

    set(0,'DefaultFigureVisible','off');

    % 3D plot of the trajectory labeled d
    for d = 1 : Np
        
        fig = figure('pos', [10, 10, 240, 210]);
        hold on
        grid on
        N_plot = min(4000, Nt);
        
        plot3(squeeze(D2(1, d, 1 : N_plot)), squeeze(D2(2, d, 1 : N_plot)), ...
                squeeze(D2(3, d, 1 : N_plot)), ...
                'linewidth', 1);
        plot3(squeeze(prediction(1, d, 1 : N_plot)), ...
                squeeze(prediction(2, d, 1 : N_plot)), ...
                squeeze(prediction(3, d, 1 : N_plot)), ...
                'linewidth', 1, 'linestyle', '--');
        scatter3(startp(1, d), startp(2, d), startp(3, d), 'o', 'red', 'filled')

        view(20, 30)
        xlabel('X', 'interpreter', 'latex')
        ylabel('Y', 'interpreter', 'latex')
        zlabel('Z', 'interpreter', 'latex')
        zticks([0, 10, 20, 30, 40, 50])
        set(gca, 'TickLabelInterpreter', 'latex')
        %title(plot_title)
        axis([-21, 21, -26, 26, -1, 51])
        if x_threshold < 20
            [Y, Z] = meshgrid(-25:25, 0:50);
            surf(-5*ones(size(Y)), Y, Z, 'Linestyle', 'none', ...
                    'facecolor', [0, 0, 0], 'FaceAlpha', 0.6)
        end
        legend({'L63', 'NN', 'start'}, 'location', 'best', 'interpreter', 'latex')
        hold off
        
        figname = fullfile(plot_path, ['NN_predictions_3D_', num2str(d, '%.3d'), str]);
        %print(fig, figname, '-depsc', '-r0', '-painters')
        print(fig, figname, '-dpng', '-r600', '-opengl')

        %{
        % 2D plot of the trajectory labeled d
        figure('pos', [10, 10, 400, 350]);
        hold on
        grid on
        N_plot = min(4000, Nt);
        plot(1 : N_plot, squeeze(D2(1, d, 1 : N_plot)), 'linewidth', 1);
        plot(1 : N_plot, squeeze(prediction(1, d, 1 : N_plot)), 'linewidth', 1);
        xlabel('timesteps')
        ylabel('X')
        %legend({'L63', 'NN'}, 'location', 'best')
        legend({'L63', 'NN'})
        title(plot_title)
        hold off
        figname = [plot_path, 'NN_predictions_2D_', num2str(d, '%.3d')];
        saveas(gca, figname, 'png')
        %}
    end

    set(0,'DefaultFigureVisible','on');

    
end