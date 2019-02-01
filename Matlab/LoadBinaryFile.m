function d = LoadBinaryFile(fileName, size, precision)
    fid = fopen(fileName, 'rb');
    if fid == -1
        printf('FAILED to open %s\n', fileName);
        return;
    end
    d = fread(fid, size, precision);
    fclose(fid);
end