%--------------------------------------------------------------------------
% findAbsPitchZ_HUL_mod
% coded by Stephen Shum
% minor edits by George Chen
%
% Finds the absolute pitch and z-value using the provided data from the
% Pitch (V2) Laser Scanner. Uses L-1 Linear Regression for reduced
% sensitivity to outliers.
%
% This function is called by the main localization function
% ("localization.m") for the 1xICP+IMU+Planar and 1xICP+Planar methods.
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
%  if you want results plotted, specify the Applanix data filename
%
% Outputs:
% -laserTime: Timestamps for all laser scans
% -lsPitch: UN-filtered pitch results
% -lsZ: UN-filtered z results
% -cc: UN-filtered correlation coefficients
% -goodIdx: Logical indices for "good" *FILTERED* results...
%
% ... by sshum (23 July 2009)
%       edited (4 August 2009)

function [laserTime , lsPitch , lsZ , cc , goodIdx] ...
    = findAbsPitchZ_IMU_mod(xyScans,polarScans,laserTime,applanixDataFileName)

if nargin == 3
    showplots = 0;
elseif nargin == 4
    showplots = 1;
else
    error('Too many or not enough arguments');
end


% % filter scans using George's code ...
% % also account for the offset to the HUL Laser Scanner (in xyScans, only)
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
% %     valid_pts = filter_scan(xyScans{ii}, polarScans{ii}, 100, 5, 20, 5600);
%     polarScans{ii} = polarScans{ii}(valid_pts, :);
%     xyScans{ii} = xyScans{ii}(valid_pts, :);
% %    xyScans{ii} = xyScans{ii}(valid_pts, :)+repmat([85.37 -326.93],length(valid_pts),1);      % Applanix
% % THE LINES ABOVE AND BELOW ARE NOW CARRIED OUT IN doFindAbsPitchZ_HUL.m...
% %    xyScans{ii} = xyScans{ii}(valid_pts, :)+repmat([69.24
% %    356.39],length(valid_pts),1);       % HUL
end


% angles = [60 120]*pi/180;
angles = [pi/3 pi/2];   % set an angle boundary to look for 'horizontal' floor
% angles = [60-15, 90+15]*pi/180-120*pi/180; % for lower right pitch scanner (october hardware setup)
lambda = 1e-5;          % set a number to run Regularized Least Squares if necessary

lsPitch = zeros(length(xyScans),1);
lsZ = zeros(length(xyScans),1);
confid = zeros(length(xyScans),1);
cc = zeros(length(xyScans),1);
data_length = zeros(length(xyScans),1);

% Enter main loop ...
for ii = 1:length(xyScans)
%     fprintf(' Processing frame %d/%d...\n', ii, length(xyScans));
    [lsPitch(ii) lsZ(ii) confid(ii) cc(ii) data_length(ii)] ...
        = doFindAbsPitchZ_IMU(xyScans{ii},polarScans{ii},angles,lambda);          
end

% post-filter the results...
[goodIdx percFiltered] = filterResults(laserTime,lsPitch,30,lsZ,500);
Results = strcat('filtered out ',num2str(round(percFiltered*100)),'% of results')

newLaserTime = laserTime(goodIdx);
newLSpitch = lsPitch(goodIdx);
newLSz = lsZ(goodIdx);



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

timeApplanix = Applanix.data.group1.time(:,3);
gtPitch = Applanix.data.group1.attitude(:,2); 
gtZ = relPosition(:,3); 
clear data;

% find closest time stamps to UnfilteredLaserTime
for i = 1:length(laserTime)
    [val idx(i)] = min(abs(timeApplanix-laserTime(i)));
end
timeApplanixPitch = timeApplanix(idx);
gtPitch0 = gtPitch(idx);
gtZ0 = gtZ(idx);
clear idx;

% find closest time stamps to FilteredLaserTime
for i = 1:length(newLaserTime)
    [val idx(i)] = min(abs(timeApplanix-newLaserTime(i)));
end
newGTtime = timeApplanix(idx);
newGTpitch = gtPitch(idx);
newGTz = gtZ(idx);
clear idx;



% Plotting all results
figure(3),clf,hold all;
plot(timeApplanixPitch,gtPitch0,'.-');
plot(laserTime,lsPitch,'.-');
plot(newLaserTime,newLSpitch,'.-');        % offset included
xlabel('time'),ylabel('pitch (degrees)'),title('Pitch');
legend('Ground Truth','Unfiltered Result','Filtered Result');

figure(5),clf,hold all;
plot(timeApplanixPitch,gtZ0-gtZ0(1),'.-');
plot(laserTime,(lsZ-lsZ(1))/1000,'.-');
plot(newLaserTime,(newLSz-newLSz(1))/1000,'.-');
xlabel('time'),ylabel('Z (meters)'),title('Absolute Z');
legend('Ground Truth','Unfiltered Result','Filtered Result');


% percent of results filtered...
percFiltered = (length(lsPitch)-length(newLSpitch))/length(lsPitch)


% Plotting filtered results ...
figure(33),clf,hold all;
plot(newLaserTime,newLSpitch,'.-');
plot(newGTtime,newGTpitch,'.-');
%plot(timeApplanixPitch,gtPitch,'.-');
xlabel('time'),ylabel('pitch (degrees)');
title('Post-Filtered Pitch');
legend('Laser Scanner','Ground Truth');

figure(333),clf,hold all;
plot(newLaserTime,newLSpitch-newGTpitch,'.-');
xlabel('time'),ylabel('pitch (degrees)');
title('Post-Filtered Pitch Errors');

MSEpitch = mean((newLSpitch-newGTpitch).^2)
MSEdPitch = mean(( (newLSpitch(2:end)-newLSpitch(1:end-1))-(newGTpitch(2:end)-newGTpitch(1:end-1)) ).^2)


figure(55),clf,hold all;
plot(newLaserTime,(newLSz-newLSz(1))/1000,'.-');    % subtract first value for relative Z positions...
plot(newGTtime,newGTz-newGTz(1),'.-');
xlabel('time'),ylabel('Z (meters)');
title('PostFiltered Absolute Z');
legend('Laser Scanner','Ground Truth');

MSE_Z = mean((newLSz/1000-newLSz(1)/1000-newGTz+newGTz(1)).^2)
MSE_dZ = mean(( (newLSz(2:end)-newLSz(1:end-1))/1000-(newGTz(2:end)-newGTz(1:end-1)) ).^2)


end %EOF


