%--------------------------------------------------------------------------
% doFindAbsRollZ_HUL
% coded by Stephen Shum
%
% Calculates the absolute roll and z of the HG9900 IMU over time via
% fitting a line to the floor at each time step and seeing how the best-fit
% line of the floor changes over time.
%
% This function is called by the function findAbsRollZ_IMU_mod
% ("findAbsRollZ_IMU_mod.m").
%
% Inputs:
% -xyScan, polarScan: the input 2D laser scan in Cartesian coordinates
%                     (xyScan) and in polar coordinates (polarScan); the
%                     inputs 'xyScan' and 'polarScan' are assumed to have
%                     already been filtered by George's 'filterScan.m' code
% -prevPitch: estimated pitch at the time of the given roll data; if this
%             value is unknown, set prevPitch = 90
% -angles: an array specifying [min max] angles (in radians); laser scan
%          points within these angles will be kept and are considered part
%          of the region of interest where the floor should be
% -lambda: parameter for regularized least squares
%
% Outputs:
% -lsRoll: estimated absolute roll value for the given scan
% -lsZ: estimated absolute z value for the given scan
% -confid: confidence: 1 when -30 < pitch < 30; 0 otherwise
% -cc: correlation coefficient for the regularized least squares line fit
%
% ...by sshum (23 July 2009)
%       edited ... 5 August 2009

function [lsRoll lsZ confid cc] ...
            = doFindAbsRollZ_IMU(xyScan,polarScan,prevPitch,angles,lambda)

% Do filtering of scan for our purposes
xy_roll = polarFilter(xyScan,polarScan,angles);



% clusters  = cluster_by_lines(xy_roll'/1000, 0.1, .15);
% clusters2 = {};
% distances = [];
% min_cluster_size = 5;
% slopes = [-.1 .2];
% dist_eps = .1;
% 
% for j = 1:length(clusters)
%     if size(clusters{j}, 2) > min_cluster_size
%         p = polyfit(clusters{j}(1, :), clusters{j}(2, :), 1);
%         if p(1) > slopes(1) && p(1) < slopes(2)
%             clusters2 = {clusters2{:}, clusters{j}};
%             distances = [distances, abs(p(2)) / sqrt(p(1)^2 + 1)];
%         end
%     end
% end
% 
% if ~isempty(clusters2)
%     [distances, indices] = sort(distances, 'descend');
%     clusters2 = clusters2(indices);
%     floor_pts = clusters2{1};
% 
%     for j = 2:length(distances)
%         if distances(1) - distances(j) < dist_eps
%             floor_pts = [floor_pts, clusters2{j}];
%         else
%             break
%         end
%     end
%     
%     xy_roll = floor_pts'*1000;
% end



r = size(xy_roll,1);

% compensate for pitch
xy_roll(:,2) = xy_roll(:,2)*sind(prevPitch);

% calculate absolute pitch and absolute Z with respect to Laser Scanner
[lsRoll lsZ confid cc M] = calcRollandZ(xy_roll(1:round(r/2),:),lambda);

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





function [Roll Z conf cc M] = calcRollandZ(xy_roll,lambda)

M = solveRLS(xy_roll,lambda);
M = L1LinearRegression(xy_roll(:,1),xy_roll(:,2),[]);

m = M(1);   % slope
b = M(2);   % intercept

% see notes for derivation of below
Roll = atand(m);      % calculated an OFFSET

x1 = b/(-1/m-m);
y1 = -1/m * x1;
Z = norm([x1 y1]);  % this is Z_L (Z with respect to the laser scanner)

X = -326.93; % Applanix
Y = 179.94;

dZ = sign(X)*(abs(X) - abs(Y)*tand(Roll))*cosd(Roll);
Z = Z+dZ;


conf = 1;
if Roll > 30 || Roll < -30
    conf = 0;
end

% calculate correlation coefficient
cc = corrcoef(xy_roll);
cc = cc(1,2);

end %EOF
