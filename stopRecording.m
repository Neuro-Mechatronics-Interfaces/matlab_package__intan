function stopRecording(intanTcpClient)
%STOPRECORDING  Stops recording from Intan RHX software.  
%
% Syntax:
%   intan.stopRecording(intanTcpClient);

write(intanTcpClient, uint8('set runmode stop'));

end