function [var, arrayIndex] = char5ReadFromArray(array, arrayIndex)
%CHAR5READFROMARRAY Read 5 bytes from array as 5 chars
varBytes = array(arrayIndex : arrayIndex + 4);
var = native2unicode(varBytes);
arrayIndex = arrayIndex + 5;
end