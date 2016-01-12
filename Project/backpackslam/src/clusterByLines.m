%--------------------------------------------------------------------------
% clusterByLines
% coded by George Chen
%
% Given a 2D laser scan in Cartesian coordinates (format: [x; y] specifying
% points in the laser scan), cluster the points into line segments. This
% function takes advantage of the fact that the points in actually ordered!
% In particular, when laser scan points come from the laser scanner, they
% are ordered radially so that as you go through the points, you sweep
% through the field of view in one pass.
%
% Thus, when clustering points into lines, this function is just looking at
% whether a sequence of consecutive points form a line, and if the next
% point in the scan is too far away, it means that that new point should
% start a new line segment.
%
% This function is called only by the doFindAbsPitchZ_IMU function
% ("doFindAbsPitchZ_IMU.m"), which is used only by the 1xICP planar methods
% for finding where the planar floor is--by line fitting and finding the
% line segment that should correspond to the floor!
%
% Inputs:
% -xyScan: 2D laser scan points in format [x; y] where the points are
%          ordered the way they come from the laser scanner
% -distThreshold: if the next point in <xyScan> is more than this threshold
%                 away from the previous point, declare that we need to
%                 start a new line
% -errorThreshold: if adding the next point in <xyScan> to the current line
%                  results in the best fit line having an error (norm of
%                  residuals) larger than this error threshold, declare
%                  that we need to start a new line
% Output:
% -clusters: cell array where each element in the cell array is a separate
%            cluster; each cluster is stored as a list of 2D laser points
%            in format [x; y]
%            *Remark: Concatenating all the clusters gives the originally
%            laser scan

function clusters = clusterByLines(xyScan, distThreshold, errorThreshold)

N = size(xyScan, 2);

if N < 2
    clusters = {xyScan};
    return
end

clusters = {};
currentCluster = xyScan(:, 1);

for i = 2:N
    last_added = currentCluster(:, end);
    new_point  = xyScan(:, i);
    
    if norm(last_added - new_point) > distThreshold
        % new point is too far away
        clusters = {clusters{:}, currentCluster};
        currentCluster = new_point;
    else
        [p, S] = polyfit([currentCluster(1, :), new_point(1)], ...
                         [currentCluster(2, :), new_point(2)], 1);
        average_error = S.normr;
        
        if average_error > errorThreshold
            % new point doesn't fit the current line very well
            clusters = {clusters{:}, currentCluster};
            currentCluster = new_point;
        else
            currentCluster = [currentCluster, new_point];
        end
    end
end

clusters = {clusters{:}, currentCluster};

end