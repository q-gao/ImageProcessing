classdef RawImageHandler < handle
    methods (Static)
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
        function ret_data = pre_processing_raw_patch(raw_data)
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

            ret_data = raw_data( raw_data ./ max(temp_mat, [], 3) < 1.5 );
        end        
        function bayer = LoadRaw(rawFile, w, h)
            fh = fopen(rawFile, 'rb');
            if -1== fh
                fprintf('Failed to open %s\n', rawFile);
                bayer = [];
            end
            bayer = fread(fh, w * h, 'uint16');
            bayer = reshape(bayer, [w, h])';
            s = size(bayer);
            if s(1) * s(2) ~= w * h
                fprintf('Error: read size %dx%d != %dx%d\n', s(1), s(2), w, h);
            end
            fclose(fh);
        end
        function [BayerImage, Label] = LoadDng(FullDngPath)
            % see https://blogs.mathworks.com/steve/2011/03/08/tips-for-reading-a-camera-raw-file-into-matlab/
            warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
            t = Tiff(FullDngPath,'r');
            % offsets = getTag(t,'SubIFD');
            % setSubDirectory(t,offsets(1));
            BayerImage = read(t);
            close(t);

            Info = imfinfo( FullDngPath );

            Label.WBC = 1./Info.AsShotNeutral;

            Label.Width  = Info.Width;
            Label.Height = Info.Height;
            Label.BayerBpp = 16;
            Label.Type = 'Bayer';
            Label.IsBigEndian = 0 ;

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