function [D_Train, D_test, D_cv] = split_data(D_raw, N_train, N_test, N_cv)

    ind = randsample(length(D_raw(1, :)), N_train + N_test + N_cv);
    D = D_raw(:, ind);
    
    D_Train     = D(:, 1 : N_train);
    D_test      = D(:, N_train + (1 : N_test));
    D_cv        = D(:, N_train + N_test + (1 : N_cv));

end