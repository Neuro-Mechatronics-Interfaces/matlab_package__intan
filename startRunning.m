function startRunning(intanTcpClient)
%STARTRUNNING  Starts sampling from Intan RHX without recording
%
% Syntax:
%   intan.startRunning(intanTcpClient);

write(intanTcpClient, uint8('set runmode run'));

end