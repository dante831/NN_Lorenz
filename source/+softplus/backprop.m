function dn = backprop(da,n,a,param)
%POSLIN.BACKPROP Backpropagate derivatives from outputs to inputs
  dn = bsxfun(@times,da,1-1./exp(a));
  %dn = bsxfun(@times,da,1./(1 + exp(-n))); % the same thing
end
  
