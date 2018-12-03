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
        function PlotGridInCurAxis_2( numCellLine, gridColor)
            if nargin < 2
                gridColor = 'r';
            end
            limRow = ylim( gca() ); cellSizeRow = (limRow(2) - limRow(1)) / numCellLine;
            limCol = xlim( gca() ); cellSizeCol = (limCol(2) - limCol(1)) / numCellLine;
            [Y, X] = meshgrid( limRow(1):cellSizeRow:limRow(2), limCol(1):cellSizeCol:limCol(2) );
            hold on;
            plot(X, Y, gridColor);
            plot(Y, X, gridColor);
        end
        function PlotGridInCurAxis( cellSizeRow, cellSizeCol, gridColor)
            if nargin < 3
                gridColor = 'r';
            end
            limRow = ylim( gca() ); 
            limCol = xlim( gca() ); 
            [Y, X] = meshgrid( limRow(1):cellSizeRow:limRow(2), limCol(1):cellSizeCol:limCol(2) );
            hold on;
            plot(X, Y, gridColor);
            plot(Y, X, gridColor);
        end        
    end
end