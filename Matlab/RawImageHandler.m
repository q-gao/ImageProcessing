classdef RawImageHandler < handle
    methods (Static)
        function VisualizeDngStat( bayers, infos )
            numDng = length(bayers);
            for i = numDng:-1:1
                ISOs(i)         = infos{i}.Info.ISOSpeedRatings;
                ExposureTime(i) = infos{i}.Info.ExposureTime;
            end
            [sortedISOs, idx] = sort( ISOs );
            
            figure;
            vars(4, numDng) = 0; % 4 channels RGGB
            for i = 1: numDng
                subplot(2,4, i);
                histogram( bayers{idx(i)}(:) );
                title( sprintf('%f', ISOs(idx(i)) ) );
                
                for c = 1: 2
                    for r = 1:2
                        a = bayers{idx(i)}(r:2:end, c:2:end);
                        vars((c-1)*2 + r, i) = var( double( a( a < 100)) );
                    end
                end
            end            
            figure; hold on;
            colors = ['r','g','c','b'];
            for i = 1:4
                plot(sortedISOs, vars(i,:), colors(i));
            end
        end       
        % Bad pixel detection
        %-------------------------------------------------
        function badpixel_mask = DetectBadPixel(bayer, maxVal)
            if nargin < 2
                maxVal = 1023;
            end
            [h, w] = size(bayer);
            badpixel_mask = zeros([h,w]);
            for c = 1: w
                c_min = max(c - 1, 1);
                c_max = min(c + 1, w);                
                for r = 1: h
                    orignalVal = bayer(r,c);
                    r_min = max(r - 1, 1);
                    r_max = min(r + 1, h);
                    bayer(r,c) = 0;
                    nbr_max = max(max(bayer(r_min:r_max,c_min:c_max)));
                    bayer(r,c) = maxVal;
                    nbr_min = min(min(bayer(r_min:r_max,c_min:c_max)));
                    
                    if orignalVal/nbr_max > 1.5  % hot pixel
                        badpixel_mask(r,c) = 1;
                    elseif orignalVal > 0
                        if nbr_min / orignalVal > 4.0  
                            badpixel_mask(r,c) = 1;
                        end
                    elseif nbr_min > 5
                        badpixel_mask(r,c) = 1;
                    end                    
                    bayer(r,c) = orignalVal;
                end
            end
        end   
        function neighborMax3x3 = GetNeighborMax3x3(raw_data)
            [M, N] = size(raw_data);
            temp_mat = zeros(M, N,8);

            temp_mat(1:end-1, 1:end  , 1) = raw_data(2:end  , 1:end);
            temp_mat(2:end  , 1:end  , 2) = raw_data(1:end-1, 1:end);
            temp_mat(1:end  , 1:end-1, 3) = raw_data(1:end  , 2:end);
            temp_mat(1:end  , 2:end  , 4) = raw_data(1:end  , 1:end-1);

            temp_mat(1:end-1, 1:end - 1,5) = raw_data(2:end, 2:end);
            temp_mat(2:end, 1:end - 1,6) = raw_data(1:end - 1, 2:end);
            temp_mat(2:end, 2:end,7) = raw_data(1:end - 1, 1:end -1);
            temp_mat(1:end - 1, 2:end,8) = raw_data(2:end, 1:end -1);
            
            neighborMax3x3 = max(temp_mat, [], 3);
        end
        function neighborMin3x3 = GetNeighborMin3x3(raw_data, maxVal)
            [M, N] = size(raw_data);
            temp_mat = ones(M, N,8)* maxVal;

            temp_mat(1:end-1, 1:end  , 1) = raw_data(2:end  , 1:end);
            temp_mat(2:end  , 1:end  , 2) = raw_data(1:end-1, 1:end);
            temp_mat(1:end  , 1:end-1, 3) = raw_data(1:end  , 2:end);
            temp_mat(1:end  , 2:end  , 4) = raw_data(1:end  , 1:end-1);

            temp_mat(1:end-1, 1:end - 1,5) = raw_data(2:end, 2:end);
            temp_mat(2:end, 1:end - 1,6) = raw_data(1:end - 1, 2:end);
            temp_mat(2:end, 2:end,7) = raw_data(1:end - 1, 1:end -1);
            temp_mat(1:end - 1, 2:end,8) = raw_data(2:end, 1:end -1);
            
            neighborMin3x3 = min(temp_mat, [], 3);
        end        
        % Load image
        %------------------------------------------------------------
        function [bayer, info] = LoadDngInDir(dngDir)
            dngFile = dir( [dngDir '\*.dng']);
            numDng = length(dngFile);
            bayer{numDng} = [];
            info{numDng} = [];
            for i = numDng:-1:1
                fprintf('Loading %s\n', dngFile(i).name);
                [bayer{i}, info{i}] = RawImageHandler.LoadDng([dngDir '\' dngFile(i).name]);
            end            
        end
        function bayer = LoadRawInDir(dngDir, w, h)
            dngFile = dir( [dngDir '\*.raw']);
            numDng = length(dngFile);
            bayer{numDng} = [];
            for i = numDng:-1:1
                fprintf('Loading %s\n', dngFile(i).name);
                bayer{i} = RawImageHandler.LoadRaw([dngDir '\' dngFile(i).name], w, h);
            end            
        end        
        function bayer = LoadRaw(rawFile, w, h)
            fh = fopen(rawFile, 'rb');
            if -1== fh
                fprintf('Failed to open %s\n', rawFile);
                bayer = [];
            end
            bayer = fread(fh, w * h, 'uint16=>uint16');
            bayer = reshape(bayer, [w, h])';
            s = size(bayer);
            if s(1) * s(2) ~= w * h
                fprintf('Error: read size %dx%d != %dx%d\n', s(1), s(2), w, h);
            end
            fclose(fh);            
        end        
        function [BayerImage, Info, Label] = LoadDng(FullDngPath)            
            % see https://blogs.mathworks.com/steve/2011/03/08/tips-for-reading-a-camera-raw-file-into-matlab/
            warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
            t = Tiff(FullDngPath,'r');
            % offsets = getTag(t,'SubIFD');
            % setSubDirectory(t,offsets(1));
            BayerImage = read(t);
            close(t);

            Info = imfinfo(FullDngPath);
            Label.WBC = 1./Info.AsShotNeutral;

            Label.Width  = Info.Width;
            Label.Height = Info.Height;
            Label.BayerBpp = 16;
            Label.Type = 'Bayer';
            Label.IsBigEndian = 0 ;
            
            %XYZ-to-camera matrix in the meta info.ColorMatrix2
            % These entries fill the transformation matrix in a C row-wise manner,
            % not MATLAB column-wise

            BayerPattern = Info.UnknownTags(2).Value;
            % BayerPattern = Info.SubIFDs{1}.Value;
            Label.BayerPattern = '';
            for ii=1:length( BayerPattern )
                switch BayerPattern(ii) % 0 == R; 1 == G ; 2 == B;
                   case 0
                      Label.BayerPattern(ii) = 'r';
                   case 1
                      Label.BayerPattern(ii) = 'g';
                   case 2
                      Label.BayerPattern(ii) = 'b';
                   otherwise
                      error('can''t handle unknown bayer pattern.');
                end
            end

            Label.Info = Info;            
        end
        function wbRggb = WhiteBalanceRggb( rggb, exif)
            wbMulti = exif.AsShotNeutral .^-1;
            wbMulti = wbMulti / wbMulti(2);  % Green should be 1
            wbRggb = double(rggb) .* RawImageHandler.WhiteBlanceMask(...
                                size(rggb,1),size(rggb,2), ...
                                wbMulti, 'rggb' ...
                            );
        end
        
        function cam2sRGB_matrix = CalcCam2sRGBMatrix( exif )
            % see Adobe DNG spec: https://www.adobe.com/content/dam/acom/en/products/photoshop/pdfs/dng_spec_1.4.0.0.pdf
            %  Chapter 6: Mapping Camera Color Space to CIE XYZ Color Space
            sRGB2xyz = [0.4124564 0.3575761 0.1804375; ...
                        0.2126729 0.7151522 0.0721750; ...
                        0.0193339 0.1191920 0.9503041 ...
                        ];
            xyz2cam = reshape(exif.ColorMatrix2, 3, 3)';
            cam2sRGB_matrix = inv( xyz2cam * sRGB2xyz );
            
            % assume this is for white-balanced RGB, then
            %  [1 1 1]' = cam2sRGB_matrix * [1 1 1]'
            % i.e., white [1 1 1] will still be white
            % This requires normalizing each row
            cam2sRGB_matrix = cam2sRGB_matrix ./ repmat(cam2sRGB_matrix * [ 1 1 1]', 1, 3);            
        end
        function colormask = WhiteBlanceMask(m,n,wbmults,align)
            % COLORMASK = wbmask(M,N,WBMULTS,ALIGN)
            %
            % Makes a white-balance multiplicative mask for an image of size m-by-n
            % with RGB while balance multipliers WBMULTS = [R_scale G_scale B_scale].
            % ALIGN is string indicating Bayer arrangement: ¡¯rggb¡¯,¡¯gbrg¡¯,¡¯grbg¡¯,¡¯bggr¡¯
            % 
            % Example:
            %   wb_multipliers = (meta_info.AsShotNeutral).?-1;
            %   wb_multipliers = wb_multipliers/wb_multipliers(2);
            %   mask = WhiteBlanceMask(size(lin_bayer,1),size(lin_bayer,2),wb_multipliers,¡¯rggb¡¯);
            %   balanced_bayer = lin_bayer .* mask;            
            
            colormask = wbmults(2)*ones(m,n); %Initialize to all green values
            switch align
                case 'rggb'
                colormask(1:2:end,1:2:end) = wbmults(1); %r
                colormask(2:2:end,2:2:end) = wbmults(3); %b
                case 'bggr'
                colormask(2:2:end,2:2:end) = wbmults(1); %r
                colormask(1:2:end,1:2:end) = wbmults(3); %b
                case 'grbg'
                colormask(1:2:end,2:2:end) = wbmults(1); %r
                colormask(1:2:end,2:2:end) = wbmults(3); %b
                case 'gbrg'
                colormask(2:2:end,1:2:end) = wbmults(1); %r
                colormask(1:2:end,2:2:end) = wbmults(3); %b
            end
        end
        % Image stat visualization       
        function ShowRggbHist(bayer, valRange)
            if nargin < 2
                valRange(2) = max(bayer(:));
                valRange(1) = min(bayer(:));
            end
            figure;
            idx = 1;
            for r = 1:2
                for c = 1:2
                    subplot(2,2, idx);
                    a = bayer(r:2:end, c:2:end);
                    a = a( a<= valRange(2));
                    a = a( a>= valRange(1));
                    histogram(a(:));
                    xlim(valRange);
                    title( sprintf('Mean, Std = %f, %f', mean(a(:)), sqrt(var( double(a(:)))) ));
                    grid minor;
                    idx = idx + 1;
                end
            end
        end
        function ShowRggbAsSequence(bayer)
            figure;
            idx = 1;
            color = ['r', 'g', 'c', 'b'];
            for r = 1:2
                for c = 1:2
                    subplot(2,2, idx);
                    a = bayer(r:2:end, c:2:end);
                    plot(a(:), color(idx));
                    idx = idx + 1;
                end
            end
        end        
    end
end
