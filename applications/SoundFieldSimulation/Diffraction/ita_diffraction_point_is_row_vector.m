function isRowVec = ita_diffraction_point_is_row_vector( inputVector )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(inputVector, 1) ~= 1
    isRowVec = false;
else
    isRowVec = true;
end

