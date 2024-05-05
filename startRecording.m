function startRecording(intanTcpClient)
%STARTRECORDING  Starts recording from Intan RHX
%
% Syntax:
%   intan.startRecording(intanTcpClient);

write(intanTcpClient, uint8('set runmode record'));

end