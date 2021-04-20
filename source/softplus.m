function a = softplus(n, varargin)

if nargin > 0
    n = convertStringsToChars(n);
end

if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = softplus.apply(n);

%{
n = -5:0.1:5;
a = softplus(n);
plot(n,a)
%}