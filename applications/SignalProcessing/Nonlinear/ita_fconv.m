function varargout = ita_fconv(varargin)
%ITA_FCONV - Convolution in frequency domain to avoid aliasing
%   
%   Input at position one needs to be an itaAudio Object. Input at position
%   two can either be a second itaAudio Object or a double. In case of an
%   double value the signal will be calculated to the power of the double
%   value;
%
%  Syntax:
%   audioObjOut = ita_fconv(audioObjIn1, audioObjIn2)
%   audioObjOut = ita_fconv(audioObjIn1, double)
%
%  Example:
%   y = ita_fconv(x, h) = x.*h
%   y = ita_fconv(x, 2) = x.^2
%
%   
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_fconv">doc ita_fconv</a>

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:   05-Jul-2010 
% Modified:  12-Jul-2010 % Alexandre Bleus
% Rewritten: 07-Feb-2015


%% Initialization and Input Parsing
sArgs        = struct('pos1_input1','itaAudio', 'pos2_input2','*');
[input1, input2] = ita_parse_arguments(sArgs,varargin);

%% Convolution Process

l1 = input1.nBins;
sr = input1.samplingRate;
input1.signalType = 'power';

% frequency domain convoltion of two signals via multiplication in time
% domain
if isa(input2,'itaAudio')
    input1.freqData =  [input1.freqData; zeros(size(input1.freqData)-[2,0])];
    input2.signalType = 'power';
    input2.freqData =  [input2.freqData; zeros(size(input2.freqData)-[2,0])];
    input1.samplingRate = input1.samplingRate * 2;
    input2.samplingRate = input2.samplingRate * 2;
    output = input1 .* input2;    
    
% rise input1 to the power of input2
elseif isa(input2,'double')
    input1.freqData =  [input1.freqData; repmat(zeros(size(input1.freqData)-[2,0]),input2-1,1)];
    input1.samplingRate = input1.samplingRate * input2;
    output = input1 .^ input2;
else
    ita_verbose_info('I cannot perform a frequency domain convolution for these input values.',0);
    return;
end

output.freqData = output.freqData(1:l1,:);
% output.freqData(end,:)  = 0; % Nyquist
output.samplingRate     = sr;

%% Set Output
varargout(1) = {output}; 

end