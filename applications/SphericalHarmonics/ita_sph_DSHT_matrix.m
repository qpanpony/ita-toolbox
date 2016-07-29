function out = ita_sph_DSHT_matrix(sampling, varargin)
% matrix = ita_sph_DSHT_matrix(sampling, varargin)
% returns a matrix to proceed a discrete SHerical harmonic transform:
% value_SH = matrix*value_spatial (value_SH and value_spatial : column-vectors)
%
% input:
%   an itaSamplingSH or an itaSamplingSHReal - object, that contains 
%   (coordinate object with complex or real SHerical 
%
% options: 
% - method: there are several DSHT-methods. Select one:
%      - weighted_least_square
%      - least_square
%      - weighted_quadrature (see Dis Zotter or DA Martin Kunkemöller)
%
% - tol: maximum allowed regularization parameter for methods which use 
%         moore penrose pseudo inverse (via single value decomposition)
%
% this function is used in itaBalloon
% Martin Kunkemöller August 2010

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs = struct('method','weighted_least_square','tol',[]);
if nargin > 2
    sArgs = ita_parse_arguments(sArgs,varargin);
end
if isempty(sampling.Y)
	error('Your sampling contains no spherical harmonic basefunctions');
end
SH = sampling.Y;

switch sArgs.method
    case 'least_square'
        % Zotter S.75 (244) :  estimate coef, so that:
        %    error = (value - Y*coef)'*(value - Y*coef) --> min
        if isempty(sArgs.tol)
            cond_Y = cond(SH,2);
            if cond_Y > 100
                disp(['WARNING: condition of matrix s.Y is: ' num2str(cond_Y)]);
                disp('This may cause imprecise results. Consider defining a tolerance number. Then I can improove the matrix inversion via single value decomposition');
            end
            out = pinv(SH);
        else            
            out = pinv(SH, sArgs.tol);
        end        
    
        
    case 'weighted_least_square'

        % Zotter S.75 (244) :  estimate coef, so that:
        %    error = (value - Y*coef)'*diag(weights)*(value - Y*coef) --> min
        
        %TO DO: Müsste eigentlich wurst sein. Checken!!!
        weights = sampling.weights/sum(sampling.weights);
        Y = bsxfun(@times, SH, sqrt(weights));
       
        if isempty(sArgs.tol)
            cond_Y = cond(SH,2);
            if cond_Y > 100
                disp(['WARNING: condition of matrix s.Y is: ' num2str(cond_Y)]);
                disp('This may cause imprecise results. Consider defining a maximum tolerance. Then matrix inversion can be improoved via single value decomposition');
            end
            out = bsxfun(@times, pinv(Y), sqrt(weights).');
            
        else
            out = bsxfun(@times, pinv(Y, sArgs.tol), sqrt(weights).');
        end
        
        
    case 'weighted_quadrature'
        if sum(sampling.weights) - 4*pi > 1e-6
            error('If you use this method, your "weights" must have a sum equal 4 pi');
        end 
        disp('WARNING: Use this method only with an orthogonal sampling like "equiangular" or "gaussian"! Otherwise "weighted_least_squares" should be better!');
        % Williams Fourier Acoustics S.192 (6.49)
        % Dissertation Zotter S.73 (237) 
        
        out = SH' * diag(sampling.weights);
    otherwise
        error('Unknown method. Choose "leastsquares" or "quadrat"');
end

