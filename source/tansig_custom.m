function a = tansig_custom(n,varargin)

if nargin > 0
    n = convertStringsToChars(n);
end

if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = tansig_custom.apply(n);

