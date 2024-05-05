function setChannelTCP(intanTcpClient, portLetter, channelIndex, enableHigh, enableSpike)
%SETCHANNELTCP  Set channel TCP state.
%
% Syntax:
%   intan.setChannelTCP(intanTcpClient, portLetter, channelIndex, enableHigh, enableSpike);
%
% Inputs:
%   intanTcpClient - tcpclient connected to RHX tcp server socket
%   portLetter

arguments
    intanTcpClient
    portLetter {mustBeTextScalar, mustBeMember(portLetter, ["a", "b", "c", "d"])}
    channelIndex {mustBeInteger, mustBeInRange(channelIndex, 0, 255)}
    enableHigh (1,1) logical = true;
    enableSpike (1,1) logical = true;
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

write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabledhigh %s', lower(portLetter), channelIndex, enableHighStr)));
write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabledspike %s', lower(portLetter), channelIndex, enableSpikeStr)));

end