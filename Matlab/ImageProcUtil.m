classdef ImageProcUtil < handle
    methods(Static)
        function rgbOut = GammaRgb(rgb, g, method)
            %%
            % Input:
            %  - rgb ([0 1] double)
            %%
            if nargin < 3, method = 'hsv'; end
            
            if strcmp(method, 'hsv')  % equal => TRUE
                hsv = rgb2hsv(rgb);
                hsv(:,:,3) = hsv(:,:,3) .^ (1/ g);
                rgbOut = hsv2rgb(hsv);                
            elseif strcmp(method, 'rgb')  % equal => TRUE
                rgbOut = rgb .^ ( 1 / g);
            elseif strcmp(method, 'yuv')  % equal => TRUE
                Y = 0.299 * R + 0.587 * G + 0.114 * B;
                U = -0.14713 * R - 0.28886 * G + 0.436 * B;
                V = 0.615 * R - 0.51499 * G - 0.10001 * B;                
            else
                ycbcr = rgb2ycbcr(rgb);
                ycbcr(:,:,1) = ycbcr(:,:,1) .^ (1/ g);
                rgbOut = ycbcr2rgb(ycbcr);
            end
        end
        function yuv = Rgb2Yuv(rgb)
            Y = 0.299 * R + 0.587 * G + 0.114 * B;
            U = -0.14713 * R - 0.28886 * G + 0.436 * B;
            V = 0.615 * R - 0.51499 * G - 0.10001 * B;       
                
            R = -0.1179838438e-4 * U + Y + 1.139834576 * V
            G = -.5805942338 * V -.3946460533 * U + 1.000003946 * Y
            B = .9999796789 * Y + 2.032111938 * U -0.1511298066e-4 * V                
        end
    end
end