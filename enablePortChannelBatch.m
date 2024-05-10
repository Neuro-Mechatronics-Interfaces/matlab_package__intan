function numBands = enablePortChannelBatch(intanTcpClient, portLetter, channels, bandType)
%ENABLEPORTCHANNELBATCH  Enable batch of channels for specified band type/port.
%
% Syntax:
%   numBands = intan.enablePortChannelBatch(intanTcpClient, portLetter, channels, bandType);
arguments
    intanTcpClient
    portLetter {mustBeMember(portLetter,{'a','b','c','d'})} = 'b';
    channels (1,:) {mustBeInteger, mustBeInRange(channels,0,255)} = 0:15;
    bandType {mustBeMember(bandType,{'wide','low','high'})} = 'high';
end

switch bandType
    case 'high'
        s = 'high';
    case 'low'
        s = 'low';
    case 'wide'
        s = '';
end

write(intanTcpClient, uint8('iexecute clearalldataoutputs')); 
for channelIndex = channels
    write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabled%s true', ...
        lower(portLetter), channelIndex, s)));
end
numBands = numel(channels);

end