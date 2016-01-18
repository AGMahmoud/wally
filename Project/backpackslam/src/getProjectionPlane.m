%--------------------------------------------------------------------------
% getProjectionPlane
% coded by George Chen
%
% For two given scans (in 3D), we find whether to project them onto the XY,
% YZ, or XZ plane and return the projected scans along with which plane we
% projected to.
%
% This function is only called by the main localization function
% ("localization.m").
%
% Inputs:
% - scan1 and scan2: scan data (in 3D) from two different times
% Outputs:
% - plane: which plane the algorithm decides to project scan1 and scan2 to,
%          i.e. one of 'XY', 'YZ', or 'XZ'
% - projectedDataStart: scan1 projected to the plane specified by 'plane'
% - projectedDataEnd: scan2 projected to the plane specified by 'plane'

function [projectedDataStart, projectedDataEnd, plane] ...
    = getProjectionPlane(scan1, scan2)

projectXY = @(points) points([1 2], :);
projectYZ = @(points) points([2 3], :);
projectXZ = @(points) points([1 3], :);

xyScan = projectXY(scan1);
yzScan = projectYZ(scan1);
xzScan = projectXZ(scan1);

[hull, xyArea] = convhull(xyScan(1, :), xyScan(2, :));
[hull, yzArea] = convhull(yzScan(1, :), yzScan(2, :));
[hull, xzArea] = convhull(xzScan(1, :), xzScan(2, :));

% set 'plane' to be whichever results in the largest convex hull area
if xyArea >= yzArea && xyArea >= xzArea
    projectedDataStart = xyScan;
    projectedDataEnd   = projectXY(scan2);
    plane              = 'XY';
elseif yzArea >= xyArea && yzArea >= xzArea
    projectedDataStart = yzScan;
    projectedDataEnd   = projectYZ(scan2);
    plane              = 'YZ';
elseif xzArea >= xyArea && xzArea >= yzArea
    projectedDataStart = xzScan;
    projectedDataEnd   = projectXZ(scan2);
    plane              = 'XZ';
end

end
