function setFile(intanTcpClient, SUBJ, YYYY, MM, DD, BLOCK, options)
%SETFILE  Sets file name and optionally the save folder.
%
% Syntax:
%   intan.setFile(intanTcpClient, SUBJ, YYYY, MM, DD, BLOCK);

arguments
    intanTcpClient
    SUBJ {mustBeTextScalar}
    YYYY {mustBeNumeric}
    MM {mustBeNumeric}
    DD {mustBeNumeric}
    BLOCK {mustBeInteger}
    options.DataTankFolder {mustBeTextScalar} = "";
end

if strlength(options.DataTankFolder) > 0
    write(intanTcpClient, uint8(sprintf('set Filename.Path %s', options.DataTankFolder)));
end
write(intanTcpClient, uint8(sprintf('set Filename.BaseFilename %s_%04d_%02d_%02d_%d', SUBJ, YYYY, MM, DD, BLOCK)));
    
end