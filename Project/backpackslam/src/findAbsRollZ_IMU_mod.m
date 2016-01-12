%--------------------------------------------------------------------------
% findAbsRollZ_HUL_mod
% coded by Stephen Shum
% minor edits by George Chen
%
% Finds the absolute roll and z-value using the provided data from the
% Roll (V1) Laser Scanner. Uses L-1 Linear Regression for reduced
% sensitivity to outliers.
%
% This function is called by the main localization function
% ("localization.m") for the 1xICP+Planar method.
%
% Code Dependencies - 'Common\Applanix Correction (Vasiliy)\*'
%                   - 'L1LinearRegression.m'
%
% Inputs:
% -xyScans, polarScans, laserTime:
%  outputs of parseAndFilterScanFile or parseAndFilterScanFileUtm30lx;
%  assumes that the inputs 'xy_scan' and 'polar_scan' have already been
%  filtered by George's 'filterScan.m' code.
%
% Optional Input:
% -applanixDataFileName:
%  if you want results plotted, specify the Applanix data filename;
%  otherwise just put an empty string ''
% -pitchEst: [pitchTime pitchLS] where both are column vectors;
%            This provides a pitch estimate so as to compensate for the 
%            effects of a pitched person...
%
% Outputs:
% -laserTime: Timestamps for all laser scans
% -lsRoll: UN-filtered roll results
% -lsZ: UN-filtered z results
% -cc: UN-filtered correlation coefficients
% -goodIdx: Logical indices for "good" *FILTERED* results...
%
% ... by sshum (24 July 2009)
%               edited 3 August 2009

function [laserTime, lsRoll, lsZ, cc, goodIdx] ...
    = findAbsRollZ_IMU_mod(xyScans,polarScans,laserTime,applanixDataFileName,pitchEst)

if nargin == 0
    error = 'Must specify a laserDataFileName!'
    help findAbsRollZ_HUL
    return;
elseif nargin == 3
    showplots = 0;
    pitchEst = []
elseif nargin == 4
    showplots = 1;
    pitchEst = []
elseif nargin == 5
    if applanixDataFileName
        showplots = 1;    
    else
        showplots = 0;
    end
end


% filter scans using George's code and previous pitch estimates ...
for ii = 1:length(xyScans)
    xyScan    = xyScans{ii};
    polarScan = polarScans{ii};
    
    % convert meters to millimeters
    xyScan          = xyScan*1000;
    polarScan(1, :) = polarScan(1, :)*1000;
    
    xyScans{ii}    = xyScan';
    polarScans{ii} = polarScan';
    
%     [xyScans{ii}, polarScans{ii}, valid_pts] = ...
%         filter_scan2(polarScans{ii}, 7, 200, 20, 5600);
%     valid_pts = filter_scan(xyScans{ii}, polarScans{ii}, 100, 5, 20, 5600);
%     xyScans{ii} = xyScans{ii}(valid_pts, :);
%     polarScans{ii} = polarScans{ii}(valid_pts, :);
end


lambda = 1e-5;          % set parameter for running regularized least squares
angles = [pi/3 pi/2];   % set an angle boundary to look for 'horizontal' floor

lsRoll = zeros(length(xyScans),1);
lsZ = zeros(length(xyScans),1);
confid = zeros(length(xyScans),1);
cc = zeros(length(xyScans),1);

% Enter main loop ...
for ii = 1:length(xyScans)
    
    prevPitch = 90;
    if pitchEst             % Compensate for pitch
        [val idx] = min(abs(pitchEst(:,1)-laserTime(ii)));
        prevPitch = pitchEst(idx,2);
    end
    
    [lsRoll(ii) lsZ(ii) confid(ii) cc(ii)] ...
        = doFindAbsRollZ_IMU(xyScans{ii},polarScans{ii},prevPitch,angles,lambda);    
end

% post-filter the results...
[goodIdx percFiltered] = filterResults(laserTime,lsRoll,60,lsZ,500);
Results = strcat('filtered out ',num2str(round(percFiltered*100)),'% of results')

