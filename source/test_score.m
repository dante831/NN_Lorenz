function scores = test_score(nets, D_cv, N_phase)

    
    if iscell(nets)
        scores = zeros(size(nets));
        for i = 1 : length(nets)
            scores(i) = sqrt(mean(sum(...
                (nets{i}(D_cv(1 : N_phase, :)) - D_cv(N_phase + 1 : end, :)).^2 ...
            )));
        end
    else
        scores = sqrt(mean(sum(...
            (nets(D_cv(1 : N_phase, :)) - D_cv(N_phase + 1 : end, :)).^2 ...
        )));
    end

end