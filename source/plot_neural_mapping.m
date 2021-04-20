
%% check on neural mapping

ind_neuron_1 = 2;
ind_data_1 = 3;
row = 2;
col = 2;

net = NNs_small_num_data_tansig{ind_neuron_1, ind_data_1};

[code, W_star, b_star, W1, W2, b1, b2] = neural_mapping([0,0,0], net);
[U_star, S_star, V_star] = svd(W_star);
[U1, S1, V1] = svd(W1);
[U2, S2, V2] = svd(W2);


x_to_y = @(W1, b1, y) tansig(W1 * y + repmat(b1, 1, length(y(1, :, 1))));
mapping = @(W_star, b_star, y) tansig(W_star * y + repmat(b_star, 1, length(y(1, :, 1))));
y_to_x = @(W2, b2, y) W2 * y + b2;
rot = @(theta) [cos(theta)  , -sin(theta) ; sin(theta)  , cos(theta)   ]; % rotation counter-clockwise by theta
ref = @(theta) [cos(2*theta), sin(2*theta); sin(2*theta), -cos(2*theta)]; % reflection along y=tan(theta)*x

%W_star - U_star(:, 1:3) * S_star(1:3, 1:3) * V_star(:, 1:3)'

% get a mesh of points that belongs to [-1, 1]^4
%temp = -1:0.2:1;
%[X1, X2, X3, X4] = ndgrid([temp, temp, temp, temp]);
%Y_series_1 = [X1(:), X2(:), X3(:), X4(:)]';
%Y_series_2 = mapping(W_star, b_star, X_series);

%D_NN = D_NN_small_num{ind_neuron_1, ind_data_1};
D_NN = gen_data_on_attractor_NN(N_phase, 2, 2500, dt, net);

