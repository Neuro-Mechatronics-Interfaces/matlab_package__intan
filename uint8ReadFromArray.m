function [var, arrayIndex] = uint8ReadFromArray(array, arrayIndex)
%UINT8READFROMARRAY  Read 1 byte from array as uint8
var = array(arrayIndex);
arrayIndex = arrayIndex + 1;
end