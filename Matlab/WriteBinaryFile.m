function WriteBinaryFile(fileName, data, precision)
    fid = fopen(fileName, 'wb');
    if fid == -1
        printf('FAILED to open %s\n', fileName);
        return;
    end
    fwrite(fid, data, precision);
    fclose(fid);
end