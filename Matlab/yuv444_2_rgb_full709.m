function img=yuv444_2_rgb_full709(inY, inU, inV)
    % input inU and inV are from YUV444
    % Range [0, 1]
    CSC_full709 = [ 1.0000	0.0000	1.5748;
                    1.0000	-0.1873	-0.4681;
                    1.0000	1.8556	0.0000];
    width = size(inY,1);
    height = size(inY,2);
    img = empty(width, height, 3);
    img(:,:,1)  = inY + CSC_full709(1,2)*(inU-0.5)+CSC_full709(1,3) * (inV-0.5);
    img(:,:,2)  = inY + CSC_full709(2,2)*(inU-0.5) + CSC_full709(2,3) *(inV-0.5);
    img(:,:,3)  = inY + CSC_full709(3,2)*(inU-0.5) +CSC_full709(3,3)* (inV-0.5);
end
