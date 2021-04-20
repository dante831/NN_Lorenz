clear all
addpath('source')

rng(831)

output_path = './results/';
plot_path = [output_path, 'figures_Henon/'];
if ~exist(plot_path)
    mkdir(plot_path)
end
start = [1, -0.2];
N_set = 1000;
Nt = 2500; % Nt should be larger than 2000
    % N_set and Nt are the same as the Lorenz case
%N_sample = 40000;
N_sample = 20; % the smallest number of data is around 20
D_raw = gen_data_on_attractor_Henon(N_set, Nt);
ind = randsample(length(D_raw(1, :)), N_sample);
D = D_raw(:, ind);
point_size = 20;


figure
scatter(D(1, :), D(2, :), 50, '.')
title('training data')

mynet = feedforwardnet(2);
mynet.trainFcn = 'trainbr';
mynet.trainParam.epochs = 1000;
[net, a, b, c] = train(mynet, D(1 : 2, :), D(3 : 4, :));
y = net(D(1 : 2, :));
perf = perform(net, y, D(3 : 4, :));


Nt = 5000;
Np = 100; % total points

sigma = 0.01;
start2 = [0.2996   -0.1656];
startp = zeros(2, Np);
for n = 1 : Np
    startp(:, n) = start2 + [0.01*(n - Np/2), 0.01*(n - Np/2)];
end

[prediction, D2] = deal(zeros(2, Np, Nt));
prediction(:, :, 1) = startp;

% do predictions from NN
for t = 2 : Nt
    if(mod(t, 100) == 0);disp(t);end
    prediction(:, :, t) = net(prediction(:, :, t - 1));
end
for n = 1 : Np
    a2 = henon_synthetic(startp(:, n), Nt);
    D2(:, n, :) = a2';
end


figure
hold on
N_plot = 4000;
n = 5;
scatter(squeeze(D2(1, :)), ...
        squeeze(D2(2, :)), 10, 'o', 'blue', 'filled');
scatter(squeeze(prediction(1, :)), ...
        squeeze(prediction(2, :)), 10, 'o', 'red', 'filled');
xlabel('X')
ylabel('Y')
legend({'ODE', 'NN'}, 'location', 'best')
hold off
saveas(gca, [plot_path, 'NN_predictions_henon'], 'png')

save('henon_workspace')

%{
% plot time instances of multiple data points
plot_interval = 1;
for i = 1 : 100/plot_interval
    set(0,'DefaultFigureVisible','off');
    t = i * plot_interval;
    disp(['t = ', num2str(t)]);
    figure
    hold on
    grid on;
    p1 = scatter(squeeze(D2(1, :, t)), ...
                  squeeze(D2(2, :, t)), point_size, 'o', 'blue', 'filled');
    p2 = scatter(squeeze(prediction(1, :, t)), ...
                  squeeze(prediction(2, :, t)), point_size, 'o', 'red', 'filled');
    p3 = scatter(startp(1, :), startp(2, :), 5, 'o', 'black', 'filled');
    axis([-1.5 1.5 -0.4 0.4])
    xlabel('X')
    ylabel('Y')
    legend([p1, p2, p3], {'ODE', 'NN', 'start'});
    hold off
    saveas(gca, ['NN_predictions/NN_predictions_', num2str(i)], 'png')
    set(0,'DefaultFigureVisible','on');

end
%}

load('henon_workspace')

[code, W_star, b_star, W1, W2, b1, b2] = neural_mapping(0, net);
[U_star, S_star, V_star] = svd(W_star);
[U1, S1, V1] = svd(W1);
[U2, S2, V2] = svd(W2);

x_to_y = @(W1, b1, y) tansig(W1 * y + repmat(b1, 1, length(y(1, :, 1))));
mapping = @(W_star, b_star, y) tansig(W_star * y + repmat(b_star, 1, length(y(1, :, 1))));
y_to_x = @(W2, b2, y) W2 * y + b2;
rot = @(theta) [cos(theta)  , -sin(theta) ; sin(theta)  , cos(theta)   ]; % rotation counter-clockwise by theta
ref = @(theta) [cos(2*theta), sin(2*theta); sin(2*theta), -cos(2*theta)]; % reflection along y=tan(theta)*x

%% start from a basic configuration

