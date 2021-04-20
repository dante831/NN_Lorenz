function D = gen_data_on_attractor_Henon(N_set, Nt)


    k = 2000; % data before this indice are abandoned to cut off transient trajectories
    D = zeros(4, (Nt - k) * N_set);
    %D = [];
    start = [1, -0.2];
    
    for i = 1 : N_set
        if mod(i, 100) == 0
            disp(['i = ', num2str(i), '/', num2str(N_set)]);
        end
        %start = (rand(1, 3) - [0.5, 0.5, 0]) * 2 .* [20, 25, 50];
        a = henon_synthetic(start, Nt);
        
        %ind = find(a(k : end - 1, 1) > 0);
        %D = [D, [a(k - 1 + ind, :), a(k + ind, :)]'];
        
        D(:, (Nt - k) * (i - 1) + 1 : (Nt - k) * i) = [a(k : end - 1, :), a(k + 1 : end, :)]';
        
        % add random perturbation on the start of the next trajectory
        start = a(randperm(length(a(k + 1 : end, 1)), 1), :) + rand(1, 2) * 0.01;
    end
    