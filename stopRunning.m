function stopRunning(intanTcpClient)
%STOPRUNNING  Stops recording from Intan RHX software.  
%
% Syntax:
%   intan.stopRunning(intanTcpClient);

write(intanTcpClient, uint8('set runmode stop'));

end