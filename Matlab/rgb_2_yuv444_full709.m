function [Y_out,U_out,V_out]=rgb_2_yuv444_full709(im)
    %im is RGB and Y_out V_out is YUV444
    CSC_full709 = [1.0000	0.0000	1.5748;
        1.0000	-0.1873	-0.4681;
        1.0000	1.8556	0.0000];
    inv_CSC_full709 = inv(CSC_full709);

    %   Detailed explanation goes here
    Y_out = zeros(size(im,1),size(im,2));
    U_out = zeros(size(im,1),size(im,2));
    V_out = zeros(size(im,1),size(im,2));
    UV_out = zeros(1,size(im,1)*size(im,2)/2);

    Y_out = inv_CSC_full709(1,1)*im(:,:,1) + inv_CSC_full709(1,2)*im(:,:,2)+inv_CSC_full709(1,3) * im(:,:,3);
    U_out = inv_CSC_full709(2,1)*im(:,:,1) + inv_CSC_full709(2,2)*im(:,:,2)+inv_CSC_full709(2,3) * im(:,:,3) + 0.5;
    V_out = inv_CSC_full709(3,1)*im(:,:,1) + inv_CSC_full709(3,2)*im(:,:,2)+inv_CSC_full709(3,3) * im(:,:,3) + 0.5;

    U2 = imresize(double(U_out),0.5);%default is bicubic
    V2 = imresize(double(V_out),0.5);
    temp = U2';
    temp1 = temp(:);
    temp = V2';
    temp2 = temp(:);
    UV_out(1:2:end-1) = temp1;
    UV_out(2:2:end) = temp2;

    % Yout = uint16(Y_out'*1023);
    % UVout  = uint16(UV_out*1023);
end

