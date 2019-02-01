function [Y, UV] = LoadYUVFromYUV420File_10bit(fnm, w, h)
% To disable it: 
%   imshow(Y, [0, 1024]) or imshow(Y', [])
    fid = fopen(fnm, "r");
    if -1 == fid
        fprintf("FAILED to open %s\n", fnm);
        Y = []; UV=[];
        return;
    end
    fprintf('File ID %d\n', fid);
    Y = fread(fid, [w, h], 'uint16');
    UV = fread(fid, w * h /2, 'uint16');
    fclose(fid);    
    UV = reshape(UV, [2, w/2, h/2]);
end