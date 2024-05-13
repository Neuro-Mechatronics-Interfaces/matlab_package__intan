function waveformBytesTotal = computeBytesPerBlock(numBlocks, numAmplifierChannels, numAnalogChannels, digInPresent, numBandsPerChannel)
%COMPUTEBYTESPERBLOCK  Returns the total number of bytes in each block of data samples for an expected number of blocks read.
arguments
    numBlocks
    numAmplifierChannels
    numAnalogChannels
    digInPresent (1,1) logical
    numBandsPerChannel (1,1) {mustBeMember(numBandsPerChannel,[1 2 3])} = 1;
end
framesPerBlock = 128;
numAmplifierBands = numBandsPerChannel * numAmplifierChannels;

waveformBytesPerFrame = 4 + 2*(numAmplifierBands + numAnalogChannels + double(digInPresent));
waveformBytesPerBlock = framesPerBlock * waveformBytesPerFrame + 4;
waveformBytesTotal = numBlocks * waveformBytesPerBlock;

end