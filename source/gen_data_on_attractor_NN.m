function D_NN = gen_data_on_attractor_NN(N_phase, N_set, Nt, dt, net)
    
    rng(1); % add random seed
    
    % check integration steps
    k = ceil(2000*0.01/dt); 
    if Nt <= k
        disp('error: Nt should be larger than 2000 to account for transient trajectories');
        return
    end
    
    % define place holder
    D_NN = zeros(6, (Nt - k) * N_set);
    
    % randomly select start points in the domain
    start = rand(3, N_set) .* repmat([20; 20; 25], 1, N_set) + repmat([0; 0; 25], 1, N_set);
    
    prediction = deal(zeros(N_phase, N_set, Nt));
    prediction(:, :, 1) = start;
    for t = 2 : Nt
        if mod(t, 100) == 0
            disp(['t = ', num2str(t), '/', num2str(Nt)]);
        end
        prediction(:, :, t) = net(prediction(:, :, t - 1));
        if t > k
            D_NN(:, (t - k - 1) * N_set + 1 : (t - k) * N_set) = ...
                [prediction(:, :, t - 1); prediction(:, :, t)];
        end
    end

end
