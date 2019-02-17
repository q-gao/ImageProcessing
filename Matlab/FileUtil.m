classdef FileUtil < handle
    methods(Static)
        function d = LoadBinaryFile(fileName, size, precision)
            fid = fopen(fileName, 'rb');
            if fid == -1
                printf('FAILED to open %s\n', fileName);
                return;
            end
            d = fread(fid, size, precision);
            fclose(fid);
        end        
        
        function SaveMatrix( A, fileName, precision)
            fid = fopen(fileName, 'wb');
            if fid == -1
                printf('FAILED to open %s\n', fileName);
                return;
            end
            c = fwrite(fid, A , precision);
            fclose(fid);            
            if( prod(size(A)) ~= c )
                printf('ERROR in writing: only %d elements written', c);
            end
        end
    end
end
