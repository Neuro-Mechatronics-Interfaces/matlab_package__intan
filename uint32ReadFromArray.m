function [var, arrayIndex] = uint32ReadFromArray(array, arrayIndex)
%UINT32READFROMARRAY Read 4 bytes from array as uint32
varBytes = array(arrayIndex : arrayIndex + 3);
var = typecast(uint8(varBytes), 'uint32');
arrayIndex = arrayIndex + 4;
end

