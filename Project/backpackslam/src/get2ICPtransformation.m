%--------------------------------------------------------------------------
% get2ICPtransformation
% coded by George Chen
%
% Helper function for constructing a 6-DOF transformation and its
% covariance for the 2xICP case.
%
% This function is called only by the main localization function
% ("localization.m"). See localization.m for how this function is called.

function [u, uCov] = ...
    get2ICPtransformation(hulTransformation, ...
                          tz, ...
                          hulCov, ...
                          varTz, ...
                          rollInitial, ...
                          rollFinal, ...
                          dRollSD, ...
                          pitchInitial, ...
                          pitchFinal, ...
                          dPitchSD, ...
                          yawInitial)

rotInitial  = rpy2rot([rollInitial; pitchInitial; yawInitial]);
rotFinal    = rpy2rot([rollFinal; ...
                       pitchFinal; ...
                       yawInitial + hulTransformation(3)]);

localRot    = rotInitial' * rotFinal;
localRotRPY = decomposeRotationMatrix(localRot);

tx = hulTransformation(1);
ty = hulTransformation(2);

droll  = localRotRPY(1);
dpitch = localRotRPY(2);
dyaw   = localRotRPY(3);

varTx = hulCov(1, 1);
varTy = hulCov(2, 2);

varDroll  = dRollSD^2;
varDpitch = dPitchSD^2;
varDyaw   = hulCov(3, 3);

u    = [tx; ty; tz; droll; dpitch; dyaw];
uCov = diag([varTx; varTy; varTz; varDroll; varDpitch; varDyaw]);

end
