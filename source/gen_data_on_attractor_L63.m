function D = gen_data_on_attractor_L63(N_set, Nt, dt)
    
    rng(1); % add random seed to generate the same set of data all the time
    
    k = ceil(2000*0.01/dt); 
    if Nt <= k
        disp('error: Nt should be larger than 2000 to account for transient trajectories');
        return
    end
    D = zeros(6, (Nt - k) * N_set);
    
    %start = [1, 1, 5];
    start = rand(1, 3) .* [20, 20, 25] + [0, 0, 25];
    
    for i = 1 : N_set
        if mod(i, 100) == 0
            disp(['i = ', num2str(i), '/', num2str(N_set)]);
        end
        
        % simulate trajectory starting from point "start", and lasting Nt
        % time steps
        [~, a] = lorenz_synthetic(start, Nt, dt);
        
        % write the obtained trajectory into D. 
        % D(1:3, :) are timestep t, and D(4:6, :) archive timestep t+1
        D(:, (Nt - k) * (i - 1) + 1 : (Nt - k) * i) = [a(k : end - 1, :), a(k + 1 : end, :)]';
        
        % add random perturbation to the start of the next trajectory
        % argument: because the Lorenz system is mixing, one neighborhood
        % of the attractor will be eventually visited by all trajectories.
        % This means that the neighborhood is dense in the sense that it
        % includes basically every possible trajectory that are attracted
        % onto the attractor. Hence, a perturbation at any part of the 
        % attractor is effectively "large". 
        start = a(randperm(length(a(k + 1 : end, 1)), 1), :) + rand(1, 3);
    end
