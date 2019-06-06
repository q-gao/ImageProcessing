function [Y, im, U1_s, V1_s] = readYUV( yuvName, uWidth, uHeight, bitdepth)
%[Y, im] = readYUV( 'D:\TestData\Mar25_2\camera\1552087639957_4000x3000_0_1_exp[0]_16bit_in.yuv', 3000, 4000, 16);
%[Y, im] = readYUV( 'D:\TestData\preview_camera\output\2149692\test.yuv', 3000,4000, 10);
if (bitdepth==10)||(bitdepth==16)
    charFmt = 'uint16';
else
    charFmt = 'uint8';
end
maxV = 2^bitdepth-1;
file = fopen(yuvName, 'r');
A = fread(file,[uHeight,uWidth],charFmt);
Y = double(A')/double(maxV);%normalize
B = fread(file,[2,uHeight*uWidth/4],charFmt);
fclose(file);

tB = B(1,:);
U1= reshape(tB(:), uHeight/2, uWidth/2);
tB=B(2,:);
V1= reshape(tB(:), uHeight/2,uWidth/2);
U1_s = U1'/double(maxV);
V1_s = V1'/double(maxV);
clear tB A B 
U2 = imresize(double(U1'),2,'bicubic')/double(maxV);
V2 = imresize(double(V1'),2,'bicubic')/double(maxV);
im = md_yuv2rgb(Y, U2, V2);
end

function img=md_yuv2rgb(inY, inU, inV)
CSC_full709 = [1.0000	0.0000	1.5748;
    1.0000	-0.1873	-0.4681;
    1.0000	1.8556	0.0000];
width = size(inY,1);
height = size(inY,2);
img = zeros(width, height, 3);
img(:,:,1)  = inY + CSC_full709(1,2)*(inU-0.5)+CSC_full709(1,3) * (inV-0.5);
img(:,:,2)  = inY + CSC_full709(2,2)*(inU-0.5) + CSC_full709(2,3) *(inV-0.5);
img(:,:,3)  = inY + CSC_full709(3,2)*(inU-0.5) +CSC_full709(3,3)* (inV-0.5);


end

