function [var, arrayIndex] = int32ReadFromArray(array, arrayIndex)
%INT32READFROMARRAY Read 4 bytes from array as int32
varBytes = array(arrayIndex : arrayIndex + 3);
var = typecast(uint8(varBytes), 'int32');
arrayIndex = arrayIndex + 4;
end