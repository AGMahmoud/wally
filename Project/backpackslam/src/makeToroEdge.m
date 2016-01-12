%--------------------------------------------------------------------------
% makeToroEdge
% coded by George Chen
%
% Makes an edge (a graph edge for a TORO input graph) for use with the
% 'writeInputForTORO' function ("Common\TORO\writeInputForTORO.m").
%
% This function is only used by the main localization function
% ("localization.m").
%
% Inputs:
% - pose1Idx/pose2Idx: indices of pose 1 and pose 2 (starting from 1 and
%                      not 0) into the list of poses that will be fed to
%                      TORO
% - transformation: 6-DOF transformation in format
%                   [tx; ty; tz; droll; dpitch; dyaw] that takes pose 2 to
%                   pose 1
% - transformationCovariance: covariance for the supplied transformation
%
% Output:
% - edge: edge for use with the function 'writeInputForTORO'


function edge = makeToroEdge(pose1Idx, pose2Idx, ...
                             transformation, transformationCovariance)
edge.source                   = pose1Idx;
edge.destination              = pose2Idx;
edge.transformation           = transformation;
edge.transformationCovariance = transformationCovariance;

end