theta1 = 60/180*pi;
theta2 = 45/180*pi;
U_test_1 = rot(theta1);
V_test_1 = rot(theta2);
S_test_1 = diag([1.1, 1.1]);
W_test_1 = U_test_1*S_test_1*V_test_1';
b_test_1 = [0.0;0.08];

start = x_to_y(W1, b1, [0.8; 0.0]);
position1 = zeros(2, Nt);
position1(:, 1) = start;
for t = 1 : Nt - 1
    position1(:, t + 1) = mapping(W_test_1, b_test_1, position1(:, t));
end
figure
scatter(position1(1, :), position1(2, :), point_size, 'o', 'blue', 'filled')

%% add reflection

theta1 = 60/180*pi;
theta2 = 45/180*pi;

theta1 = acos(U_star(1, 1))/2;
theta2 = acos(V_star(1, 1));
U_test_2 = ref(theta1);
%U_test_2 = rot(theta1);
V_test_2 = rot(theta2);
S_test_2 = diag([1.1, 1.1]);
S_test_2 = S_star;
W_test_2 = U_test_2*S_test_2*V_test_2';
b_test_2 = [0.0;0.08];
b_test_2 = b_star;

position1 = zeros(2, Nt);
position1(:, 1) = start;
for t = 1 : Nt - 1
    position1(:, t + 1) = mapping(W_test_2, b_test_2, position1(:, t));
end
figure
scatter(position1(1, :), position1(2, :), 10, 'o', 'blue', 'filled')


%% Henon map

theta1 = angle(U_star(1, 1) + 1i*U_star(1, 2))/2;
theta2 = angle(V_star(1, 1) - 1i*V_star(1, 2));
U_henon = ref(theta1);
V_henon = rot(theta2);
S_henon = S_star;
W_henon = U_henon * S_henon * V_henon';
b_henon = b_star;


Nt = 10000;
n = 100;
X1 = (- n : n) * 1 / n;
X2 = -0.2 * X1 + 0.2;
y_start = x_to_y(W1, b1, [X1(:)'; X2(:)']);
%y_start = x_to_y(W1, b1, D_raw(1:2, 400000:400100));
%y_start = [X1(:)'; X2(:)'];

position = zeros(2, length(y_start(1, :)), Nt);
for i = 1 : Nt
    if i == 1
        position(:, :, i) = y_start;
    else
        position(:, :, i) = mapping(W_henon, b_henon, position(:, :, i - 1));
    end
end

Nt = 100000;
position1 = zeros(2, Nt);
position1(:, 1) = x_to_y(W1, b1, startp(:, 1));
for t = 1 : Nt - 1
    position1(:, t + 1) = mapping(W_henon, b_henon, position1(:, t));
end


%% plot predictions of the NN and Henon map
small_figsize =[10, 10, 150, 150];
colors = get(gca,'colororder');

output = y_to_x(W2, b2, position1);
fig = figure('pos', [10, 10, 400, 300]);
ax = axes;
scatter(ax, output(1, 1000:end), output(2, 1000:end), point_size/10, colors(1, :), 'o', 'filled')
hold on
scatter(ax, D_raw(1, 1:end), D_raw(2, 1:end), point_size/10, colors(2, :), 'o', 'filled')
legend('NN', 'Henon', 'interpreter', 'latex')
xlabel('$x^{(1)}$', 'interpreter', 'latex')
ylabel('$x^{(2)}$', 'interpreter', 'latex')
set(ax, 'TickLabelInterpreter', 'latex')
axis([-1.5, 1.5, -0.4, 0.4])
hold off
print(fig, [plot_path, 'predictions'], '-depsc', '-r0', '-painters')

fig = figure('pos', [10, 10, 300, 300]);
hold on
box on
scatter(output(1, 1000:end), output(2, 1000:end), point_size/3, colors(1, :), 'o', 'filled')
scatter(D_raw(1, 1:end), D_raw(2, 1:end), point_size/3, colors(2, :), 'o', 'filled')
axis([0.295, 0.313, 0.206, 0.214])
xticks([])
yticks([])
print(fig, [plot_path, 'predictions_expand'], '-depsc', '-r0', '-painters')


%% plot individual steps of the internal mapping

