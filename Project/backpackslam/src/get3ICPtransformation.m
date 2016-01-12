%--------------------------------------------------------------------------
% get3ICPtransformation
% coded by George Chen
%
% Helper function for constructing a 6-DOF transformation and its
% covariance given three 3-DOF transformations and their corresponding
% covariance matrices.
%
% This function is called only by the main localization function
% ("localization.m"). See localization.m for how this function is called.
%
% Remarks:
%    If you look at the code below, you will notice that the
%    xzPlaneTransformation's angle is negated. The reason for this is as
%    follows: In a right-handed x-y-z coordinate system, apply the
%    right-hand rule to the positive x and positive z axes and you'll
%    notice that the rotation is about the NEGATIVE y axis rather than the
%    (desired) positive y axis, so a negation is needed.

function [u, uCov] = ...
    get3ICPtransformation(xyPlaneTransformation, ...
                          yzPlaneTransformation, ...
                          xzPlaneTransformation, ...
                          xyPlaneTransformationCov, ...
                          yzPlaneTransformationCov, ...
                          xzPlaneTransformationCov, ...
                          tz, ...
                          varTz)

tx = xyPlaneTransformation(1);
ty = xyPlaneTransformation(2);

droll  = yzPlaneTransformation(3);
dpitch = -xzPlaneTransformation(3);
dyaw   = xyPlaneTransformation(3);

varTx = xyPlaneTransformationCov(1, 1);
varTy = xyPlaneTransformationCov(2, 2);

varDroll  = xzPlaneTransformationCov(3, 3);
varDpitch = yzPlaneTransformationCov(3, 3);
varDyaw   = xyPlaneTransformationCov(3, 3);

u    = [tx; ty; tz; droll; dpitch; dyaw];
uCov = diag([varTx; varTy; varTz; varDroll; varDpitch; varDyaw]);

end
