function W = beampattern(xpos, kx, weights)
% Function that computes a ULA beampattern
%
% Input: xpos   : x-position of elements
%        kx     : 2*pi/lambda*sin(theta) to be computed
%        weights: Weighting of each element
% 
% Output:  W    : beampattern


% Ensuring all vectors are column vectors
xpos = xpos(:);
weights = weights(:); 
kx = kx(:);
        

W = exp(1j*kx.*xpos.') * weights;
        