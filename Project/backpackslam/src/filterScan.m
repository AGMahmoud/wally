%--------------------------------------------------------------------------
% filterScan
% coded by George Chen
%
% This function is a low-level, clean-up procedure for laser scans
% (essentially a low pass filter). It applies a median filter to a given 2D
% laser scan (in polar coordinates). The output filtered scan is the same
% as the original scan except that each point in the original scan that
% differs by more than some threshold from the corresponding point in the
% median-filtered scan gets replaced by the median-filtered value.
% Basically, this means that "outlier" values are replaced by
% median-filtereed values but "inlier" values are untouched. Lastly, points
% less than some minimum distance away from the origin and points farther
% than some maximum distance away from the origin are declared INVALID. We
% do not remove invalid points from the filtered scan; rather, we just
% inform the user which points have ranges that are too small or too large.
%
% This function is used only by functions parseAndFilterScanFile
% ("parseAndFilterScanFile.m") and parseAndFilterScanFileUtm30lx
% ("parseAndFilterScanFileUtm30lx.m").
%
% Inputs:
% - polar_scan: Nx2 vector of format [range, bearing] specifying N points
% - med_filt_size: for median filter applied to range values
% - threshold: range values from the polar scan are replaced by the
%              corresponding median-filtered value iff the two values
%              differ by more than this threshold
% - min_range: points closer than this from the origin are marked invalid
% - max_range: points farther than this from the origin are marked invalid
%
% Outputs:
% - filtered_xy_scan: filtered scan, in cartesian coordinates
% - filtered_polar_scan: filtered scan, in polar coordinates
% - valid: specifies the indices of the filtered scans should be used

function [filteredXYScan, filteredPolarScan, valid] ...
    = filterScan(polarScan, medFiltSize, threshold, minRange, maxRange)

filteredPolarScanRange = medfilt1(polarScan(:, 1), medFiltSize);

diff = abs(polarScan(:, 1) - filteredPolarScanRange);

filteredPolarScan = polarScan;
filteredPolarScan(diff > threshold, 1) = ...
    filteredPolarScanRange(diff > threshold);

valid = filteredPolarScan(:, 1) > minRange & ...
        filteredPolarScan(:, 1) < maxRange;

filteredXYScan = ...
    [filteredPolarScan(:, 1) .* cos(filteredPolarScan(:, 2)), ...
     filteredPolarScan(:, 1) .* sin(filteredPolarScan(:, 2))];

end