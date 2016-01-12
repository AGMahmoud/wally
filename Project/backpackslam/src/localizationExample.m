%--------------------------------------------------------------------------
% localizationExample
% coded by George Chen
%
% This file shows how to run localization.m

clear; clc;

%% Set a bunch of settings for running localization.m

toroPath         = 'toro3d.exe';
% fileLogDir       = 'july 1\Cory 4th floor set 1 - Synchronized';
% fileLogDir       = '.\October 22\20091022-2';
fileLogDir       = '.\February 28, 2010\20100228-1';
outputDir        = '.\tmp';
outputFilePrefix = ...
    'feb28_set1_applanixInitial_2icp_imu_localRefine';

method                   = 2; % 0 => 1xICP+IMU+planar
                              % 1 => 1xICP+planar (DO NOT USE THIS! CHANCES
                              %      ARE THAT YOU ACTUALLY WANT TO USE 0
                              %      INSTEAD, i.e. 1xICP+IMU+planar)
                              % 2 => 2xICP+IMU
                              % 3 => 3xICP

useLocalRefinement       = 10; % how many frames apart for local refinement
                               % (must be an integer; set this to any
                               % integer less than 2 for no local
                               % refinement)

useOctoberHardwareConfig = 1; % either 1 (yes) or 0 (no)
sourceOfInitialRotation  = 1; % either 1 (Applanix) or 0 (InterSense IMU)

effectiveYawRange        = 15; % for the October horizontal upper left yaw
                               % scanner, we will only use this amount of
                               % the scanner's range (in meters; maximum:
                               % 30)

getGroundtruthOnly       = 0;  % either 1 (yes, only get the groundtruth so
                               % that we can determine what to set
                               % "burnInFrames" and "loopClosures" to) or 0
                               % (assumes that "burnInFrames" and
                               % "loopClosures" have been determined and
                               % are set to desired values)


%% Specify the number of initial laser frames to ignore:
% burnInFrames = 0; % if you don't know yet (i.e. you are trying to determine
%                   % this value by setting "getGroundtruthOnly" to 1), set
%                   % burnInFrames to 0--DO NOT SET IT TO SOME OTHER VALUE
%                   % (burnInFrames causes a number of frames to be skipped
%                   % when reading in laser scanner data--when we haven't yet
%                   % determined how much to skip, setting it to a nonzero
%                   % value will cause a skip!)
% burnInFrames = 49; % use this for July 1 set 1
% burnInFrames = 34; % use this for July 1 set 2
% burnInFrames = 900; % use this for Oct 22 set 1
% burnInFrames = 0; % use this for Oct 22 set 2, Feb 28 set 2, Feb 28 set 4
% burnInFrames = 5; % use this for Feb 28 set 3
burnInFrames = 51; % use this for Feb 28 set 1


%% Specify loop closures (in variable loopClosures):
% variable "loopClosures" is a matrix where each row specifies a loop
% closure between two poses (a negative index means counting from the end,
% e.g. -1 => last pose); so a row that says -1 1 means loop closure from
% the last node to the first node
%
% if you are trying to determine where the loop closures are, you can set
% this variable to whatever you want (it is unused)

% loopClosures = [-1 1]; % use this for all datasets up to Feb 28 EXCEPT
%                        % FOR Feb 28 set 1
loopClosures = [1250 1; -1 1]; % use this for Feb 28 set 1


%% Do localization
[applanixComparableOpenLoop, ...
 applanixComparableClosedLoop, ...
 applanix, ...
 applanixTime, ...
 hulTime, ...
 applanixRaw, ...
 applanixTimeRaw, ...
 hulLaserScans, ...
 vrLaserScans, ...
 vlLaserScans] = ...
    localization(method, useLocalRefinement, useOctoberHardwareConfig, ...
                 toroPath, fileLogDir, outputDir, outputFilePrefix, ...
                 sourceOfInitialRotation, loopClosures, burnInFrames, ...
                 effectiveYawRange, getGroundtruthOnly);


%% Make plots
if getGroundtruthOnly
    
    figure;
    plotPoses(applanix, 'r');
    legend('Ground truth');
    fprintf('\n');
    fprintf(['Look at variables "applanix" and "applanixTime" ' ...
             'for ground truth values subsampled to 10Hz.\n']);
    fprintf(['Look at variables "applanixRaw" and "applanixTimeRaw" ' ...
             'for ground truth values at 200Hz.\n']);
    fprintf(['REMARK: burnInFrames and loopClosures are specified ' ...
             'using indices of the 10Hz data, not the 200Hz data.\n']);
    fprintf('\n');
    
else
    
    % Plot open loop trajectory over ground truth
    figure;
    plotPoses(applanixComparableOpenLoop, 'b'); hold on;
    plotPoses(applanix, 'r'); hold off;
    legend('Estimated (open loop)', 'Ground truth');
    
    % Plot closed loop trajectory over ground truth
    figure;
    plotPoses(applanixComparableClosedLoop, 'b'); hold on;
    plotPoses(applanix, 'r'); hold off;
    legend('Estimated (closed loop)', 'Ground truth');
    
end
