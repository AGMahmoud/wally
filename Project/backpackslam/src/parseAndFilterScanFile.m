%--------------------------------------------------------------------------
% parseAndFilterScanFile
% original code by Nikhil Naikal
% modified by George Chen
%
% Parses and filters an input Hokuyo URG-04LX laser scan file; this file
% contains ALL laser scans over time (i.e. all laser scans for when the
% device was capturing data). The laser scan filtering parameters are the
% same as the input parameters to the function filterScan ("filterScan.m").
% See that file for what the filtering parameters are.
%
% The output (parsed and filtered) laser scans are presented in Cartesian
% coordinates and polar coordinates. A time stamp is also recorded for each
% laser scan.
%
% This function is used by the main localization function
% ("localization.m").
%
% Inputs:
% - filename: scan filename
% - offset: number of initial scans to skip
% - med_filt_size: for median filter applied to range values
% - threshold: range values from the polar scan are replaced by the
%              corresponding median-filtered value iff the two values
%              differ by more than this threshold
% - min_range: points closer than this from the origin are marked invalid
% - max_range: points farther than this from the origin are marked invalid
% - zupts: each 1x2 row specifies a start timestamp and end timestamp of
%          a ZUPT interval; laser scans in ZUPT intervals will be *ignored*
%
% Outputs:
% - xyScans: each scan in format [x, y] can be accessed using xy_scans{i}
% - polarScans: each scan in format [r, theta] can be accessed using
%               polar_scans{i}
% - timestamps: column vector of times

function [xyScans, polarScans, timestamps] = ...
    parseAndFilterScanFile(filename, offset, ...
                           medFiltSize, threshold, minRange, maxRange, ...
                           zupts)

if nargin == 6
    zupts = [];
end

% read in the scans
scans = load(filename);

% throw away first <offset> scans
scans = scans(1+offset:end, 53:734);

[numScans, numPtsPerScan] = size(scans);

% dump each scan into a cell
xyScans     = cell(numScans, 1);
polarScans  = cell(numScans, 1);
timestamps  = load(strcat(filename(1:end-4), '_TimeStampsSync.txt'));
timestamps  = timestamps(1+offset:end);

% deal with ZUPT's
if ~isempty(zupts)
    numZupts = size(zupts, 1);
    
    for i = 1:numZupts
        startZuptTime = zupts(i, 1);
        endZuptTime   = zupts(i, 2);
        
        removeIndices = timestamps >= startZuptTime & ...
                        timestamps <= endZuptTime;
        
        xyScans(removeIndices)    = [];
        polarScans(removeIndices) = [];
        timestamps(removeIndices) = [];
    end
end

% specifications from Hokuyo URG-04LX device
startAngle = -340*360/1024;
stopAngle  = 341*360/1024;
delta      = (stopAngle - startAngle)/(numPtsPerScan-1);
angles     = (startAngle:delta:stopAngle)';

for i = 1:numScans
    [xyScans{i}, polarScans{i}, valid] = ...
        filterScan([scans(i, :)', angles*pi/180], ...
                   medFiltSize, threshold, minRange, maxRange);
    
    xyScans{i}    = xyScans{i}(valid, :)'/1000;
    polarScans{i} = polarScans{i}(valid, :)';
    
    polarScans{i}(1, :) = polarScans{i}(1, :)/1000;
end

end