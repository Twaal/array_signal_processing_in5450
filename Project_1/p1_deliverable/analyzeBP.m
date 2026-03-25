function Result = analyzeBP(u,W)

% Function that fins -3 and -6 dB beamwidht of mainlobe and sidelobe level
%
% Input: u      : sin(theta) at which W is computed
%        W      : Beampattern   
%

% Strategy that is followed:
%
%   1: Find index of max-value, i.e. center of mainlobe. 
%      Function assumes only one max (i.e. no gratinglobes).
%   2: From center mainlobe, find start and stop of mainlobe
%   3: Find -3 and -6 dB width of mainlobe
%   4: Find max of response in sidelobe region

% 1:
[mlMax, iMax] = max(db(abs(W)));

% 2:
mlStart = iMax;
while abs(W(mlStart)) >= abs(W(mlStart - 1))
    mlStart = mlStart - 1;
end

mlStop = iMax;
while abs(W(mlStop)) >= abs(W(mlStop + 1))
    mlStop = mlStop + 1;
end

% 3:
uInd = mlStart:mlStop;
uTmp = u(uInd);

ind = find(db(abs(W(uInd))) >= mlMax - 3);
Result.Three_dB = asin(uTmp(ind(end))) - asin(uTmp(ind(1)));

ind = find(db(abs(W(uInd))) >= mlMax - 6);
Result.Six_dB = asin(uTmp(ind(end))) - asin(uTmp(ind(1)));

Result.maxSL = max(db(abs(W([1:mlStart mlStop:end])))) - mlMax;

