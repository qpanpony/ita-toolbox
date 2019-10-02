function scatteringCoeffs = ita_calculateScatteringCoefficients(charDepth, valueRange)
% ita_calculateScatteringCoefficients
%
%   this function calculates the scattering coefficients for one-third
%   octave frequency bands according to the structural dimension of a
%   material. Results can be directly used for RAVEN simulations
%
%   Equation according to: Postma (2015) - Creation and calibration method of acoustical models for historic virtual reality
%   described as identical to "estimate" function in CATT acoustics
%
%   INPUT: charDepth in m 
%   (see Vorländer (2008) - Auralization, Annex, Fig. A.1., p. 311)
%   
%   OUTPUT: scatteringCoeffs (vector  of 31 entries,
%           corresponding to center frequencies from 20 Hz to 20 kHz)
%           Limited to a value range from [0.1 to 0.99]
%
%   <ITA-Toolbox>
%   This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
%   You can find the license for this m-file in the application folder.
%   </ITA-Toolbox>

    if nargin == 1 % if only charDepth given
        valueRange = [0.1 0.99];
    end

    centerFreqs = ita_ANSI_center_frequencies([20 20000],3);
    waveLengths = 343 ./ centerFreqs;

    scatteringCoeffs = 0.5*sqrt(charDepth./waveLengths);

    scatteringCoeffs = max(valueRange(1),scatteringCoeffs);
    scatteringCoeffs = min(valueRange(2),scatteringCoeffs);

end

