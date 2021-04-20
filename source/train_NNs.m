function [ts, scores_train, scores_cv, NNs] = train_NNs(...
    D_raw, N_train, N_test, N_cv, x_threshold, ...
    Num_neuron, Num_data, transferFcn)

    % Set random seed so that NN are trained same all the time
    rng(2);

    % Define some constants and arrays
    N_phase = 3; % dimensionality of phase space
    N_d = length(Num_data);
    [ts, scores_train, scores_cv] = deal(zeros([length(Num_neuron), N_d]));
    
    % Split and select data
    % First select 3 times as many data points, and discard according to
    % x_threshold. Then, only choose the first N_train points
    [D_Train, D_test, D_cv] = split_data(D_raw, N_train*3, N_test, N_cv);
    D_Train = D_Train(:, D_Train(1, :) > x_threshold);
    D_Train = D_Train(:, 1:N_train);

    % define placeholder for NNs
    NNs = cell(length(Num_neuron), length(N_d));

    % do cross-validation loop for # of neurons and # of data
    for i_d = 1 : N_d

        disp(['number of data: ', num2str(Num_data(i_d))]);
        temp_D_Train = D_Train(:, 1:Num_data(i_d));

        for i_c = 1 : length(Num_neuron)

            % set dimantionality of neuron space
            N_neuron    = Num_neuron(i_c); 

            % train a simple feed-forward neural network
            mynet = feedforwardnet(N_neuron);
            mynet.trainFcn = 'trainbr';
            mynet.trainParam.epochs = 1000;
            mynet.layers{1}.transferFcn = transferFcn;
            [NNs{i_c, i_d}, ~, ~, ~] = train(mynet, temp_D_Train(1 : N_phase, :), temp_D_Train(N_phase + 1 : 2 * N_phase, :));

        end

        ts(:, i_d)              = test_score({NNs{:, i_d}}, D_test      , N_phase);
        scores_train(:, i_d)    = test_score({NNs{:, i_d}}, temp_D_Train, N_phase);
        scores_cv(:, i_d)       = test_score({NNs{:, i_d}}, D_cv        , N_phase);

    end

end