%--------------------------------------------------------------------------
% getIndicesOfPosesCloseToSomePosition
% coded by George Chen
%
% Gets indices in a list of poses (in format [x; y; z; roll; pitch; yaw])
% where the position of a pose is close to some specified position by some
% threshold (distance used: Euclidean norm).
%
% This function is meant as a tool to help identify loop closure events. In
% particular, currently no other function actually calls this function.
%
% Inputs:
% -poses: list of poses in format [x; y; z; roll; pitch; yaw]; we will
%         search through this list
% -x, y, z: a specified position; we want to find points in the list of
%           poses that are close to this specified position in Euclidean
%           distance
% -threshold: a pose in <poses> is declared "close to" the specified point
%             if the Euclidean norm between the pose's position and the
%             specified point is less than this threshold value;
%             THIS ARGUMENT IS OPTIONAL (DEFAULT VALUE: 0.005)
%
% Output:
% For each point in the list of poses that is close to the specified point,
% this function will print out:
% (1) The index of that point in the list of poses (i.e. the index of the
%     point in input <poses>)
% (2) What the position of the pose is
% (3) How far away this pose's position is to the specified point
%    (Euclidean distance)

function getIndicesOfPosesCloseToSomePosition(poses, x, y, z, threshold)

if nargin == 4
    threshold = .005; % 5 millimeters--assuming poses, x, y, z are
                      % specified in meters
end

numPoses = size(poses, 2);

distances(1:3, :) = poses(1:3, :) - repmat([x; y; z], 1, numPoses);
distances = sqrt(dot(distances, distances)); % now distances is 1 by
                                             % numPoses, where distances(i)
                                             % specifies how close pose i
                                             % is to position x,y,z

for i = 1:numPoses
    if distances(i) < threshold
        fprintf(['Index %d: position at index is (%f, %f, %f), ' ...
                 'which is %f away from (%f, %f, %f)\n'], ...
                i, poses(1, i), poses(2, i), poses(3, i), ...
                distances(i), x, y, z);
    end
end

end