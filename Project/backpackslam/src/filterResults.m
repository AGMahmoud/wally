%--------------------------------------------------------------------------
% filterResults
% coded by Stephen Shum
%
% Filters out estimates where the derivative | dAngle/dt | > angleThres.
% If a 4th and 5th argument are provided (presumably the Z-estimates),
% then it will also filter out estimates where dZ/dt > zThres.
%
% This function is used by functions findAbsPitchZ_HUL_mod
% ("findAbsPitchZ_HUL_mod.m") and findAbsRollZ_HUL_mod
% ("findAbsRollZ_HUL_mod.m").
%
% Inputs:   'laserTime'     - timestamps corresponding to each estimate
%           'lsAngle'       - estimates corresponding to each time stamp
%           'angleThres'    - threshold that constrains the above estimates
%                             as described above.
%
% Optional Inputs:  'lsZ' & 'zThres' can specify another set of estimates 
%                   and threshold value to add an additional constraint
%                   to this filter.
%
% Output:   'goodIdx'       - the logical indices of the values that meet the
%                             specified constraints.
%           'percFiltered'  - the proportion of results filtered out.
%
%
% ... by sshum (6 August 2009)

function [goodIdx percFiltered] = filterResults(laserTime,lsAngle,angleThres,lsZ,zThres)

if nargin < 3
    error = 'Must have at least 3 arguments';
    help filterResults3;
    goodIdx = [];
    return;
elseif nargin == 5
    newLSz = lsZ;
    thresZ1 = zThres;
else
    newLSz = zeros(length(laserTime),1);
    thresZ1 = Inf;
end

newLaserTime = laserTime;
newLSpitch = lsAngle;
thresP1 = angleThres;

goodIdx = true(size(newLSpitch));
for jj = 2:length(newLSpitch)
    % dP/dt <= thresP1 && dZ/dt <= thresZ1
    if abs((newLSpitch(jj)-newLSpitch(jj-1))/(newLaserTime(jj)-newLaserTime(jj-1))) > thresP1 ...
            || abs((newLSz(jj)-newLSz(jj-1))/(newLaserTime(jj)-newLaserTime(jj-1))) > thresZ1
        goodIdx(jj) = false;
        newLSpitch(jj) = newLSpitch(jj-1);
        newLSz(jj) = newLSz(jj-1);
    end
end

% unnecessary...but whatever
newLaserTime = newLaserTime(goodIdx);
newLSpitch = newLSpitch(goodIdx);
newLSz = newLSz(goodIdx);

percFiltered = (length(lsAngle)-length(newLSpitch))/length(lsAngle);

end %EOF


