classdef StudyImageFreqDomain < handle
    methods (Static)
        function subImg = SubImageAtFreqIndex(F, u, v)
            [M, N] = size(F);
            
            F_sub = complex(zeros(M,N), 0);
            F_sub(u, v) = F(u, v);
            u2 = M + 2 -u;
            if u2 > M,  u2 = u2 - M; end
            v2 = N + 2 -v;
            if v2 > N,  v2 = v2 - N; end            
            F_sub( u2, v2 ) = F(u2, v2);
            
            subImg = ifft2(F_sub);
        end
        function [subImg, numAboveFreq] = SubImageFreqMagAbove(F, threshPcent)
            % sub image = images constructed from subset of freq components
            % keep freq's whose mag >= theshPcent * F(1,1)
            
            thresh = threshPcent * abs(F(1,1));
            indAbove = find( abs(F) >= thresh );
            numAboveFreq = length( indAbove);
            [I, J] = ind2sub( size(F), indAbove );
            F_sub = complex( zeros( size(F) ), 0 );            
            F_sub(I, J) = F(I, J);
            subImg = ifft2( F_sub );
        end
        function PlotSubImages(origImg, threshPcent, valueRange)
            F = fft2(origImg);
            [w, h ] = size(F);
            numFreq = w * h;
            numSubImg = length( threshPcent );
            subImgs{numSubImg} = [];
            figure; numC = 1 + numSubImg; numR = 2;      
            subplottight(numR, numC, 1); imshow(origImg, valueRange); 
            for i = 1: numSubImg
                [subImgs{i}, numAbove] = StudyImageFreqDomain.SubImageFreqMagAbove(F, threshPcent(i));
                subplottight(numR, numC, i+1); 
                imshow(subImgs{i}, valueRange);
                title( sprintf('%.2f%% > Thresh %.5f', numAbove/numFreq*100 , threshPcent(i) ));
            end
            
            subplottight(numR, numC, numC+1); 
            histogram(origImg(:), 256); 
            for i = 1: numSubImg
                subplottight(numR, numC, numC+i+1); 
                histogram(subImgs{i}(:), 256);
            end            
        end
        function [sparse, subImgs] = CalcImgFreqDomainSparsity(img, ntiles_rc, threshPcents)
            % Output:
            %  - sparse(tile_idx, thresh_id)
            %  - subImgs(y, x, thresh_id)
            numThresh = length( threshPcents );
            [numR, numC] = size(img);
            numFreq = numR * numC;  % assume no storage optimization for r2c case
            % alloc memory
            sparse( ntiles_rc(1) * ntiles_rc(2), numThresh ) = 0;
            subImgs( numR, numC, numThresh ) = 0;
            
            tile_size = size(img) ./ ntiles_rc;
            tile_id = 1;
            for tc = 1: ntiles_rc(2)  % tile index along column direction
                x0 = (tc -1 ) * tile_size(2) + 1 ;
                x1 = x0 + tile_size(2) - 1;
                for tr = 1: ntiles_rc(1)  % tile index along row direction
                    y0 = (tr -1 ) * tile_size(1) + 1 ;
                    y1 = y0 + tile_size(1) - 1;
                    F = fft2( img(y0:y1, x0:x1) );
                    for tid = 1: numThresh
                        [si, numAbove] = StudyImageFreqDomain.SubImageFreqMagAbove(...
                                            F, threshPcents(tid) );
                        subImgs(y0:y1, x0:x1, tid) = si;
                        sparse(tile_id, tid) = numAbove / numFreq;
                    end
                    tile_id = tile_id + 1;
                end
            end
        end
    end
end