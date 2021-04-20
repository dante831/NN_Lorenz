function [code, W_star, b_star, W1_prime, W2_prime, b1_prime, b2_prime] = neural_mapping(prediction, net)

% adapted from https://www.mathworks.com/matlabcentral/answers/94001-how-can-i-manually-evaluate-my-data-to-validate-my-neural-network
% preprocess function
N_phase = net.inputs{1}.size;
if length(size(prediction)) == 3
    inputs = reshape(prediction, N_phase, length(prediction(1, 1, :)) * length(prediction(1, :, 1)));
else
    inputs = prediction;
end
for iii = 1:numel(net.inputs{1}.processFcns)
      inputs = feval( net.inputs{1}.processFcns{iii}, ...
          'apply', inputs, net.inputs{1}.processSettings{iii} );
end
code = tansig(net.IW{1} * inputs + net.b{1});
Yc = net.LW{2, 1} * code + net.b{2};
%Yc = net.LW{2, 1} * tansig(net.IW{1} * inputs + net.b{1}) + net.b{2};
for iii = 1:numel(net.outputs{2}.processFcns)
     Yc = feval( net.outputs{2}.processFcns{iii}, ...
          'reverse', Yc, net.outputs{2}.processSettings{iii} );
end
%max(max(Yc(:, 1:end - 1) - squeeze(D2(:, n, 2:end)))) % should be small.
%temp = code(:, 2 : end) - tansig(W_star * code(:, 1 : end - 1) + repmat(b_star, size(code(1, 2 : end)))); % should be small. 

W1 = net.IW{1};
W2 = net.LW{2, 1};
b1 = net.b{1};
b2 = net.b{2};
S_out = diag(net.outputs{2}.processSettings{1}.gain);
S_in = diag(net.inputs{1}.processSettings{1}.gain);
b_out = net.outputs{2}.processSettings{1}.xoffset;
b_in = net.inputs{1}.processSettings{1}.xoffset;

W1_prime = W1 * S_in;
W2_prime = S_out^-1 * W2;
b1_prime = - W1*(S_in * b_in + 1) + b1;
b2_prime = S_out^-1*(b2 + 1) + b_out;
W_star = W1_prime * W2_prime;
b_star = W1_prime * b2_prime + b1_prime;
%W_star = W1 *  S_in *  S_out^-1 * W2;
%b_star = W1 * (S_in * (S_out^-1 * (b2 + 1) + b_out - b_in) - 1) + b1;

% the previous operations are interesting to look at: 
% 1. preconditioning on the data: use mapminmax function to map inputs onto
% [0.0, 1.0]^N_phase space. Then, tanh(W1 * inputs + b1) maps these inputs
% onto [0.0, 1.0]^N_neuron space. This is the encoding process
% 2. then, the dynamical system reduces to a simple transformation in the
% code space: code_{t + 1} = tansig(W_star * code_{t} + b_star)
% 3. in the end, y vectors are mapped from the code space into phase space
% again, with x_T = W2 * y_{T-1} + b2, and then are stretched using the
% inverse of mapminmax
% 4. the pre- and post- processing of the data, which use mapminmax
% function, are of almost the same parameters. (this should definitely be
% the same, since in phase space, mappings are constrained on the
% attractor)
% 5. actually, the preprocessing is a little bit tricky...
% y_t = tansig(W1*(S_in*(x_t - b_in) - 1) + b1)
% x_t+1 = S_out^-1*(W2*y_t + b2 + 1) + b_out
% hence,
% y_t+1 = tansig(W1*(S_in*(S_out^-1*(W2*y_t + b2 + 1) + b_out - b_in) - 1) + b1)
% y_t+1 = tansig(...
%               W1*S_in*S_out^-1*W2*y_t + ...
%               W1*(S_in*(S_out^-1*(b2 + 1) + b_out - b_in) - 1) + b1 ...
%               )
% y_t+1 = tansig(W_star * y_t + b_star, where
% W_star = W1*S_in*S_out^-1*W2, 
% b_star = W1*(S_in*(S_out^-1*(b2 + 1) + b_out - b_in) - 1) + b1




