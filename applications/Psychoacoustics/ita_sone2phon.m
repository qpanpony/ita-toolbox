function varargout = ita_sone2phon(input)
%ITA_SONE2PHON - convert sone values to phon values
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_sone2phone(audioObjIn)
%
%
%  Example:
%   audioObjOut = ita_sone2phone(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sone2phone">doc ita_sone2phone</a>

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: martin.guski@akustik.rwth-aachen.de
% Created:  30-Sep-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 


if isa(input, 'itaResult')
    
    if  ~all(strcmp('sone', input.channelUnits))
        error('ChannelUnits must be sone.-')
    end
    
    output = itaResult(input);
    
    idxBiggerOrEqualToOne = input.timeData >=1;
    
    % 10*log2(N) = 10 * log2(10) *log10(N) is approximately 33.22*log10(N)
    output.timeData(idxBiggerOrEqualToOne) = 40+10*log2(input.timeData(idxBiggerOrEqualToOne));           % >= 1 sone
    output.timeData(~idxBiggerOrEqualToOne) = 40*(input.timeData(~idxBiggerOrEqualToOne) + 0.0005).^0.35;      % < 1 sone
    
    output.channelUnits(:) = {'phon'};
    %% Add history line
    output = ita_metainfo_add_historyline(output,mfilename);


elseif isa(input, 'itaValue')
    if ~all(strcmp({input.unit}, 'sone'))
        error('Unit must be sone.-')
    end
    output = itaValue(input);
    
    for iValue = 1:length(input) 
        if input(iValue).value >= 1
            output(iValue).value = 40+10*log2(input(iValue).value); % 10*log2(N) = 10 * log2(10) *log10(N) is approximately 33.22*log10(N)
        else
            output(iValue).value = 40*(input(iValue).value + 0.0005).^0.35;
        end
        output(iValue).unit = 'phon';
    end
        
    
else
    error('Input has to be itaResult or itaVAlue!')
end

% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);




%% Set Output
varargout(1) = {output}; 

%end function
end