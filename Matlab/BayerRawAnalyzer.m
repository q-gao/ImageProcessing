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
    end
end