classdef ExposureFusion < handle % This is critical see explanation in Run()
    properties
        m_numPyrLevels;
        m_imgWidth;
        m_imgHeight;
        m_ccImgLapPyr;  % cc: cell cell
        m_cPyrExp;
    end
    %===============================================
    methods
        function obj = ExposureFusion( numLevels, w, h )
            obj.m_numPyrLevels = numLevels;
            obj.m_imgWidth = w;
            obj.m_imgHeight = h;
            obj.m_ccImgLapPyr = {};
            obj.m_cPyrExp = {};
        end
        function g = RunMultiExposureHdr( obj, ue, oe, keepThresh )
            oeWgt = oe < keepThresh;
            ueWgt = 1 - oeWgt;
            
            cPyr{2} = [];
            cPyrW{2} = [];
            
             cPyr{1} = obj.BuildLaplacianPyramidFromIntImg( ue );
            cPyrW{1} = obj.BuildGaussianPyramidFromIntImg(  ueWgt);
            
             cPyr{2} = obj.BuildLaplacianPyramidFromIntImg( oe );
            cPyrW{2} = obj.BuildGaussianPyramidFromIntImg(  oeWgt);
            
            pyrBlended = ExposureFusion.BlendPyramids( cPyr, cPyrW);
            g = ExposureFusion.CollapseLapPyr( pyrBlended );
        end
        function pyrG = BuildGaussianPyramidFromIntImg( obj, img )
            pyrG{obj.m_numPyrLevels} = []; % pre-allocate memeory
                        
            pyrG{1} = cast(img, 'double');
            
            for i = 2: obj.m_numPyrLevels
                pyrG{i} = downsample( pyrG{i-1});             
            end
        end
        function pyr = BuildLaplacianPyramidFromIntImg(obj, img)
            pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
            pyr{1} = cast(img, 'double');
            
            for i = 2: obj.m_numPyrLevels
                pyr{i} = downsample( pyr{i-1});             
                % MATLAB uses a system commonly called "copy-on-write" to avoid making a copy 
                % of the input argument inside the function workspace until or unless you modify the input argument
                % see https://www.mathworks.com/matlabcentral/answers/152-can-matlab-pass-by-reference
                pyr{i-1} = pyr{i-1} - upsample(pyr{i}, 2 * size(pyr{i}) - size(pyr{i-1}) ) ;
            end
        end        
        function out = Run_RGGB(obj, cBayers, aMu, aSigma, blackLevel)
            if nargin < 5,   blackLevel = 64; end
            
            numImgs = length(cBayers);
            %obj.m_ccImgLapPyr{ numImgs } = {};
            obj.m_cPyrExp{ numImgs } = {};
            cRggbs{numImgs} = [];
            for imgIdx = 1: numImgs
                % load as double
                if isstring(cBayers{imgIdx})
                    cRggbs{imgIdx} = LoadBinaryFile(...
                                                cBayers{imgIdx},[obj.m_imgWidth, obj.m_imgHeight],...
                                                'uint16'...
                                    ) - blackLevel;            
                else
                    cRggbs{imgIdx} = cBayers{imgIdx} - blackLevel;
                end
                
                obj.m_cPyrExp{imgIdx} = obj.BuildExpPyrFromRggb(...
                                                        cRggbs{imgIdx}, ...
                                                        aMu(imgIdx),aSigma(imgIdx), ...
                                                        1023 - blackLevel ... 
                                        );                                                
            end
            
            out = zeros( size(cRggbs{1}) );
            cLapPyrs{numImgs} = [];            
            for ty = 1: 2
                for tx = 1:2
                    
                    for imgIdx = 1: numImgs
                        cLapPyrs{imgIdx}{obj.m_numPyrLevels} = [];

                        cLapPyrs{imgIdx}{1} = int16(cRggbs{imgIdx}(tx:2:end, ty:2:end));
                        for i = 2: obj.m_numPyrLevels
                            cLapPyrs{imgIdx}{i} = int16(downsample( cLapPyrs{imgIdx}{i-1}));             
                            % MATLAB uses a system commonly called "copy-on-write" to avoid making a copy 
                            % of the input argument inside the function workspace until or unless you modify the input argument
                            % see https://www.mathworks.com/matlabcentral/answers/152-can-matlab-pass-by-reference
                            cLapPyrs{imgIdx}{i-1} = cLapPyrs{imgIdx}{i-1} - ...
                                                    int16(upsample(cLapPyrs{imgIdx}{i},...
                                                        2 * size(cLapPyrs{imgIdx}{i}) - size(cLapPyrs{imgIdx}{i-1})...
                                                    )) ;
                        end                        
                    end
