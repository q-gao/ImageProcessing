function Y = LoadYFromYUV420File_10bit(fnm, w, h)
% To disable it: 
%   imshow(Y, [0, 1024]) or imshow(Y', [])
    fid = fopen(fnm, "r");
    if -1 == fid
        fprintf("FAILED to open %s\n", fnm);
        Y = []
        return;
    end
    Y = fread(fid, [w, h], 'uint16');
    fclose(fid);
end