y0 = y_start;
% first step, rotation 
y1 = V_henon' * y0;
% second step, stretch
y2 = S_henon * y1;
% third step, reflection
y3 = U_henon * y2;
% fourth step, compression
y4 = tansig(y3 + repmat(b_star, 1, length(y3(1, :))));

% the complete figure
fig1 = figure('pos', [10, 10, 550, 240]);
scatter(y0(1, :), y0(2, :), 15, colors(1, :), 'o', 'filled')
hold on
scatter(y1(1, :), y1(2, :), 15, colors(2, :), 'o', 'filled')
scatter(y2(1, :), y2(2, :), 15, colors(3, :), 'o', 'filled')
scatter(y3(1, :), y3(2, :), 15, colors(4, :), 'o', 'filled')
scatter(y4(1, :), y4(2, :), 15, colors(5, :), 'o', 'filled')
scatter(0, 0, 10, 'black', 'o', 'filled')
xlabel('$y^{(1)}$', 'interpreter', 'latex')
ylabel('$y^{(2)}$', 'interpreter', 'latex')
axis([-55, 55, -40, 15])
set(gca, 'TickLabelInterpreter', 'latex')
legend({'$\mathcal H^0$', ...
        '$\mathcal H^1$', ...
        '$\mathcal H^2$', ...
        '$\mathcal H^3$', ...
        '$\mathcal H^4$', ...
        'origin'}, 'interpreter', 'latex', 'location', 'northeast')
hold off
print(fig1, [plot_path, 'whole'], '-depsc', '-r0', '-painters')

% 0, 1, and 4
fig2 = figure('pos', [10, 10, 400, 200]);
hold on
box on
scatter(y0(1, :), y0(2, :), 15, colors(1, :), 'o')
scatter(y4(1, :), y4(2, :), 15, colors(5, :), 'o')
scatter(y1(1, :), y1(2, :), 15, colors(2, :), 'o', 'filled')
scatter(0, 0, 20, 'black', 'o', 'filled')
axis([-1.4, 1.2, -0.3, 1.0])
xticks([])
yticks([])
print(fig2, [plot_path, '014'], '-depsc', '-r0', '-painters')

% 0
fig3 = figure('pos', small_figsize);
hold on
box on
scatter(y0(1, :), y0(2, :), 5, colors(1, :), 'o', 'filled')
axis([0.64, 0.76, 0.66, 0.78])
xticks([])
yticks([])
print(fig3, [plot_path, '0'], '-depsc', '-r0', '-painters')

% 1
fig4 = figure('pos', small_figsize);
hold on
box on
scatter(y1(1, :), y1(2, :), 5, colors(2, :), 'o', 'filled')
axis([-1.084, -0.924, -0.01, 0.15])
xticks([])
yticks([])
print(fig4, [plot_path, '1'], '-depsc', '-r0', '-painters')

% 2
fig5 = figure('pos', small_figsize);
hold on
box on
scatter(y2(1, :), y2(2, :), 5, colors(3, :), 'o', 'filled')
axis([-44.72, -44.45, -0.04, 0.04])
xticks([])
yticks([])
print(fig5, [plot_path, '2'], '-depsc', '-r0', '-painters')

% 3
fig6 = figure('pos', small_figsize);
hold on
box on
scatter(y3(1, :), y3(2, :), 5, colors(4, :), 'o', 'filled')
axis([33.03, 33.2, -29.94, -29.77])
xticks([])
yticks([])
print(fig6, [plot_path, '3'], '-depsc', '-r0', '-painters')

% 0 and 4
fig7 = figure('pos', small_figsize);
hold on
box on
scatter(y0(1, :), y0(2, :), 5, colors(1, :), 'o', 'filled')
scatter(y4(1, :), y4(2, :), 5, colors(5, :), 'o', 'filled')
axis([0.64, 0.76, 0.66, 0.78])
xticks([])
yticks([])
print(fig7, [plot_path, '04'], '-depsc', '-r0', '-painters')

% 0 and 4 zoomed in
figure('pos', [10, 10, 400, 400])
hold on
box on
scatter(y0(1, :), y0(2, :), 15, colors(1, :), 'o', 'filled')
scatter(y4(1, :), y4(2, :), 15, colors(5, :), 'o', 'filled')
axis([0.64, 0.76, 0.66, 0.78])
saveas(gca, [plot_path, '04_zoomed'], 'png')

save('henon_workspace')
