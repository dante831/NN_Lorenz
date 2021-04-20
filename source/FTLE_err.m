function error = FTLE_err(Lambda_ode, Lambda_nn)

    s = size(Lambda_ode);
    error = zeros(s);
    if length(s) == 2
        for m = 1 : s(1)
            for n = 1 : s(2)
                error(m, n) = rms(Lambda_ode{m, n} - Lambda_nn{m, n});
            end
        end
    elseif length(s) == 3
        for m = 1 : s(1)
            for n = 1 : s(2)
                for k = 1 : s(3)
                    error(m, n, k) = rms(Lambda_ode{m, n, k} - Lambda_nn{m, n, k});
                end
            end
        end
    end
    
end