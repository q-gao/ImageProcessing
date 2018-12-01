classdef StudyWavelet2 < handle
    methods(Static)
        function PlotSwtAtLevel( ca, chd, cvd, cdd, lvl )
            A1 = wcodemat( ca(:,:,lvl),255);
            H1 = wcodemat(chd(:,:,lvl),255);
            V1 = wcodemat(cvd(:,:,lvl),255);
            D1 = wcodemat(cdd(:,:,lvl),255);
            
            figure;
            subplottight(2,2,1); imshow(uint8(A1));
            subplottight(2,2,2); imshow(uint8(H1));
            subplottight(2,2,3); imshow(uint8(V1));
            subplottight(2,2,4); imshow(uint8(D1));
        end
        function PlotSwtAll( ca, chd, cvd, cdd, numLvlPerCol )
            [~, ~, numLevels] = size(ca);
            numLvlPerRow = floor(numLevels / numLvlPerCol);
            numSubplotPerRow = 2 * numLvlPerRow;
            numSubplotPerCol = 2 * numLvlPerCol;
            figure;
            for lvlTileY = 1: numLvlPerCol
                for lvlTileX = 1: numLvlPerRow
                    lvl = (lvlTileY-1) * numLvlPerRow + lvlTileX;
                    A1 = wcodemat( ca(:,:,lvl),255);
                    H1 = wcodemat(chd(:,:,lvl),255);
                    V1 = wcodemat(cvd(:,:,lvl),255);
                    D1 = wcodemat(cdd(:,:,lvl),255);
                    
                    off = (lvlTileY-1) * 2 * numSubplotPerRow + (lvlTileX-1) * 2 + 1;
                    %fprintf('%d ',off);
                    subplottight(numSubplotPerCol,numSubplotPerRow, off); imshow(uint8(A1));
                    subplottight(numSubplotPerCol,numSubplotPerRow, off+1); imshow(uint8(H1));
                    off = off + numSubplotPerRow;
                    %fprintf('%d\n',off);
                    subplottight(numSubplotPerCol,numSubplotPerRow, off); imshow(uint8(V1));
                    subplottight(numSubplotPerCol,numSubplotPerRow, off+1); imshow(uint8(D1));
                end
            end
            
            figure;
            % histogram
            norm = 0.5;
            for lvlTileY = 1: numLvlPerCol
                for lvlTileX = 1: numLvlPerRow
                    lvl = (lvlTileY-1) * numLvlPerRow + lvlTileX;
                    A1 = wcodemat( ca(:,:,lvl),255);
                    H1 = wcodemat(chd(:,:,lvl),255);
                    V1 = wcodemat(cvd(:,:,lvl),255);
                    D1 = wcodemat(cdd(:,:,lvl),255);
                    
                    off = (lvlTileY-1) * 2 * numSubplotPerRow + (lvlTileX-1) * 2 + 1;
                    %fprintf('%d ',off);
%                     subplottight(numSubplotPerCol,numSubplotPerRow, off); histogram(A1);
%                     subplottight(numSubplotPerCol,numSubplotPerRow, off+1);histogram(H1);
                    A1 = ca(:,:,lvl) * norm;
                    H1 = chd(:,:,lvl) * norm;
                    subplot(numSubplotPerCol,numSubplotPerRow, off); histogram(A1(:));
                    subplot(numSubplotPerCol,numSubplotPerRow, off+1);histogram(H1);                    
                    off = off + numSubplotPerRow;
                    %fprintf('%d\n',off);
%                     subplottight(numSubplotPerCol,numSubplotPerRow, off); histogram(V1);
%                     subplottight(numSubplotPerCol,numSubplotPerRow, off+1);histogram(D1);
                    V1 = cvd(:,:,lvl) * norm;
                    D1 = cdd(:,:,lvl) * norm;
                    subplot(numSubplotPerCol,numSubplotPerRow, off); histogram(V1);
                    subplot(numSubplotPerCol,numSubplotPerRow, off+1);histogram(D1);                    
                    
                    norm = norm * 0.5;
                end
            end
            
        end        
    end
end
