# Read RAW Images

## In MATLAB

```matlab
% Read a 10-bit RAW images
fin = fopen('RAW_10bit.raw', 'rb')
I = fread(fin, r*c, '*ubit16');  % use ubit16 for 10bits per pixel
fclose(fin)

% Show it
I_r = reshape(I, [c, r]); % NOTE: a image row is loaded to a MATLAB matrix column
I_r = I_r';  % rotate it as MATLAB is column first: 
imshow(I_r, [0 1023]);

% demoasic and shows
rgb=demosaic(I_r, 'rggb');  % output RGB values in uint16
rgb_r = mat2gray(rgb(:,:,1)); % convert it double
rgb_g = mat2gray(rgb(:,:,2));
rgb_b = mat2gray(rgb(:,:,3));
rgb_norm = cat(3,rgb_r,rgb_g,rgb_b);
imshow(rgb_norm)
```
