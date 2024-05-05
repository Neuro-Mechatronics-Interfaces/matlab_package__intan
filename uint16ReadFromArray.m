function [var, arrayIndex] = uint16ReadFromArray(array, arrayIndex)
%UINT16READFROMARRAY  Read 2 bytes from array as uint16
varBytes = array(arrayIndex : arrayIndex + 1);
var = typecast(uint8(varBytes), 'uint16');
arrayIndex = arrayIndex + 2;
end