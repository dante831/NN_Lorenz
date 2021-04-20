function plot_test_error(X, Y, ts, LOG_YSCALE, plot_path, plot_name, ...
    varargin)

    
    zlimit = [1e-2, 1e2]; % z axis limit
    surface_z = 5e-2; % the vertical level of the transparent plane
    EX_POINT = false; % whether to plot the example NN
    for i=1:2:length(varargin)
        if strcmp(varargin(i), 'zlimit')
            zlimit = varargin(i+1);
            zlimit = zlimit{1};
        elseif strcmp(varargin(i), 'surface_z')
            surface_z = varargin(i+1);
            surface_z = surface_z{1};
        elseif strcmp(varargin(i), 'EX_POINT')
            EX_POINT = varargin(i+1);
            EX_POINT = EX_POINT{1};
        elseif strcmp(varargin(i), 'plot_title')
            plot_title = varargin(i+1);
            plot_title = plot_title{1};
        end
    end
    
    Num_neuron = X(:, 1);
    Num_data = Y(1, :)';
    
    fig = figure('pos', [10, 10, 320, 270]);
    hold on
    grid on
    s1 = surf(X, Y, ts);

    % show the location of the example NN trained with 4 neurons and 40
    % data points
    if EX_POINT
        scatter3(X(2, 3), Y(2, 3), ts(2, 3), 'red', 'o', 'filled');
    end
    
    h = colorbar;
    set(gca,'colorscale','log')
    %ylabel(h, 'error')
    h.Label.Interpreter = 'latex';
    h.TickLabelInterpreter = 'latex';
    
    s2 = surf(X, Y, ones(size(X)) * surface_z, ...
        'Facecolor', 'r', 'Edgecolor', 'none');
    alpha([s1, s2], 0.5)
    set(gca, 'ZScale', 'log')
    if LOG_YSCALE
        set(gca, 'yScale', 'log')
    end
    xlabel('Neurons', 'interpreter', 'latex')
    ylabel('Number of data', 'interpreter', 'latex')
    zlabel('RMS error', 'interpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    view(120, 30)
    axis([Num_neuron(1), Num_neuron(end), Num_data(1), Num_data(end), zlimit])
    xticks(Num_neuron)
    yticks(Num_data)
    zticks([1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2])
    caxis([1e-2*5, 1e2/5])
    if exist('plot_title', 'var')
        title(plot_title, 'interpreter', 'latex')
    end
    hold off
    
    print(fig, [plot_path, plot_name], '-dpng', '-r600', '-opengl')
    
end

