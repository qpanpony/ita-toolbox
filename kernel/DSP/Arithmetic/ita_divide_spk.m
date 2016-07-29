function [ varargout ] = ita_divide_spk( varargin )
%ITA_DIVIDE_SPK - Division of two spectra
%   This function divides two spectra in frequency domain.
%
%   Syntax: audioObj = ita_divide_spk(num_spk,den_spk)
%  options:
%          regularization ([]) : freqRange e.g. [20 10000]
%          mode ('circular') : 'linear' deconvolution mode
%
%   See also ita_multiply_spk.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_divide_spk">doc ita_divide_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de

%% GUI required?
if nargin == 0
    
    ele = 1;
    pList{ele}.description = 'Numerator';
    pList{ele}.helptext    = 'This is the first itaAudio for the numerator';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Denominator';
    pList{ele}.helptext    = 'This is the second itaAudio for the denominator';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Regularization';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Use Regularization';
    pList{ele}.helptext    = 'This is a method to maintain the frequency range of the numerator spectrum and get good IR behavior.';
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Low Cutoff Frequency';
    pList{ele}.helptext    = 'Low Frequency for regularization';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 20;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'High Cuttoff Frequency';
    pList{ele}.helptext    = 'High Frequency for regularization';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 20000;
        
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Divide two itaAudio Objects']);
    if ~isempty(pList)
        
        if pList{3} %with regularization
            result = ita_divide_spk(pList{1},pList{2},'regularization',[pList{4} pList{5}]);
        else %without
            result = ita_divide_spk(pList{1},pList{2});
        end
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{6}, result);
    end
    return;
end

%% Initialization
sArgs   = struct('pos1_num','itaSuper','pos2_den','anything','regularization',[],'mode','circular','zerophase',true);
sArgs   = ita_parse_arguments(sArgs,varargin);
num     = sArgs.num;
den     = sArgs.den;

%% check denominator
if isa(den,'itaValue') || isnumeric(den)
    varargout{1} = ita_amplify(num,1/den); %re-route to ita_amplify
    return;
end

%% 'mode' deconvolution
if strcmpi(sArgs.mode,'linear')
    num = ita_extend_dat(num,num.nSamples * 2);
    den = ita_extend_dat(den,den.nSamples * 2);
end

%% check domain
if isTime(den)
    den = den';
end

if isTime(num)
   num = num'; 
end

%% Regularization or not?
if ~isempty( sArgs.regularization )
   res = num * ita_invert_spk_regularization(den,sArgs.regularization,'zerophase',sArgs.zerophase); %% TODO 
   if strcmpi(den.signalType ,'power') && strcmpi(num.signalType,'power')
       res.signalType = 'energy';
   end
   varargout{1} = res;
   return
end

result = num/den;

%% find output
varargout(1) = {result};