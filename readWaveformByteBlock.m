function [data, timestamp] = readWaveformByteBlock(waveformTcpClient, numChannels, blocksPerRead, timestep)
%READWAVEFORMBYTEBLOCK  Reads the array of waveforms of specified number of blocks.
%
% Syntax:
%   [data, timestamp] = intan.readWaveformByteBlock(waveformTcpClient, blocksPerRead, timestep);
%
% Inputs:
%   waveformTcpClient - TCP Client connected to RHX waveforms (default port is 5001).
%   blocksPerRead     - Number of sample "blocks" to read for chunk.

arguments
    waveformTcpClient
    numChannels (1,1) {mustBePositive, mustBeInteger};
    blocksPerRead (1,1) {mustBePositive, mustBeInteger} = 100;
    timestep (1,1) {mustBePositive} = 1/20000; % 1 / sample rate
end

% Calculations for accurate parsing
framesPerBlock = 128;
waveformBytesPerFrame = 4 + (2 + 2);
waveformBytesPerBlock = framesPerBlock * waveformBytesPerFrame + 4;
waveformBytes100Blocks = blocksPerRead * waveformBytesPerBlock;

waveformArray = read(waveformTcpClient, waveformBytes100Blocks);


timestamp = zeros(framesPerBlock, blocksPerRead);
data = zeros(numChannels, blocksPerRead);
timestampIndex = 1;
waveformIndex = 1;

% Read all incoming blocks
for block = 1:blocksPerRead

    % Read waveform data

    % Expect 4 bytes to be TCP Magic Number as uint32.
    % If not what's expected, print that there was an error.
    [magicNumber, waveformIndex] = intan.uint32ReadFromArray(waveformArray, waveformIndex);
    if magicNumber ~= 0x2ef07a08
        fprintf(1, 'Error... block %d magic number incorrect.\n', block);
    end
    % Each block should contains 128 frames of data - process each of
    % these one-by-one
    for frame = 1:framesPerBlock

        % Expect 4 bytes to be timestamp as int32.
        [timestamp(1, timestampIndex), waveformIndex] = intan.int32ReadFromArray(waveformArray, waveformIndex);
        timestamp(1, timestampIndex) = timestep * timestamp(1, timestampIndex);
        
        [data(waveformIndex, timestampIndex), waveformIndex] = intan.uint16ReadFromArray(waveformArray, waveformIndex);
        timestampIndex = timestampIndex + 1;
    end

end

end