% Example:
%  NOTE: the transpose applied to raw if raw has the same layout as raw 
%        read with LoadRaw
%
%       WriteBinaryFile('merged_mean.raw14', raw', 'uint16');
%
function WriteBinaryFile(fileName, data, precision)
    fid = fopen(fileName, 'wb');
    if fid == -1
        printf('FAILED to open %s\n', fileName);
        return;
    end
    fwrite(fid, data, precision);
    fclose(fid);
end