function [t,a] = lorenz_synthetic(start, Nt, dt)

% 'f' is set of differential equations
% 'a' is array containing x, y, and z variables
% 't' is time variable

sigma = 10;
beta = 8/3;
rho = 28;

f = @(t,a) [-sigma*a(1, :) + sigma*a(2, :); ...
            rho*a(1, :) - a(2, :) - a(1, :) * a(3, :); ...
            -beta*a(3, :) + a(1, :) .* a(2, :)];
%[t,a] = ode45(f, [0 100], start);     % Runge-Kutta 4th/5th order ODE solver
% use the solver with "tspan" equals to [0 100] is unsuitable since it
% varies the evaluation time step internally 
[t,a] = ode45(f, (0 : Nt - 1) * dt, start); % Runge-Kutta 4th/5th order ODE solver
% the spatial increment is large if started from [100, 2, 1]. but as Lorenz pointed
% out in page 134 in his 1963 paper, the nature of the dissipative system
% makes sure that the solution will converge to the attractor
