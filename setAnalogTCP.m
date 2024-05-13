function setAnalogTCP(intanTcpClient, channelNumber, enable)
%SETDIGITALTCP  Sets DIG-IN TCP enable status for waveform client
arguments
    intanTcpClient
    channelNumber (1,1) {mustBeInteger, mustBeInRange(channelNumber, 1, 8)}
    enable (1,1) logical
end
if enable
    enableStr = 'true';
else
    enableStr = 'false';
end
write(intanTcpClient, uint8(sprintf('set analog-in-%1d.tcpdataoutputenabled %s', channelNumber, enableStr)));
end