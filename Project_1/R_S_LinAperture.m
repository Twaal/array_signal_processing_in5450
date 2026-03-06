function [Resp, normResp] = R_S_LinAperture(apX, apZ, X, Z, lambda, varargin)

% Function that calculates the Rayleigh-Sommerfelt integral formula for a
% linear aperture D with coordinates [apX, apZ] at the positions [X, Z]. 
% 
% Input variables:
%           apX         : vector of x-coordinates to the linear aperture [m]
%           apZ         : vector of z-coordinates to the linear aperture [m]
%           X           : vector or matrix of x-coordinates of obs. point [m]
%           Z           : vector or matrix of x-coordinates of obs. point [m]
%           lambda      : Wavelength used
%     Optional
%           A0          : possible weightning of points in aperture. Same size as apX and apZ
%
% Output variables:
%           Resp    : Response calculated in points X, Z
%           normResp: Response normalized by 1/sqrt(r). Since 1D array,
%                       power falls off with 1/r (Cyl.coord).
%


% Making sure variables have correct dimensions
apX = apX(:);      % Row vector
apZ = apZ(:);      % Row vector

[m,n] = size(X);
X = X(:);          % Row vector. Vectorizes X in case of matrix 
Z = Z(:);          % Row vector. Vectorizes X in case of matrix 

% Define weighting of aperture if not given
if nargin < 6
    A0 = ones(size(apX)); A0 = A0 / sum(A0);
else
    A0 = varargin{1};
end

% Defining k
k = 2*pi/lambda;

% Calculating radius to each pair of points
Rad = sqrt( (apX-X').^2 + (apZ-Z').^2 );

% Calculating cos of angle to each observarion points
cosTheta = (apZ-Z')./Rad;

% Solving the Rayleigh-Sommerfelt equation
Resp  = 1/(lambda*1i) * (A0.' * ( (exp(1i*k*Rad)./Rad) .* cosTheta ) );

Resp = reshape(Resp,m,n);

% Finding index of apX closest to zero
[~, s2] = min(abs(apX));
% Correcting for amplitude drop due to distance. Since line aperture,
% cylindrical symmetry, and power drops as 1/r. Amplitude drop as 1/sqrt(r)
normResp = Resp .* sqrt(reshape(Rad(s2,:),m,n));
