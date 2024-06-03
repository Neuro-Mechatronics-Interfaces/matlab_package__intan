function setFileSavePeriod(intanTcpClient, nMinutes)
%SETFILESAVEPERIOD  Sets the recording file save period (minutes)
%
% Example:
%   intan.setFileSavePeriod(intanTcpClient, 15); % Sets to 15 minutes
arguments
    intanTcpClient
    nMinutes (1,1) {mustBeInteger, mustBeInRange(nMinutes, 1,999)} = 15;
end
write(intanTcpClient, uint8(sprintf('set newsavefileperiodminutes %d',nMinutes)));

end