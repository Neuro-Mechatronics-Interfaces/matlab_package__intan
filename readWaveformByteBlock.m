function [data, timestamp] = readWaveformByteBlock(waveformTcpClient, numAmplifierChannels, numAnalogChannels, digInPresent, options)
%READWAVEFORMBYTEBLOCK  Reads the array of waveforms of specified number of blocks.
%
% Syntax:
%   [data, timestamp] = intan.readWaveformByteBlock(waveformTcpClient, numChannels, digInPresent, blocksPerRead, timestep);
%
% Inputs:
%   waveformTcpClient - TCP Client connected to RHX waveforms (default port is 5001).
%   blocksPerRead     - Number of sample "blocks" to read for chunk.

arguments
    waveformTcpClient
    numAmplifierChannels (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(numAmplifierChannels,0)}; % Number of unique channel/band combinations sent to waveform socket
    numAnalogChannels (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(numAnalogChannels,0)}
    digInPresent (1,1) logical;
    options.BlocksPerRead (1,1) {mustBePositive, mustBeInteger} = 100;
    options.SampleRate (1,1) {mustBePositive} = 20000; % 
    options.NumBandsPerChannel (1,1) {mustBeMember(options.NumBandsPerChannel,[1,2,3])} = 1;
    options.MagicNumber (1,1) = 0x2ef07a08;
end

timestep = 1/options.SampleRate;
MAGIC_NUMBER = options.MagicNumber;

% Calculations for accurate parsing
framesPerBlock = 128;
numAmplifierBands = options.NumBandsPerChannel * numAmplifierChannels;

waveformBytesPerFrame = 4 + 2*(numAmplifierBands + numAnalogChannels + double(digInPresent));
waveformBytesPerBlock = framesPerBlock * waveformBytesPerFrame + 4;
waveformBytesTotal = options.BlocksPerRead * waveformBytesPerBlock;

if waveformTcpClient.NumBytesAvailable < waveformBytesTotal
    data = [];
    timestamp = [];
    return;
else
    waveformArray = read(waveformTcpClient, waveformBytesTotal);
end

timestampIndex = 1;
rawIndex = 1;

timestamp = zeros(1, options.BlocksPerRead);
data = zeros(numAmplifierBands, options.BlocksPerRead);
should_display_error_indicator = true;

% Read all incoming blocks
for block = 1:options.BlocksPerRead

    % Read waveform data

    % Expect 4 bytes to be TCP Magic Number as uint32.
    % If not what's expected, print that there was an error.
    offset = 0;
    [magicNumber, rawIndex] = intan.uint32ReadFromArray(waveformArray, rawIndex);
    while magicNumber ~= MAGIC_NUMBER
        if should_display_error_indicator
            warning("Incorrect magic number detected (block = %d)! Cycling input bytes until we get back on track...", block);
            cycleTic = tic;
            should_display_error_indicator = false;
        end
        rawIndex = 1;
        waveformArray = circshift(waveformArray,-1);
        offset = offset + 1;
        waveformArray(end) = read(waveformTcpClient,1); % Read one more byte and try again!
        [magicNumber, rawIndex] = intan.uint32ReadFromArray(waveformArray, rawIndex);
    end
    if ~should_display_error_indicator
        fprintf(1,'Magic Number is correctly 0x2ef07a08 after %5.2f seconds (offset = %d bytes)!\n', round(toc(cycleTic),2), offset);
        should_display_error_indicator = true;
    end
    % Each block should contains 128 frames of data - process each of
    % these one-by-one
    for frame = 1:framesPerBlock
        [timestamp(1, timestampIndex), rawIndex] = ...
                        intan.int32ReadFromArray(waveformArray, rawIndex);
        for channelIndex = 1:(numAmplifierBands+numAnalogChannels+digInPresent)
            [data(channelIndex, timestampIndex), rawIndex] = ...
                        intan.uint16ReadFromArray(waveformArray, rawIndex);
        end
        timestampIndex = timestampIndex + 1;
    end
    
    
end
timestamp = timestamp .* timestep;
data(1:numAmplifierBands,:) = 0.195 * (data(1:numAmplifierBands,:) - 32768);
if numAnalogChannels > 0
    analogChannelsVec = (numAmplifierBands+1):(numAmplifierBands+numAnalogChannels);
    data(analogChannelsVec,:) = 312.5e-6 * (data(analogChannelsVec,:) - 32768);
end

end