%                     lapPyrBlended = obj.WAvgLapPyrd(cLapPyrs, obj.m_cPyrExp);
                    lapPyrBlended = ExposureFusion.BlendPyramids( cLapPyrs, obj.m_cPyrExp );
                    out(tx:2:end, ty:2:end) = uint16( ExposureFusion.CollapseLapPyr(lapPyrBlended) );
                    
                end                
            end
        end
%         function pyrBlendedLap = WAvgLapPyrd(obj, cLapPyrs, cWPyrs)
%             pyrBlendedLap{obj.m_numPyrLevels} = {};
%             pyrWghtSum{obj.m_numPyrLevels} = {};
%             numImgs = length( cLapPyrs );
%             
%             for lvl = 1 : obj.m_numPyrLevels
%                 % init with first image
%                 pyrBlendedLap{lvl} = cLapPyrs{1}{lvl} .* cWPyrs{1}{lvl};
%                 pyrWghtSum{lvl} = cWPyrs{1}{lvl};
%                 
%                 for imgIdx = 2: numImgs
%                     pyrBlendedLap{lvl} = pyrBlendedLap{lvl} + ...
%                                          cLapPyrs{imgIdx}{lvl} .* cWPyrs{imgIdx}{lvl};
%                     pyrWghtSum{lvl} = pyrWghtSum{lvl} + cWPyrs{imgIdx}{lvl};                    
%                 end                
%             end
%             
%             % normalization
%             for lvl = 1 : obj.m_numPyrLevels
%                 %fprintf('Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );
%                 pyrBlendedLap{lvl} = pyrBlendedLap{lvl} ./ pyrWghtSum{lvl};
%                 %fprintf('  Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );                
%             end            
%         end
        function pyrExpo = BuildExpPyrFromRggb(obj, rggb, c, sigma, maxVal)
            if nargin < 5,  maxVal = 1023; end
            
            pyrExpo{ obj.m_numPyrLevels } = [];
            
%             init = 0;
%             for ty = 1 : 2
%                 for tx = 1: 2
%                     D = double(rggb(tx:2:end, ty:2:end)) / maxVal - c;
%                     v = 2 * sigma * sigma;
%                     if ~init
%                         pyrExpo{1} = exp( - D .* D ./ v );
%                         init = 1;
%                     else
%                         pyrExpo{1} = pyrExpo{1} .* exp( - D .* D ./ v );
%                     end
%                 end
%             end

            g = BayerRawAnalyzer.Rggb2Gray( rggb );
            D = double(g) / maxVal - c;
            v = 2 * sigma * sigma;
            pyrExpo{1} = exp( - D .* D ./ v );
                        
            for lvl = 2: obj.m_numPyrLevels
                pyrExpo{lvl} = downsample( pyrExpo{lvl-1} );
            end
        end        
        function g = Run_Y( obj, varargin )
            %NOTE: if ExposureFusion is not a handle class, obj will be
            % passed as a value!! So obj is actually a copy of the caller
            % object!!
            
            % pre-allocate memory
            numImgs = nargin-1;
            obj.m_ccImgLapPyr{ numImgs } = {};
            obj.m_cPyrExp{ numImgs } = {};
            for i = 1: numImgs
                if ischar(varargin{i})
                    [obj.m_ccImgLapPyr{i}, obj.m_cPyrExp{i}] = ...
                        obj.BuildLapAndExposednessPyramidFromYFile( varargin{i} );
                else
                    [obj.m_ccImgLapPyr{i}, obj.m_cPyrExp{i}] = ...
                        obj.BuildLapAndExposednessPyramidFromY( varargin{i} );                    
                end
            end
            
%             for i = 1: numImgs
%                 figure;
%                 plotid = 1;
%                 for lvl = obj.m_numPyrLevels: -1: 1
%                     subplottight(3, obj.m_numPyrLevels, plotid);
%                     plotid = plotid + 1;
%                     if lvl == obj.m_numPyrLevels
%                         imshow(obj.m_ccImgLapPyr{i}{lvl}', [0, 1024], 'border', 'tight');
%                     else
%                         imshow(obj.m_ccImgLapPyr{i}{lvl}', [-300, 500], 'border', 'tight');
%                     end
%                 end
%                 for lvl = obj.m_numPyrLevels: -1: 1                
%                     subplottight(3, obj.m_numPyrLevels, plotid);
%                     plotid = plotid + 1;
%                     imshow(obj.m_cPyrExp{i}{lvl}', [0, 1], 'border', 'tight');
%                 end
%                 for lvl = obj.m_numPyrLevels: -1: 1
%                     subplottight(3, obj.m_numPyrLevels, plotid);
%                     plotid = plotid + 1;
%                     if lvl == obj.m_numPyrLevels                    
%                         imshow( (obj.m_ccImgLapPyr{i}{lvl} .* obj.m_cPyrExp{1}{lvl})', [0, 1024], 'border', 'tight');
%                     else
%                         imshow( (obj.m_ccImgLapPyr{i}{lvl} .* obj.m_cPyrExp{1}{lvl})', [-300, 500], 'border', 'tight');
%                     end
%                 end
%             end
%             pyrBlendedLap = obj.WAvgLapPyrd(obj.m_ccImgLapPyr, obj.m_cPyrExp);
            pyrBlendedLap =ExposureFusion.BlendPyramids(obj.m_ccImgLapPyr, obj.m_cPyrExp);
%             pyrBlendedLap{obj.m_numPyrLevels} = {};
%             pyrWghtSum{obj.m_numPyrLevels} = {};
%             for lvl = 1 : obj.m_numPyrLevels
%                 pyrBlendedLap{lvl} = obj.m_ccImgLapPyr{1}{lvl} .* obj.m_cPyrExp{1}{lvl};
%                 pyrWghtSum{lvl} = obj.m_cPyrExp{1}{lvl};
%             end
%             for lvl = 1 : obj.m_numPyrLevels
%                 for imgIdx = 2: numImgs
%                     pyrBlendedLap{lvl} = pyrBlendedLap{lvl} + ...
%                                          obj.m_ccImgLapPyr{imgIdx}{lvl} .* obj.m_cPyrExp{imgIdx}{lvl};
%                     pyrWghtSum{lvl} = pyrWghtSum{lvl} + obj.m_cPyrExp{imgIdx}{lvl};                    
%                 end
%             end
%             
%             for lvl = 1 : obj.m_numPyrLevels
%                 %fprintf('Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );
%                 pyrBlendedLap{lvl} = pyrBlendedLap{lvl} ./ pyrWghtSum{lvl};
%                 %fprintf('  Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );                
%             end
            
            g = ExposureFusion.CollapseLapPyr(pyrBlendedLap);
        end
        function pyr = BuildGaussianPyramidFromYFile(obj, yfileName)
            pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
            pyr{1} = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);
            for i = 2: obj.m_numPyrLevels
                pyr{i} = impyramid( pyr{i-1}, 'reduce');
            end
        end
        function [pyr, pyrExposedness] = BuildLapAndExposednessPyramidFromYFile(obj, yfileName)
            Y = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);
            [pyr, pyrExposedness] = obj.BuildLapAndExposednessPyramidFromY(Y);
%             pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
%             
%             % load as double
%             pyr{1} = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);
% 
%             pyrExposedness=obj.BuildExposednessPyramid( pyr{1} );
%             
%             for i = 2: obj.m_numPyrLevels
%                 pyr{i} = downsample( pyr{i-1});             
%                 % MATLAB uses a system commonly called "copy-on-write" to avoid making a copy 
%                 % of the input argument inside the function workspace until or unless you modify the input argument
%                 % see https://www.mathworks.com/matlabcentral/answers/152-can-matlab-pass-by-reference
%                 pyr{i-1} = pyr{i-1} - upsample(pyr{i}, 2 * size(pyr{i}) - size(pyr{i-1}) ) ;
%             end
        end
        function [pyr, pyrExposedness] = BuildLapAndExposednessPyramidFromY(obj, Y)
            pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
            
            pyr{1} = double(Y);
            pyrExposedness=obj.BuildExposednessPyramid( double(Y) );
            
            for i = 2: obj.m_numPyrLevels
                pyr{i} = downsample( pyr{i-1});             
                % MATLAB uses a system commonly called "copy-on-write" to avoid making a copy 
                % of the input argument inside the function workspace until or unless you modify the input argument
                % see https://www.mathworks.com/matlabcentral/answers/152-can-matlab-pass-by-reference
                pyr{i-1} = pyr{i-1} - upsample(pyr{i}, 2 * size(pyr{i}) - size(pyr{i-1}) ) ;
            end            
        end
        function pyrExpo = BuildExposednessPyramid(obj, Y)
            pyrExpo{ obj.m_numPyrLevels } = [];
            
            c = 0.5;
            sigma = 0.2;
            D = double(Y) / 1023 - c;
            v = 2 * sigma * sigma;
            pyrExpo{1} = exp( - D .* D ./ v );
            
            for lvl = 2: obj.m_numPyrLevels
                pyrExpo{lvl} = downsample( pyrExpo{lvl-1} );
            end
        end
    end
    methods(Static)
        function g = CollapseLapPyr(pyrLap, maxVal)
            if nargin < 2,  maxVal = 1023; end
            
            nl = length(pyrLap);
            g = pyrLap{nl};
            for lvl = nl - 1: -1: 1
                %dim = size( pyrLap{lvl} );
                %g = upsample(g, [mod(dim(1),2), mod(dim(2),2)] ) + pyrLap{lvl};
                up = upsample(g, 2 * size(g) - size(pyrLap{lvl}) );
                g =  up + pyrLap{lvl};
                
                fprintf(' G_%d min, max= %f, %f before clipping negative values\n', lvl, min(g(:)), max(g(:)));
%                 mask = g < 0;
%                 g(mask) = 0; % up(mask);  % IMPORTANT to avoid artifact
%                 g(g > maxVal) = maxVal;
            end
        end        
        function pyrBlended = BlendPyramids( cPyr, cPyrW )
            % double floating point calculation
            numLvl = length( cPyr{1} );
            numImg = length( cPyr );
            for lvl = numLvl: -1: 1
                pyrBlended{ lvl } = double(cPyr{1}{lvl}) .* cPyrW{1}{lvl};
                pyrWSum{ lvl } = cPyrW{1}{lvl};
            end
            
            for i = 2: numImg
                for lvl = numLvl: -1: 1
                    pyrBlended{ lvl } = pyrBlended{ lvl } + double(cPyr{i}{lvl}) .* cPyrW{i}{lvl};
                    pyrWSum{ lvl } = pyrWSum{ lvl } + cPyrW{i}{lvl};
                end            
            end
            for lvl = numLvl: -1: 1
                pyrBlended{ lvl } = pyrBlended{ lvl } ./ pyrWSum{lvl};
            end            
        end        
    end
end