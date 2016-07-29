function varargout = ita_guisupport_domainlist(type)
%ITA_GUISUPPORT_DOMAINLIST - List of domain currently supported by ita_menu
%
%  Syntax:
%   cellList = ita_guisupport_domainlist()
%
%   See also: ita_menu
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_guisupport_domainlist">doc ita_guisupport_domainlist</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009

%% Initialization and Input Parsing
ele = 0;
result = {struct('name','','accelerator','','separator','')}; %Init result. Will be overwritten in typical cases.

% itaaudio & itaresult.freq
if isa(type,'itaAudio') || (isa(type,'itaResult') && strcmpi(type.domain,'freq'))
    
    ele = ele + 1;
    result{ele}.name = 'Frequency';
    result{ele}.accelerator = 'M';
    result{ele}.separator = false;
    
    ele = ele + 1;
    result{ele}.name = 'Frequency and Phase';
    result{ele}.accelerator = 'P';
    result{ele}.separator = false;
    
    ele = ele + 1;
    result{ele}.name = 'Frequency and Group Delay';
    result{ele}.accelerator = 'G';
    result{ele}.separator = false;
    
    ele = ele + 1;
    result{ele}.name = 'Real and Imaginary Part';
    result{ele}.accelerator = 'K';
    result{ele}.separator = false;
end

%itaresult.freq
% bar

%itaaudio itaresult.time
if isa(type,'itaAudio') || (isa(type,'itaResult') && strcmpi(type.domain,'time'))
    
    ele = ele + 1;
    result{ele}.name = 'Time';
    result{ele}.accelerator = 'T';
    result{ele}.separator = true;
    
    ele = ele + 1;
    result{ele}.name = 'Time in dB';
    result{ele}.accelerator = 'Y';
    result{ele}.separator = false;
    
end

%itaaudio
if isa(type,'itaAudio')
    %     ele = ele + 1;
    %     result{ele}.name = 'Envelope';
    %     result{ele}.accelerator = '';
    %     result{ele}.separator = true;
    %
    %     ele = ele + 1;
    %     result{ele}.name = 'Cepstrum';
    %     result{ele}.accelerator = '';
    %     result{ele}.separator = false;
    
    ele = ele + 1;
    result{ele}.name = 'Spectrogram';
    result{ele}.accelerator = '';
    result{ele}.separator = true;
    
    ele = ele + 1;
    result{ele}.name = 'All';
    result{ele}.accelerator = '';
    result{ele}.separator = false;
end

% if isa(type,'itaResult') && strcmpi(type.domain,'freq') || isa(type,'itaAudio')
%     ele = ele + 1;
%     result{ele}.name = 'BarSpectrum';
%     result{ele}.accelerator = '';
%     result{ele}.separator = true;
% end


%% Find output parameters
varargout(1) = {result};
%end function
end