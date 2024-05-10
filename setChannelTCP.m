function setChannelTCP(intanTcpClient, portLetter, channelNumber, enableLow, enableHigh, enableWide, enableSpike)
%SETCHANNELTCP  Set channel TCP state.
%
% Syntax:
%   intan.setChannelTCP(intanTcpClient, portLetter, channelNumber, enableHigh, enableSpike);
%
% Inputs:
%   intanTcpClient - tcpclient connected to RHX tcp server socket
%   portLetter

arguments
    intanTcpClient
    portLetter {mustBeTextScalar, mustBeMember(portLetter, {'a','b','c','d'})}
    channelNumber {mustBeInteger, mustBeInRange(channelNumber, 0, 255)}
    enableLow (1,1) logical = false;
    enableHigh (1,1) logical = true;
    enableWide (1,1) logical = false;
    enableSpike (1,1) logical = false;
end

if enableHigh
    enableHighStr = 'true';
else
    enableHighStr = 'false';
end

if enableSpike
    enableSpikeStr = 'true';
else
    enableSpikeStr = 'false';
end

if enableLow
    enableLowStr = 'true';
else
    enableLowStr = 'false';
end

if enableWide
    enableWideStr = 'true';
else
    enableWideStr = 'false';
end
write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabled %s', lower(portLetter), channelNumber, enableWideStr)));
write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabledhigh %s', lower(portLetter), channelNumber, enableHighStr)));
write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabledlow %s', lower(portLetter), channelNumber, enableLowStr)));
write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabledspike %s', lower(portLetter), channelNumber, enableSpikeStr)));

end