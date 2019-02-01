clear all
close all

load input_yuv
load test_ratio

im = md_yuv2rgb(Y, U2, V2);
R = zeros(size(Y,1),size(Y,2),3);
for ch =1 :3
    R(:,:,ch)=min(1,im(:,:,ch).*ratio);
end
ratio_dn = imresize(double(ratio),0.5);
figure, imshow(ratio_dn,[]);
[Y_out, UV_out ] = write_yuv420(R);

[Y_R,U_R,V_R]=md_rgbryuv(R);
im_exp1 = md_yuv2rgb(Y_R,U_R,V_R);
figure, imshow(im_exp1);

% no clipping will have color shifting
% Y_exp = Y.*ratio;
% U2_exp = (U2-0.5).*ratio +0.5;
% V2_exp = (V2-0.5).*ratio +0.5;
% im_exp = md_yuv2rgb(Y_exp, U2_exp, V2_exp);

Y_exp = min(1, Y.*ratio);
U2_exp = min(1,(U2-0.5).*ratio)+0.5;
V2_exp = min(1,(V2-0.5).*ratio)+0.5;

%     Y_exp = min(1,Y.*ratio);
%     U2_exp = min(1,(max(0,U2)-0.5).*ratio +0.5);
%     V2_exp = min(1,(max(0,V2)-0.5).*ratio +0.5);

im_exp = md_yuv2rgb(Y_exp, U2_exp, V2_exp);
figure, imshow(im_exp);
tt0 = Y_exp-Y_R;
tt1 = V2_exp-V_R;
tt2 = U2_exp-U_R;
figure, imagesc(Y_exp-Y_R);
figure, imagesc(V2_exp-V_R);
figure, imagesc(U2_exp-U_R);

[ Y_out2, UV_out2 ] = write_yuv420(Y_exp, U2_exp,V2_exp);
command = 'move out_yuv_10bit.yuv D:\HDR+\ToneMapping\simulator\data\front_gain1\raw\yuv_10bit.yuv';
system (command);

% test down sampled 
Y_exp = min(1, Y.*ratio);
U1_s = U1'/1023.0;
V1_s = V1'/1023.0;
U1_exp = min(1,(U1_s-0.5).*ratio_dn)+0.5;
V1_exp = min(1,(V1_s-0.5).*ratio_dn)+0.5;

        UV_out = zeros(1,size(im,1)*size(im,2)/2);
        temp = U1_exp';
        temp1 = temp(:);
        temp = V1_exp';
        temp2 = temp(:);
        UV_out(1:2:end-1) = temp1;
        UV_out(2:2:end) = temp2;
        
        Yout = uint16(Y_exp'*1023.0);
         UVout  = uint16(UV_out*1023.0);
         file = fopen('out_yuv_10bit.yuv', 'wb');
fwrite(file, Yout, 'uint16');
fwrite(file, UVout,'uint16');
fclose(file);