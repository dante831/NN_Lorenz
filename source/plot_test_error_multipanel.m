function fig = plot_test_error_multipanel(fig, position, ...
    X, Y, ts, varargin)

    zlimit = [1e-2, 1e2]; % z axis limit
    surface_z = 5e-2; % the vertical level of the transparent plane
    plot_title = [];
    COLORBAR = true; ZLABEL = true; XYLABEL = true;
    for i=1:2:length(varargin)
        if strcmp(varargin(i), 'zlimit')
            zlimit = varargin(i+1);
            zlimit = zlimit{1};
        elseif strcmp(varargin(i), 'surface_z')
            surface_z = varargin(i+1);
            surface_z = surface_z{1};
        elseif strcmp(varargin(i), 'plot_title')
            plot_title = varargin(i+1);
            plot_title = plot_title{1};
        elseif strcmp(varargin(i), 'COLORBAR')
            COLORBAR = varargin(i+1);
            COLORBAR = COLORBAR{1};
        elseif strcmp(varargin(i), 'ZLABEL')
            ZLABEL = varargin(i+1);
            ZLABEL = ZLABEL{1};
        elseif strcmp(varargin(i), 'XYLABEL')
            XYLABEL = varargin(i+1);
            XYLABEL = XYLABEL{1};
        end
    end
    
    Num_neuron = X(:, 1);
    Num_data = Y(1, :)';
    
    
    ax = axes;
    %'Position', position);
    set(ax, 'LooseInset', get(gca,'TightInset'))
    hold on
    grid on
    s1 = surf(ax, X, Y, ts);
    
    set(ax,'colorscale','log')
    if COLORBAR
        h = colorbar;
        h.Label.Interpreter = 'latex';
        h.TickLabelInterpreter = 'latex';
    end
    
    s2 = surf(X, Y, ones(size(X)) * surface_z, ...
        'Facecolor', 'r', 'Edgecolor', 'none');
    alpha([s1, s2], 0.5)
    set(gca, 'ZScale', 'log')
    if XYLABEL
        xlabel('Neurons', 'interpreter', 'latex')
        ylabel('Number of data', 'interpreter', 'latex')
    end
    if ZLABEL
        zlabel('RMS error', 'interpreter', 'latex')
    end
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
    set(ax, 'Position', position)
        
end