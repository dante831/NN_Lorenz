%% define some general constants

root_path = './';
addpath([root_path, 'source/'])
output_path = './results/';
plot_path_half_domain = [output_path, 'figures_half_domain/'];
plot_path_small_num = [output_path, 'figures_small_num/'];
if ~exist(output_path)
    mkdir(output_path)
end
if ~exist(plot_path_half_domain)
    mkdir(plot_path_half_domain)
end
if ~exist(plot_path_small_num)
    mkdir(plot_path_small_num)
end

Num_neuron            = 3:1:8;
N_train               = 1000;  	% number of training data
N_test                = 600;    % number of testing data
N_cv                  = 400;    % number of cross-validation data
dt                    = 0.01;  	% length of the time step
Num_data_small_num    = [20, 30, 40, 60, 100, 150];
N_d                   = length(Num_data_small_num);
N_phase               = 3;

%% generate training data on the attractor (DON'T DELETE)
N_set       = 1000;     % number of trajectories
Nt          = 2500;     % time steps of each trajectory
D_raw = gen_data_on_attractor_L63(N_set, Nt, dt);
save([output_path, 'train_data_on_attractor.mat'], 'D_raw');

% load training data on the attractor, generated from main.m
load([output_path, 'train_data_on_attractor.mat']);

%% train NNs on very few data points

% network trained on a small number of data
x_threshold = -100; 
    % threshold for data selection in the x direction. Here, it's negative
    % so that all data are included
fcn_str = 'tansig';
[ts_tansig, ~, ~, NNs_small_num_data_tansig] = train_NNs(...
    D_raw, N_train, N_test, N_cv, x_threshold, ...
    Num_neuron, Num_data_small_num, fcn_str);

% ---------------- plot trajectories -----------------

% succesful choices
ind_neuron_1 = 2; % 4 neurons
ind_data_1 = 3; % 40 data points
net = NNs_small_num_data_tansig{ind_neuron_1, ind_data_1};

Nt = 2000; % total iterations of each trajectory
Np = 20; % total trajectories

plot_trajectories(Nt, dt, Np, net, D_raw, plot_path_small_num, [], Inf);
% Choose number 8 for the paper, figure 1

%% train NNs with different activation (transfer functions)
fcn_strs = {'elliotsig', 'logsig', 'poslin', 'radbas', 'tribas', ...
    'softmax', 'softplus', 'tansig_custom', 'purelin'};
% tansig_custom here is to confirm that my custom-defined function is the
% same as matlab's internal function, tansig. 
for n = 1 : length(fcn_strs)
    fcn_str = fcn_strs{n};
    eval(['[ts_', fcn_str, ', ~, ~, NNs_small_num_data_', fcn_str, ']', ...
        ' = train_NNs(D_raw, N_train, N_test, N_cv, x_threshold, ', ...
        'Num_neuron, Num_data_small_num, fcn_str);']);
end

% plot RMS error statistics
fcn_strs = ["tansig"   , "(a) $g(x) = \tanh(x)$"; ...
            "elliotsig", "(b) Elliot sigmoid, $g(x) = x/(1+|x|)$"; ...
            "logsig"   , "(c) log sigmoid, $g(x) = 1/(1+e^{-x})$"; ...
            "radbas"   , "(d) radial basis, $g(x) = e^{-x^2}$"; ...
            "softmax"  , "(e) softmax, $g(\mathbf{x})_i = e^{x_i}/(\sum_i e^{x_i})$"; ...
            "softplus" , "(f) softplus, $g(x) = \ln(1+e^x)$"; ...
            "purelin"  , "(g) pure linear, $g(x) = x$"; ...
            "poslin"   , "(h) ReLU, $g(x) = x\cdot\mathbf{1}_{x>0}$"; ...
            "tribas"   , "(i) trangular basis,  $g(x) = (1 - |x|)\cdot\mathbf{1}_{-1<x<1}$"; ...
            "tansig_custom", "$g(x) = \tanh(x)$"];
[Y, X] = meshgrid(Num_data_small_num, Num_neuron);
LOG_YSCALE = false;
%fig = figure('pos', [10, 10, 270*3, 300*3]);
fig = figure('pos', [10, 10, 230*3, 220*3]);
fig_nx = 3; fig_ny = 3;
left_margin = 0.06; right_margin = 0.09; 
bottom_margin = 0.03; top_margin = 0.03;
x_spacing = 0.07; y_spacing = 0.05;
width = (1 - left_margin - right_margin - x_spacing*(fig_nx-1))/fig_nx;
height = (1 - bottom_margin - top_margin - y_spacing*(fig_nx-1))/fig_ny;
for n = 1 : size(fcn_strs, 1) - 1
    fcn_str = char(fcn_strs(n, 1));
    eval(['temp_ts = ', 'ts_', fcn_str, ';'])
    position = [left_margin + (width + x_spacing) * (mod(n - 1, fig_nx)), ...
                1 - (top_margin + height + (height + y_spacing) * floor((n-1)/fig_nx)), ...
                width, height];
    if mod(n, fig_nx) == 1; ZLABEL = true; else; ZLABEL = false; end
    if n == 6; COLORBAR = true; else; COLORBAR = false; end
    if any(n == [7, 8, 9]); XYLABEL = true; else; XYLABEL = false; end
    plot_test_error_multipanel(fig, position, ...
        X, Y, temp_ts, 'zlimit', [5e-3, 5e1], 'surface_z', 1e-2, ...
        'plot_title', fcn_strs(n, 2), 'COLORBAR', COLORBAR, ...
        'ZLABEL', ZLABEL, 'XYLABEL', XYLABEL);
    if strcmp(fcn_str, 'softmax')
        continue
    else
        ax2 = axes; 
        x = -2:0.01:2;
        eval(['y = ', fcn_str, '(x);'])
        plot(ax2, x, y, 'linewidth', 1); 
        axis([-2, 2, -2, 2]); grid on
        set(ax2, 'TickLabelInterpreter', 'latex')
        position_2 = [position(1:2), 0, 0] + [0.8*width, 0.75*height, 0.25*width, 0.2*height];
        set(ax2, 'Position', position_2)
    end
end
print(fig, [plot_path_small_num, 'NN_test_errors_3D_multipanel'], ...
    '-dpng', '-r300', '-opengl')

for n = 1 : size(fcn_strs, 1)
    fcn_str = char(fcn_strs(n, 1));
    eval(['temp_ts = ', 'ts_', fcn_str, ';'])
    plot_name = ['NN_test_errors_3D_small_num_data_', fcn_str];
    plot_test_error(X, Y, temp_ts, LOG_YSCALE, plot_path_small_num, ...
        plot_name, 'zlimit', [5e-3, 5e1], 'surface_z', 1e-2, ...
        'plot_title', fcn_strs(n, 2));
end
for n = 1 : size(fcn_strs, 1)
    fcn_str = char(fcn_strs(n, 1));
    eval(['temp_NNs = ', 'NNs_small_num_data_', fcn_str, ';'])
    net = temp_NNs{ind_neuron_1, ind_data_1};
    plot_trajectories(Nt, dt, 1, net, D_raw, plot_path_small_num, ...
        ['_', fcn_str], Inf);
end


%% train NNs on data points from a partial attractor

N_d                  = 5;
Num_data_half_domain = floor(logspace(1, log10(N_train), N_d));

% set x > -5, and not too many number of neurons (e.g., smaller than 12)
x_threshold = -5.0; % threshold for data selection
fcn_str = 'tansig';
[ts, scores_train, scores_cv, NNs_half_domain] = train_NNs(...
    D_raw, N_train, N_test, N_cv, x_threshold, ...
    Num_neuron, Num_data_half_domain, fcn_str);

% 3D plot of test errors as functions of number of data and neurons
[Y, X] = meshgrid(Num_data_half_domain, Num_neuron);
plot_name = 'NN_test_errors_3D_small_num_data';
LOG_YSCALE = true;
plot_test_error(X, Y, ts, LOG_YSCALE, plot_path_half_domain, plot_name);

% ---------------- plot trajectories -----------------

% succesful choices
ind_neuron_2 = 3;
ind_data_2 = 3;
net = NNs_half_domain{ind_neuron_2, ind_data_2};
Nt = 2000; % total iterations of each trajectory
Np = 10; % total trajectories

plot_trajectories(Nt, dt, Np, net, D_raw, plot_path_half_domain, ...
    [], x_threshold);
% Choose number 8 for the paper


%% calculate FTLE for both types of neural networks

% define some constants
N_set       = 1000;     % number of trajectories
Nt          = 2500;     % time steps of each trajectory
Np          = 2000;
Nt_series = [5, 10, 50, 100, 500];
PLOT_FTLE   = false;
[Lambda_ode_small_num_data, Lambda_nn_small_num_data] = ...
    deal(cell(length(Nt_series), length(Num_neuron), ...
              length(Num_data_small_num)));
D_NN_small_num = cell(length(Num_neuron), length(Num_data_small_num));
[Lambda_ode_half_domain, Lambda_nn_half_domain] = ...
    deal(cell(length(Nt_series), length(Num_neuron), ...
              length(Num_data_half_domain)));
D_NN_half_domain = cell(length(Num_neuron), length(Num_data_half_domain));

% ---------------- FTLE for small number of data -----------------

for i = 1 : length(Num_neuron)
    for j = 1 : length(Num_data_small_num)
        
        net = NNs_small_num_data_tansig{i, j};
        
        % generate data on NN's attractor
        D_NN_small_num{i, j} = ...
            gen_data_on_attractor_NN(N_phase, N_set, Nt, dt, net);
        
        % calculate FTLE
        for n = 1 : length(Nt_series)
            disp(['i = ', num2str(i), ', j = ', num2str(j), ', n = ', num2str(n)])
            [Lambda_ode_small_num_data{n, i, j}, Lambda_nn_small_num_data{n, i, j}] = ...
                FTLE_calculation(net, dt, D_raw, D_NN_small_num{i, j}, Nt_series(n), Np, plot_path_small_num, PLOT_FTLE);
        end
    end
end

FTLE_error_small_num = ...
    FTLE_err(Lambda_ode_small_num_data, Lambda_nn_small_num_data);
[Y, X] = meshgrid(Num_data_small_num, Num_neuron);
plot_name = 'FTLE_errors_3D_small_num_data';
LOG_YSCALE = false;
plot_test_error(X, Y, squeeze(FTLE_error_small_num(3, :, :)), ...
    LOG_YSCALE, plot_path_small_num, plot_name, 'EX_POINT', true);

% plot one-to-one correspondence of FTLE
ind_Nt = [1, 3, 4, 5];
row = 2;
col = 2;
Lambda_ode_ = {Lambda_ode_small_num_data{ind_Nt, ind_neuron_1, ind_data_1}};
Lambda_nn_  = {Lambda_nn_small_num_data{ind_Nt, ind_neuron_1, ind_data_1}};
Nts = Nt_series(ind_Nt);
plot_FTLE(row, col, Lambda_ode_, Lambda_nn_, Nts, plot_path_small_num)

% ---------------- FTLE for half-domain of training data -----------------

for i = 1 : length(Num_neuron)
    for j = 1 : length(Num_data_half_domain)
        
        net = NNs_half_domain{i, j};
        
        % generate data on NN's attractor
        D_NN_half_domain{i, j} = gen_data_on_attractor_NN(N_phase, N_set, Nt, dt, net);
        
        % calculate FTLE
        for n = 1 : length(Nt_series)
            [Lambda_ode_half_domain{n, i, j}, Lambda_nn_half_domain{n, i, j}] = ...
                FTLE_calculation(net, dt, D_raw, D_NN_half_domain{i, j}, Nt_series(n), Np, plot_path_half_domain, PLOT_FTLE);
        end
    end
end
FTLE_error_half_domain = FTLE_err(Lambda_ode_half_domain, Lambda_nn_half_domain);
[Y, X] = meshgrid(Num_data_half_domain, Num_neuron);
plot_name = 'FTLE_errors_3D_half_domain';
LOG_YSCALE = true;
plot_test_error(X, Y, squeeze(FTLE_error_half_domain(3, :, :)), ...
    LOG_YSCALE, plot_path_half_domain, plot_name, 'EX_POINT', true);

% plot one-to-one correspondence of FTLE
ind_Nt = [1, 3, 4, 5];
row = 2;
col = 2;
Lambda_ode_ = {Lambda_ode_half_domain{ind_Nt, ind_neuron_2, ind_data_2}};
Lambda_nn_  = {Lambda_nn_half_domain{ind_Nt, ind_neuron_2, ind_data_2}};
Nts = Nt_series(ind_Nt);
plot_FTLE(row, col, Lambda_ode_, Lambda_nn_, Nts, plot_path_half_domain)

%% Get matrices for table 1
net = NNs_small_num_data_tansig{ind_neuron_1, ind_data_1};
[y_raw, W_star, b_star, W1, W2, b1, b2] = neural_mapping(D_raw(1:3, :), net);
[U,S,V] = svd(W_star);

%% save workspace for L63 model
save([root_path, 'workspace_L63']);



