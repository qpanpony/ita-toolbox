function [ varargout] = ita_make_fourpole(varargin)
%ITA_MAKE_FOURPOLE - Generate Fourpole Parameters
%    This function produces the transmission fourpole matrix
%    of an element (spring, mass, damper) in frequency domain
%
%    Call: audioObj = ita_make_fourpole(elType, elValue, sr, FFT_order)
%    Call: audioObj = ita_make_fourpole(itaAudio, 'leftright')
%    Call: audioObj = ita_make_fourpole(itaAudio, 'topbottom')
%    Call: audioObj = ita_make_fourpole('gyrator',Bl,44100,17)
%    Call: audioObj = ita_make_fourpole('transformator',Bl,44100,17)
%
%    elType:  spring, mass, damper
%    elValue: value of the element in SI units
%
%   See also ita_make_impedance, ita_plot_fourpole_matrix
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_make_fourpole">doc ita_make_fourpole</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  04-Jun-2008
% Modified: 03-Sep-2008 - pdi - Cleaning
% Modified: 08-Oct-2008 - pdi - Channel and unit information added
% Modified: 08-Oct-2008 - pdi - axis scaling deleted

%% Syntax check and parameters
if nargin == 0
    pList = [];
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Element type';
    pList{ele}.helptext    = 'What type of element?' ;
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'time';
    pList{ele}.list        = 'mass|spring|damper|transformator';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Value';
    pList{ele}.helptext    = 'What value?' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '1';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description    = 'Advanced Settings';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Sampling Rate';
    pList{ele}.helptext    = 'What value?' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '44100';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'FFT degree';
    pList{ele}.helptext    = 'What value?' ;
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = '14';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - ']);
    if ~isempty(pList)
        result = ita_make_fourpole(pList{1},pList{2}, pList{3},pList{4});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{5}, result);
    else
        varargout{1} = [];
    end
    return;
    
elseif nargin == 2
    if isa(varargin{1},'itaAudio') %audioObj is given
        element_type    = varargin{2};
        data = varargin{1}';
        sampling_rate   = data.samplingRate;
        FFT_order       = data.fftDegree; %abl: class function
        element_value   = 'predefined impedance';
    else
        element_type    = varargin{1};
        element_value   = varargin{2};
        sampling_rate   = 44100;
        FFT_order       = 12;
        disp(['ITA_MAKE_FOURPOLE:Sampling rate set to ' num2str(sampling_rate) ' and FFT_order to ' num2str(FFT_order) '.'])
    end
elseif nargin == 4
    element_type    = varargin{1};
    element_value   = varargin{2};
    sampling_rate   = varargin{3};
    FFT_order       = varargin{4};
else
    error ('ITA_MAKE_FOURPOLE:Please see syntax.')
end
error(nargoutchk(0,1,nargout,'string'))

%% Initialization
% nBins             = (2^(FFT_order) - 2 )/2 + 2; %considering positive frequencies only
imp = ita_generate('flat',1,sampling_rate,FFT_order);
frequency_vector  = imp;
frequency_vector.freqData  = imp.freqVector;
zerofreq_vector   = 0.*frequency_vector;

FP =  [imp,imp;imp,imp];

%% Calculation
switch lower(element_type)
    case {'mass'}
        %according to Hynnä
        FP(1,1) = 1 + zerofreq_vector;
        FP(1,2) = (1i * 2 * pi * frequency_vector * element_value);
        FP(2,1) = 0 + zerofreq_vector;
        FP(2,2) = 1 + zerofreq_vector;
        
    case {'spring'}
        FP(1,1) = 1 + zerofreq_vector;
        FP(1,2) = 0 + zerofreq_vector;
        FP(2,1) = (1i * 2 * pi * frequency_vector * element_value);
        FP(2,2) = 1 + zerofreq_vector;
        
    case {'damper','resistor','resistance'}
        FP(1,1) = 1 + zerofreq_vector;
        FP(1,2) = 0 + zerofreq_vector;
        FP(2,1) = 0 * frequency_vector + 1/element_value; %pdi correcty according to Hynnä
        FP(2,2) = 1 + zerofreq_vector;
        
    case {'unity','transformator'}
        FP(1,1) = element_value * imp;
        FP(1,2) = 0 * imp;
        FP(2,1) = 0 * imp;
        FP(2,2) = imp / element_value;
        
    case {'gyrator'}
        FP(1,1) = 0 * imp;        
        FP(1,2) = element_value * imp;
        FP(2,1) = imp / element_value;
        FP(2,2) = 0 * imp;
%         FP(1,1) = element_value * imp;
%         FP(1,2) = 0 * imp;
%         FP(2,1) = 0 * imp;
%         FP(2,2) = imp / element_value;
        
    case {'leftright'}
        FP(1,1) = 1 * imp;
        FP(1,2) = data;
        FP(2,1) = 0 * imp;
        FP(2,2) = 1 * imp;
%         FP(1,1) = 1 * imp;
%         FP(2,1) = data;
%         FP(1,2) = 0 * imp;
%         FP(2,2) = 1 * imp;

        
    case {'topbottom'}
        FP(1,1) = 1 * imp;
        FP(1,2) = 0 * imp;
        FP(2,1) = 1/data; %error 1/...
        FP(2,2) = 1 * imp;
  
end

%% Channel Units
unit_str = {'1','kg/s';'s/kg','1'};

%% Update header
for idx_x = 1:2
    for idx_y = 1:2
        FP(idx_x,idx_y).channelNames{1} = ['\alpha{' num2str(idx_x) num2str(idx_y) '},' element_type ', value:' num2str(element_value)];
        FP(idx_x,idx_y).channelUnits{1} = unit_str{idx_x,idx_y};
    end
end

FP = itaFourpole(FP);
FP.type = 'A';

%% Find appropriate Output paramters
varargout{1} = FP;

end
