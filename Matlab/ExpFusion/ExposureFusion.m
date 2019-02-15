classdef ExposureFusion < handle % This is critical see explanation in Run()
    properties
        m_numPyrLevels;
        m_imgWidth;
        m_imgHeight;
        m_ccImgLapPyr;  % cc: cell cell
        m_ccImgExposednessPyr;
    end
    %===============================================
    methods
        function obj = ExposureFusion( numLevels, w, h )
            obj.m_numPyrLevels = numLevels;
            obj.m_imgWidth = w;
            obj.m_imgHeight = h;
            obj.m_ccImgLapPyr = {};
            obj.m_ccImgExposednessPyr = {};
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
            g = ExposureFusion.CollapseLaplacianPyramid( pyrBlended );
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
        function g = Run( obj, varargin )
            %NOTE: if ExposureFusion is not a handle class, obj will be
            % passed as a value!! So obj is actually a copy of the caller
            % object!!
            
            % pre-allocate memory
            obj.m_ccImgLapPyr{ nargin - 1 } = {};
            obj.m_ccImgExposednessPyr{ nargin - 1 } = {};
            numImgs = nargin-1;
            for i = 1: numImgs
                [obj.m_ccImgLapPyr{i}, obj.m_ccImgExposednessPyr{i}] = ...
                    obj.BuildLapAndExposednessPyramidFromYFile( varargin{i} );
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
%                     imshow(obj.m_ccImgExposednessPyr{i}{lvl}', [0, 1], 'border', 'tight');
%                 end
%                 for lvl = obj.m_numPyrLevels: -1: 1
%                     subplottight(3, obj.m_numPyrLevels, plotid);
%                     plotid = plotid + 1;
%                     if lvl == obj.m_numPyrLevels                    
%                         imshow( (obj.m_ccImgLapPyr{i}{lvl} .* obj.m_ccImgExposednessPyr{1}{lvl})', [0, 1024], 'border', 'tight');
%                     else
%                         imshow( (obj.m_ccImgLapPyr{i}{lvl} .* obj.m_ccImgExposednessPyr{1}{lvl})', [-300, 500], 'border', 'tight');
%                     end
%                 end
%             end
            
            pyrBlendedLap{obj.m_numPyrLevels} = {};
            pyrWghtSum{obj.m_numPyrLevels} = {};
            for lvl = 1 : obj.m_numPyrLevels
                pyrBlendedLap{lvl} = obj.m_ccImgLapPyr{1}{lvl} .* obj.m_ccImgExposednessPyr{1}{lvl};
                pyrWghtSum{lvl} = obj.m_ccImgExposednessPyr{1}{lvl};
            end
            for lvl = 1 : obj.m_numPyrLevels
                for imgIdx = 2: numImgs
                    pyrBlendedLap{lvl} = pyrBlendedLap{lvl} + ...
                                         obj.m_ccImgLapPyr{imgIdx}{lvl} .* obj.m_ccImgExposednessPyr{imgIdx}{lvl};
                    pyrWghtSum{lvl} = pyrWghtSum{lvl} + obj.m_ccImgExposednessPyr{imgIdx}{lvl};                    
                end
            end
            
            for lvl = 1 : obj.m_numPyrLevels
                %fprintf('Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );
                pyrBlendedLap{lvl} = pyrBlendedLap{lvl} ./ pyrWghtSum{lvl};
                %fprintf('  Blended Lap Level %d: max-abs = %f\n', lvl, max(max( abs(pyrBlendedLap{lvl}) )) );                
            end
            
            g = ExposureFusion.CollapseLaplacianPyramid(pyrBlendedLap);
        end
        function pyr = BuildGaussianPyramidFromYFile(obj, yfileName)
            pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
            pyr{1} = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);
            for i = 2: obj.m_numPyrLevels
                pyr{i} = impyramid( pyr{i-1}, 'reduce');
            end
        end
        function [pyr, pyrExposedness] = BuildLapAndExposednessPyramidFromYFile(obj, yfileName)
%             Y = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);            
%             pyr = laplacian_pyramid(Y, obj.m_numPyrLevels);
            pyr{obj.m_numPyrLevels} = []; % pre-allocate memeory
            pyr{1} = LoadYFromYUV420File_10bit( yfileName, obj.m_imgWidth, obj.m_imgHeight);

            pyrExposedness=obj.BuildExposednessPyramid( pyr{1} );
            
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
            D = Y / 1023 - c;
            v = 2 * sigma * sigma;
            pyrExpo{1} = exp( - D .* D ./ v );
            
            for lvl = 2: obj.m_numPyrLevels
                pyrExpo{lvl} = downsample( pyrExpo{lvl-1} );
            end
        end
    end
    methods(Static)
        function g = CollapseLaplacianPyramid(pyrLap)
            nl = length(pyrLap);
            g = pyrLap{nl};
            for lvl = nl - 1: -1: 1
                %dim = size( pyrLap{lvl} );
                %g = upsample(g, [mod(dim(1),2), mod(dim(2),2)] ) + pyrLap{lvl};
                g = upsample(g, 2 * size(g) - size(pyrLap{lvl}) ) + pyrLap{lvl};
                
                fprintf(' G_%d max-abs= %f\n', lvl, max(max(g)));
            end
        end        
        function pyrBlended = BlendPyramids( cPyr, cPyrW )
            % double floating point calculation
            numLvl = length( cPyr{1} );
            numImg = length( cPyr );
            for lvl = numLvl: -1: 1
                pyrBlended{ lvl } = cPyr{1}{lvl} .* cPyrW{1}{lvl};
                pyrWSum{ lvl } = cPyrW{1}{lvl};
            end
            
            for i = 2: numImg
                for lvl = numLvl: -1: 1
                    pyrBlended{ lvl } = pyrBlended{ lvl } + cPyr{i}{lvl} .* cPyrW{i}{lvl};
                    pyrWSum{ lvl } = pyrWSum{ lvl } + cPyrW{i}{lvl};
                end            
            end
            for lvl = numLvl: -1: 1
                pyrBlended{ lvl } = pyrBlended{ lvl } ./ pyrWSum{lvl};
            end            
        end        
    end
end