% get points of the attractor
N_points = 50;
%temp_D = D_NN(1:3, randsample(size(D_NN, 2), N_points));
temp_D = D_NN(1:3, 100 + (1 : 5 : N_points*5));
Y_series_1 = x_to_y(W1, b1, temp_D);
%Y_series_1 = round(Y_series_1/0.02)*0.02;
%Y_series_1 = unique(Y_series_1', 'rows')';

pointsize = 30;
dim = [2, 3, 1];
% define colors
[~, ind] = sort(Y_series_1(dim(1), :));
c = linspace(1, 10, N_points);


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

    position = @(fig_index) [left_margin + (mod(fig_index - 1, col)) * (width_fig + x_distance), ...
                1 - (up_margin + ceil(fig_index / col) * (height_fig + y_distance)) + y_distance, ...
                width_fig, height_fig];

fig = figure('pos', figsize);
[ax, lgd] = deal([]);
colors = get(gca,'colororder');

fig_index = 1;

ax(1) = subplot(2, 2, fig_index);
colormap('jet')
%scatter3(Y_series_1(dim(1), ind), Y_series_1(dim(2), ind), Y_series_1(dim(3), ind), pointsize, c, 'o', 'filled')
scatter(Y_series_1(dim(1), ind), Y_series_1(dim(2), ind), pointsize, c, 'o', 'filled')
%view(110, 30)
%axis([-0.8, -0.2, -0.1, 0.5])
hold on
Y_series_4 = U_star * S_star * V_star' * Y_series_1 + b_star;
%scatter3(Y_series_4(dim(1), ind), Y_series_4(dim(2), ind), Y_series_4(dim(3), ind), pointsize, c, 'x')
scatter(Y_series_4(dim(1), ind), Y_series_4(dim(2), ind), pointsize, c, 'x')
axis([-1.09, -0.34, -0.46, 0.24])
lgd(1) = legend({'$\mathcal{H}_0$', '$\mathcal{H}_3$'}, 'interpreter', 'latex');
text(0.05, 0.9, '(a)', 'Units', 'normalized', 'interpreter', 'latex')
        
        set(ax(1), 'Position', position(fig_index));
        set(ax(1), 'TickLabelInterpreter', 'latex')

fig_index = 2;
ax(2) = subplot(2, 2, fig_index);
Y_series_2 = V_star' * Y_series_1;
%scatter3(Y_series_2(dim(1), ind), Y_series_2(dim(2), ind), Y_series_2(dim(3), ind), pointsize, c, 's', 'filled')
scatter(Y_series_2(dim(1), ind), Y_series_2(dim(2), ind), pointsize, c, 's', 'filled')
hold on
%axis([-0.35, 0.25, -0.25, 0.35])
Y_series_3 = S_star * V_star' * Y_series_1;
%scatter3(Y_series_3(dim(1), ind), Y_series_3(dim(2), ind), Y_series_3(dim(3), ind), pointsize, c, 'd')
scatter(Y_series_3(dim(1), ind), Y_series_3(dim(2), ind), pointsize, c, 'd')
axis([-0.20, 0.50, -0.30, 0.40])
lgd(2) = legend({'$\mathcal{H}_1$', '$\mathcal{H}_2$'}, 'interpreter', 'latex', 'location', 'northeast');
text(0.05, 0.9, '(b)', 'Units', 'normalized', 'interpreter', 'latex')

        set(ax(2), 'Position', position(fig_index));
        set(ax(2), 'TickLabelInterpreter', 'latex')

fig_index = 3;
ax(3) = subplot(2, 2, fig_index);
Y_series_5 = tansig(W_star * Y_series_1 + b_star);
scatter(Y_series_1(dim(1), ind), Y_series_1(dim(2), ind), pointsize, c, 'o', 'filled')
hold on
%scatter3(Y_series_5(dim(1), ind), Y_series_5(dim(2), ind), Y_series_5(dim(3), ind), pointsize, c, '*')
dY = Y_series_5 - Y_series_1;
scatter(Y_series_5(dim(1), ind), Y_series_5(dim(2), ind), pointsize, c, 's')
%quiver(Y_series_1(dim(1), :), Y_series_1(dim(2), :), ...
%        dY(dim(1), :), dY(dim(2), :), 0, 'Linewidth', 1.0)
lgd(3) = legend({'$\mathcal{H}_0$', '$\mathcal{H}_4$'}, 'interpreter', 'latex');
%set(lgd(3),'Box','off')
text(0.05, 0.9, '(c)', 'Units', 'normalized', 'interpreter', 'latex')
axis([-0.90, -0.20, -0.50, 0.20])

        set(ax(3), 'Position', position(fig_index));
        set(ax(3), 'TickLabelInterpreter', 'latex')

        
fig_index = 4;
ax(4) = subplot(2, 2, fig_index);
X_series_1 = y_to_x(W2, b2, Y_series_1);
X_series_2 = y_to_x(W2, b2, Y_series_5);
scatter3(X_series_1(1, ind), X_series_1(2, ind), X_series_1(3, ind), 5, colors(4, :), 'o', 'filled')
hold on
dX_2 = (X_series_2 - X_series_1);
hq = quiver3(X_series_1(1, :), X_series_1(2, :), X_series_1(3, :), ...
        dX_2(1, :), dX_2(2, :), dX_2(3, :), 1.0, 'Linewidth', 1.0, 'MaxHeadSize', 0.5, 'color', colors(1, :));
%legend({'Y_series_1', 'Y_series_2', 'Y_series_3', 'Y_series_4'})
lgd(4) = legend({'start', 'NN flow'}, 'interpreter', 'latex', 'location', 'Northeast');
%set(lgd(4),'Box','off')
text(0.05, 0.9, '(d)', 'Units', 'normalized', 'interpreter', 'latex')

view(20, 10)
axis([-25, 25, -30, 30, 0, 60])
xticks([-15, 0, 15])
yticks([-25, 0, 25])
        
        set(ax(4), 'Position', position(fig_index));
        set(ax(4), 'TickLabelInterpreter', 'latex')

%saveas(gca, [plot_path_small_num, 'mapping'], 'png')
print(fig, [plot_path_small_num, 'mapping'], '-depsc', '-r0', '-painters')



%% check whether the 4-D orthonormal matrices are rotational or not

temp = -1:1:1;
[X1, X2, X3, X4] = ndgrid([temp, temp, temp, temp]);
X_series_1 = [X1(:), X2(:), X3(:), X4(:)]';
X_series_2 = V_star' * X_series_1;

figure
pointsize = 20;
dim = [1, 2, 3];
scatter3(X_series_1(dim(1), :), X_series_1(dim(2), :), X_series_1(dim(3), :), pointsize, 'filled')
view(110, 30)
hold on
scatter3(X_series_2(dim(1), :), X_series_2(dim(2), :), X_series_2(dim(3), :), pointsize, 'filled')

[Q_l, Q_r] = isoclinic_decomposition(V_star');
Q_l * Q_r - V_star'

U_star_2 = U_star;
U_star_2(1:4, 4) = - U_star_2(1:4, 4);
[Q_l, Q_r] = isoclinic_decomposition(U_star_2);
Q_l * Q_r - U_star_2

