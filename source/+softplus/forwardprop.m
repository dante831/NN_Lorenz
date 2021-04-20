function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP Forward propagate derivatives from input to output.
  da = bsxfun(@times,dn,1-1./exp(a));
end

  %da = bsxfun(@times,dn,1-(a.*a)); % tansig

