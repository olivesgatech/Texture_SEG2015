% This function calculates the Kullback-Leibler divergence between two 
% distributions (histograms) 
function [KLDivergence] = Compute_KLD(X1,X2,varargin)
%   Input:    
%            X1, X2      - histograms
%   varargin:            - 'sym'
%                        - 'js'
%   
%   Output:   
%            KLDivergence  - distance between the two histograms.
%            
%   Usage:
%   KLD(X1,X2) is calculated by
%   sum[X1(i).* log2(X1(i)/X2(i))] 
%
%   or
%
%   KLD(X1,X2,'sym') 
%   gives the symmetric variant of the Kullback-Leibler divergence, given by 
%   [KLD(X1,X2)+KLD(X2,X1)]/2
%
%   or
%
%   KLD(X1,X2,'js') 
%   gives the Jensen-Shannon divergence, given by
%   [KLD(X1,Q)+KLD(X2,Q)]/2, where Q = (X1+X2)/2  

if ~isempty(varargin)
    switch varargin{1}
        case 'sym'
            d1 = sum(X1.*log2(X1+eps)-X1.*log2(X2+eps));
            d2 = sum(X2.*log2(X2+eps)-X2.*log2(X1+eps));
            d = (d1+d2)/2;
        case 'js'
            Q = (X1+X2)/2;
            d1 = sum(X1.*(log2(X1+eps)-log2(Q+eps)));
            d2 = sum(X2.*(log2(X2+eps)-log2(Q+eps)));
            d = (d1+d2)/2;
        otherwise
            error('Unknown parameter...');
    end
else
    d = sum(X1 .* (log2(X1+eps)-log2(X2+eps)));
end    
KLDivergence = d; 