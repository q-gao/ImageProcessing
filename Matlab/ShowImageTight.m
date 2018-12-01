classdef PlotImageUtil < handle
    methods(Static)
        function ShowImageTight( cImgs, valueRange, layout)
            numImg = length(cImgs);
            if nargin < 2, valueRange = []; end
            if nargin < 3, layout = [1, numImg]; end

            figure;
            for iid = 1: numImg
                subplottight(layout(1), layout(2), iid);
                imshow(cImgs{iid}, valueRange, 'border', 'tight');
            end
        end
    end
end