function numBands = enablePortChannelBatch(intanTcpClient, portLetter, channels, bandType, options)
%ENABLEPORTCHANNELBATCH  Enable batch of channels for specified band type/port.
%
% Syntax:
%   numBands = intan.enablePortChannelBatch(intanTcpClient, portLetter, channels, bandType);
arguments
    intanTcpClient
    portLetter {mustBeMember(portLetter,{'a','b','c','d'})} = 'b';
    channels (1,:) {mustBeInteger, mustBeInRange(channels,0,255)} = 0:15;
    bandType {mustBeMember(bandType,{'wide','low','high'})} = 'high';
    options.EnableTCP (1,1) logical = true;
end

switch bandType
    case 'high'
        s = 'high';
    case 'low'
        s = 'low';
    case 'wide'
        s = '';
end

write(intanTcpClient, uint8('execute clearalldataoutputs')); 
for channelIndex = channels
    write(intanTcpClient, uint8(sprintf('set %s-%03d.enabled true', lower(portLetter), channelIndex)));
    % write(intanTcpClient, uint8(sprintf('set %s-%03d.recordingenabled true', lower(portLetter), channelIndex)));
    if options.EnableTCP
        write(intanTcpClient, uint8(sprintf('set %s-%03d.tcpdataoutputenabled%s true', ...
            lower(portLetter), channelIndex, s)));
    end
end
numBands = numel(channels);

end