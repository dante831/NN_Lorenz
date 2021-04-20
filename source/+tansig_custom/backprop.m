function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,1-exp(log(a.*a)));
end
