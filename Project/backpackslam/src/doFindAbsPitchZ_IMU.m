%--------------------------------------------------------------------------
% doFindAbsPitchZ_HUL
% coded by Stephen Shum
%
% Calculates the absolute pitch and z of the HG9900 IMU over time via
% fitting a line to the floor at each time step and seeing how the best-fit
% line of the floor changes over time.
%
% This function is called by the function findAbsPitchZ_IMU_mod
% ("findAbsPitchZ_IMU_mod.m").
%
% Inputs:
% -xyScan, polarScan: the input 2D laser scan in Cartesian coordinates
%                     (xyScan) and in polar coordinates (polarScan); the
%                     inputs 'xyScan' and 'polarScan' are assumed to have
%                     already been filtered by George's 'filterScan.m' code
% -angles: an array specifying [min max] angles (in radians); laser scan
%          points within these angles will be kept and are considered part
%          of the region of interest where the floor should be
% -lambda: parameter for regularized least squares
%
% Outputs:
% -lsPitch: estimated absolute pitch value for the given scan
% -lsZ: estimated absolute z value for the given scan
% -confid: confidence: 1 when 45 < pitch < 85; 0 otherwise
% -cc: correlation coefficient for the regularized least squares line fit
% -data_length: number of floor points found
% -floor_pts: floor points in format [x; y]; these are a subset of input
%             xyScan
%
% ...by sshum (4 August 2009)
%       edited (12 August 2009)

function [lsPitch lsZ confid cc data_length floor_pts] ...
            = doFindAbsPitchZ_IMU(xyScan,polarScan,angles,lambda)

% Do filtering of scan for our purposes
xy_pitch = polarFilter(xyScan,polarScan,angles);



clusters  = clusterByLines(xy_pitch'/1000, 0.1, .15);
clusters2 = {};
distances = [];
min_cluster_size = 5;
slopes = [-.1 .8];
dist_eps = .1;

for j = 1:length(clusters)
    if size(clusters{j}, 2) > min_cluster_size
        p = polyfit(clusters{j}(1, :), clusters{j}(2, :), 1);
        if p(1) > slopes(1) && p(1) < slopes(2)
            clusters2 = {clusters2{:}, clusters{j}};
            distances = [distances, abs(p(2)) / sqrt(p(1)^2 + 1)];
        end
    end
end

if ~isempty(clusters2)
    [distances, indices] = sort(distances, 'descend');
    clusters2 = clusters2(indices);
    floor_pts = clusters2{1};

    for j = 2:length(distances)
        if distances(1) - distances(j) < dist_eps
            floor_pts = [floor_pts, clusters2{j}];
        else
            break
        end
    end
    
    xy_pitch = floor_pts'*1000;
else
    floor_pts = xy_pitch'/1000;
end



data_length = size(xy_pitch,1);

% calculate absolute pitch and absolute Z with respect to Laser Scanner
[lsPitch lsZ confid cc] = calcPitchandZ(xy_pitch,lambda);
end %EOF





function newScan = polarFilter(xyScan,polarScan,angles)

validMinIdx = find(polarScan(:,2)>angles(1));

xyScan = xyScan(validMinIdx,:);
polarScan = polarScan(validMinIdx,:);

validMaxIdx = find(polarScan(:,2)<angles(2));

xyScan = xyScan(validMaxIdx,:);
polarScan = polarScan(validMaxIdx,:);

validMinDistIdx = find(polarScan(:,1)>1000);

xyScan = xyScan(validMinDistIdx,:);
polarScan = polarScan(validMinDistIdx,:);

validMaxDistIdx = find(polarScan(:,1)<3000);
newScan = xyScan(validMaxDistIdx,:);
end %EOF



function M = solveRLS(data,lambda)
% solve the regularized least squares problem
last = size(data,1);

Xmat = data(end-last+1:end,1);
Xmat = [Xmat ones(length(Xmat),1)];
Yvec = data(end-last+1:end,2);

M = (Xmat'*Xmat + lambda*eye(2))\(Xmat'*Yvec);
end %EOF



function [Pitch Z conf cc] = calcPitchandZ(xy_pitch,lambda)

M = solveRLS(xy_pitch,lambda);
% Use L1LinearRegression instead?
M = L1LinearRegression(xy_pitch(:,1),xy_pitch(:,2),[]);

m = M(1);   % slope
b = M(2);   % intercept

% see documentation for derivation of below
% here, we include 3.855 degree offset
Pitch = atand(1/m)+3.855;

x1 = b/(-1/m-m);
y1 = -1/m * x1;
Z = norm([x1 y1]);      % if we did not translate previously, this is laser scanner Z.

X = -326.93; % Applanix
Y = 85.37;

dZ = sign(X)*(abs(X)-abs(Y)*tand(90-Pitch))*sind(Pitch);
Z = Z+dZ;



% does the offset change our estimate of Z?
% Test: -rotate two points on y = mx+b by -3.855 degrees
%           (see notes for why it is negative)
%       -find new line ... (\tilde{m), \tilde{b})
%       -calculate a new Z
theta = -3.855;
Rot = [cos(theta) -sin(theta); sin(theta) cos(theta)];
pt1 = Rot * [x1; y1];               % rotate points ...
pt2 = Rot * [0; b];

m2 = (pt2(2)-pt1(2))/(pt2(1)-pt1(1));   % new slope
b2 = pt2(2)-m2*pt2(1);                  % new intercept

x2 = b2/(-1/m2-m2);                 % get Z ...
y2 = -1/m2 * x2;
Z2 = norm([x2 y2]);



conf = 1;
if Pitch > 85 || Pitch < 45
    conf = 0;
end


% calculate correlation coefficient
cc = corrcoef(xy_pitch);
cc = cc(1,2);

end %EOF
