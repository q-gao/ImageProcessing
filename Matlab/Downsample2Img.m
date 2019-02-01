% Downsampling procedure.
%
% Arguments:
%   grayscale I image
%   downsampling filter 'filter', should be a 1D separable filter.
%   'border_mode' should be 'circular', 'symmetric', or 'replicate'. See 'imfilter'.
%
% If image width W is odd, then the resulting image will have width (W-1)/2+1,
% Same for height.

function R = Downsample2Img(I, filter)
if nargin < 2
    % default: 5x5 Gaussian
    % [1 4 6 4 1]/16
    filter = [.0625, .25, .375, .25, .0625];
end

border_mode = 'symmetric';

% low pass, convolve with separable filter
R = imfilter(I,filter,border_mode);     %horizontal
R = imfilter(R,filter',border_mode);    %vertical

% decimate
r = size(I,1);
c = size(I,2);
R = R(1:2:r, 1:2:c, :);  