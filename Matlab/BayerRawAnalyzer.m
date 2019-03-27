classdef BayerRawAnalyzer < handle
    methods(Static)
        %% Demosaic to sRGB
        function srgb = Bayer10bits2sRGB(bayer)
            % demosaic algo:
            % https://www.mathworks.com/help/images/ref/demosaic.html
            % [1] Malvar, H.S., L. He, and R. Cutler, 
            %   High quality linear interpolation for demosaicing of Bayer-patterned color images. 
            %   ICASPP, Volume 34, Issue 11, pp. 2274-2282, May 2004.
            srgb = lin2rgb( ... % 
                        ... % demosaic output has the same type as input
                        demosaic(uint16(bayer * 64), 'rggb'), ... % to uint16 first
                        'OutputType','double'... % output [0 1]
                    );
        end
        %%
        function cChDatas = SeparateCh(bayer)
            % cChDatas{i} is i-th channel
            for i = 3:-1:0
                cChDatas{i+1} = bayer( floor(i/2)+1:2:end, mod(i,2)+1:2:end);
            end
        end
        function rggb = FlattenCh(ch)
            % cChDatas{i} is i-th channel
            rggb = zeros( 2 * size(ch{1}) );
            rggb(1:2:end, 1:2:end) = ch{1};
            rggb(2:2:end, 1:2:end) = ch{2};
            rggb(1:2:end, 2:2:end) = ch{3};            
            rggb(2:2:end, 2:2:end) = ch{4};
        end        
        function ShowChannelHist(bayer)
            ch = BayerRawAnalyzer.SeparateCh(bayer);
            for c = 4: -1 : 1
                h = histogram(ch{c}(:));
                chist{c} = h.Values;
                chistBin{c} = h.BinEdges(1:end-1) + h.BinWidth/2;
            end
            figure; hold on;            
            s = {'r','g','c','b'};
            for c = 1:4
                plot(chistBin{c}, chist{c}, s{c});
            end
        end
        
        function ShowBayerChannelImages(cChDatas)
            figure; 
            for i = 1:4
                subplottight(2,2,i);
                imshow(cChDatas{i},[0,1023]);
            end            
            % enable showing info for the pixel under current cursor
            impixelinfo();
        end
        
        function ShowBayer(b)
            cChDatas=BayerRawAnalyzer.SeparateCh(b);
            figure; 
            for i = 1:4
                subplottight(2,2,i);
                imshow(cChDatas{i},[0,1023]);
            end            
            % enable showing info for the pixel under current cursor
            impixelinfo();
        end        
        function ShowBayerDiff(b1, b2)
            cCh1 = BayerRawAnalyzer.SeparateCh(b1);
            cCh2 = BayerRawAnalyzer.SeparateCh(b2);
            figure; 
            for i = 1:4
                subplottight(2,2,i);
                imshow( abs(cCh1{i}-cCh2{i}),[0,1023]);
            end             
        end
        %% AvgerageBayer:brsnction description
        function  avg = AvgerageListOfArray(brs)
           for i = length(brs):-1:1
                t(:,:,i) = brs{i};
           end 
           avg = mean(t, 3);
        end
        %% RGGB to Gray
        function gray = Rggb2Gray_Simple(rggb)
            % linear RGB to lum
           gray = 0.2126* rggb(1:2:end,1:2:end)...
                + 0.3576 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
                + 0.0722 * rggb(2:2:end,2:2:end);             
%            % sRGB to Lum
%            gray = 0.25* rggb(1:2:end,1:2:end)...
%                 + 0.25 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
%                 + 0.25 * rggb(2:2:end,2:2:end); 
        end
        function gray = Rggb2Gray(rggb)
%            gray = 0.2990 * rggb(1:2:end,1:2:end)...
%                 + 0.2935 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
%                 + 0.1140 * rggb(2:2:end,2:2:end); 
           % https://www.wikiwand.com/en/Grayscale
           % linear sRGB to linear gray
           gray = 0.2126 * rggb(1:2:end,1:2:end)...
                + 0.3576 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
                + 0.0722 * rggb(2:2:end,2:2:end);            
        end
        
    end
end
