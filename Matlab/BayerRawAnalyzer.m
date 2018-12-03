classdef BayerRawAnalyzer < handle
    methods(Static)
        function cChDatas = SeparateCh(bayer)
            % cChDatas{i} is i-th channel
            for i = 3:-1:0
                cChDatas{i+1} = bayer( floor(i/2)+1:2:end, mod(i,2)+1:2:end);
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
    end
end