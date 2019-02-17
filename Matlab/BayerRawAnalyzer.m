classdef BayerRawAnalyzer < handle
    methods(Static)
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
           gray = 0.25* rggb(1:2:end,1:2:end)...
                + 0.25 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
                + 0.25 * rggb(2:2:end,2:2:end); 
        end
        function gray = Rggb2Gray(rggb)
           gray = 0.2990 * rggb(1:2:end,1:2:end)...
                + 0.2935 * (rggb(1:2:end,2:2:end) + rggb(2:2:end,1:2:end))...
                + 0.1140 * rggb(2:2:end,2:2:end); 
        end
        
    end
end