newLaserTime = laserTime(goodIdx);
newLSroll = lsRoll(goodIdx);
newLSz = lsZ(goodIdx);
newCC = cc(goodIdx);


% plot?
if ~showplots
   return; 
end



% % % PLOT RESULTS =======================================================

% % Extract Applanix timestamps and data
Applanix = load(applanixDataFileName);

% Remove the zupts (vasiliy's code)
Applanix.data = smoothPath(Applanix.data, laserTime);
close 102;
close 103;

numpoints = size(Applanix.data.group1.position,1);
relPosition = Applanix.data.group1.position - repmat(Applanix.data.group1.position(1,:), numpoints, 1);
%[relPosition, utmPosition] = convertPosition(Applanix.data.group1.position(:,1:3), 1);

timeApplanix = Applanix.data.group1.time(:,3);
gtRoll = Applanix.data.group1.attitude(:,1); 
gtZ = relPosition(:,3); 
clear data;

% find closest time stamps to UnfilteredLaserTime
for i = 1:length(laserTime)
    [val idx(i)] = min(abs(timeApplanix-laserTime(i)));
end
timeApplanixPitch = timeApplanix(idx);
gtRoll0 = gtRoll(idx);
gtZ0 = gtZ(idx);
clear idx;

% find closest time stamps to FilteredLaserTime
for i = 1:length(newLaserTime)
    [val idx(i)] = min(abs(timeApplanix-newLaserTime(i)));
end
newGTtime = timeApplanix(idx);
newGTroll = gtRoll(idx);
newGTz = gtZ(idx);




% Plotting unfiltered results
figure(3),clf,hold all;
plot(laserTime,lsRoll,'.-');
plot(timeApplanixPitch,gtRoll0,'.-');
xlabel('time'),ylabel('Roll (degrees)'),title('Unfiltered Roll');
legend('Laser Scanner','Ground Truth');

figure(5),clf,hold all;
plot(laserTime,(lsZ-lsZ(1))/1000,'.-');
plot(timeApplanixPitch,gtZ0-gtZ0(1),'.-');
xlabel('time'),ylabel('Z (meters)'),title('Unfiltered Absolute Z');
legend('Laser Scanner','Ground Truth');


% percent of results filtered...
percFiltered = (length(lsRoll)-length(newLSroll))/length(lsRoll)


figure(33),clf,hold all;
plot(newLaserTime,newLSroll-(mean(newLSroll)-mean(newGTroll)),'.-');
%plot(newLaserTime,newLSroll,'.-');
plot(newGTtime,newGTroll,'.-');
%plot(timeIntersense,iRoll,'.-');
%plot(timeApplanixPitch,gtPitch,'.-');
xlabel('time'),ylabel('Roll (degrees)');
title('Post-Filtered Roll');
legend('Laser Scanner','Ground Truth');

MSEroll = mean((newLSroll-mean(newLSroll)-newGTroll+mean(newGTroll)).^2)
%MSEroll = mean((newLSroll-newGTroll).^2)
MSEdRoll = mean(( (newLSroll(2:end)-newLSroll(1:end-1))-(newGTroll(2:end)-newGTroll(1:end-1)) ).^2)
meanOffset = mean(newLSroll)-mean(newGTroll)

figure(55),clf,hold all;
plot(newLaserTime,(newLSz-newLSz(1))/1000,'.-');
plot(newGTtime,newGTz-newGTz(1),'.-');
xlabel('time'),ylabel('Z (meters)');
title('PostFiltered Absolute Z');
legend('Laser Scanner','Ground Truth');

MSE_Z = mean((newLSz/1000-newLSz(1)/1000-newGTz+newGTz(1)).^2)
MSEpitchZ2 = mean((newLSz/1000-mean(newLSz)/1000-newGTz+mean(newGTz)).^2);

MSE_dZ = mean(( (newLSz(2:end)-newLSz(1:end-1))/1000-(newGTz(2:end)-newGTz(1:end-1)) ).^2)

meanOffset = mean(newLSz/1000)-mean(newGTz);
startOffset = newLSz(1)/1000-newGTz(1);


end %EOF

