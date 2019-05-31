function boolean_res = ita_diffraction_point_is_of_dim3(inputPoint)
%ITA_DIFFRACTION_POINT_IS_OF_DIM3 Checks if inputPoint is either a
%3-dimensional row or a 3-dimensional column vector
%   inputPoint: array
%   boolean_res: true if inputPoint is of dimension 3, false otherwise

dimPoint = size(inputPoint);

row3Dvec = (dimPoint(1) == 1 && dimPoint(2) == 3); 
column3Dvec = (dimPoint(1) == 3 && dimPoint(2) == 1);

boolean_res = row3Dvec || column3Dvec;
end

