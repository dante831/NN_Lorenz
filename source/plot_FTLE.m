function plot_FTLE(row, col, Lambda_ode_, Lambda_nn_, Nts, plot_path)

    min_x = -2;
    max_x = 14;
    
    % parameters of the figure
    figsize = [10 10 330 300];
    distance = 20;
    x_distance  = distance / figsize(3);
    y_distance  = distance / figsize(4);

    left_margin     = 0.11;
    right_margin    = 0.07;
    down_margin     = 0.11;
    up_margin       = 0.05;

    width_fig   = (1 - left_margin - right_margin - x_distance * (col - 1)) / col;
    height_fig  = (1 - down_margin - up_margin    - y_distance * (row - 1)) / row;

    fig = figure('pos', figsize);
    
    for fig_index = 1 : length(Lambda_ode_)

        Lambda_ode = Lambda_ode_{fig_index};
        Lambda_nn = Lambda_nn_{fig_index};

        subplot(2, 2, fig_index);
        ax1 = subplot(row, col, fig_index);
        hold on
        grid on
        title(['$N_t = ', num2str(Nts(fig_index)), '$'], 'interpreter', 'latex')
        scatter(Lambda_ode, Lambda_nn, 10, 'filled')
        plot(min_x:max_x, min_x:max_x, '--')
        axis([min_x, max_x, min_x, max_x])
        set(gca, 'xtick', min_x:2:max_x)
        set(gca, 'ytick', min_x:2:max_x)
        
        % set axis labels and ticks
        set(ax1, 'Xtick', [0, 2:4:14])
        set(ax1, 'Ytick', [0, 2:4:14])
        if fig_index > col*(row-1)
            xlabel('L63', 'interpreter', 'latex')
        else
            set(ax1, 'Xticklabel', [])
        end
        if mod(fig_index - 1, col) == 0
            ylabel('NN', 'interpreter', 'latex')
        else
            set(ax1, 'Yticklabel', [])
        end
        
        position = [left_margin + (mod(fig_index - 1, col)) * (width_fig + x_distance), ...
                1 - (up_margin + ceil(fig_index / col) * (height_fig + y_distance)) + y_distance, ...
                width_fig, height_fig];
        
        set(ax1, 'Position', position);
        set(ax1, 'TickLabelInterpreter', 'latex')

        hold off
    end
    
    %saveas(gca, [plot_path, 'FTLE_Nts'], 'png')
    print(fig, [plot_path, 'FTLE_Nts'], '-depsc', '-r0', '-painters')


    