classdef VideoTool < handle
    methods(Static)
        function [G, numFrames] = GrayFromColorVideoFile( vidFile )
            % assume video format is RGB24
            v = VideoReader( vidFile );
            % see https://www.mathworks.com/matlabcentral/answers/250033-number-of-frames-in-video-file-with-matlab-2015b#answer_196870
            maxNumFrames = ceil( v.FrameRate * v.Duration );
            G = zeros(v.Height, v.Width, maxNumFrames, 'uint8');
            numFrames = 0;
            while hasFrame(v)
                numFrames = numFrames + 1;                
                G(:, :, numFrames) = rgb2gray(readFrame(v));
            end
        end
    end
end