function varargout = ita_plottools_ticks(varargin)
%ITA_PLOTTOOLS_TICKS - Generate XTicks for Audio Data
%  This function generates the Ticks and Labels for the x-axis (frequency)
%  of Audio Data
%
%  Syntax: [xticks xlabels] = ita_plottools_ticks(mode_string)
%
%   See also ita_plot_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_ticks">doc ita_plottools_ticks</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  15-Apr-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_mode','char');
[mode_str,sArgs] = ita_parse_arguments(sArgs,varargin);

%% What mode is requested?
switch(lower(mode_str))
    case {'log'}
        % xlabel_vec  = {2 4 6 10 20 '' 40 '' 60 '' '' '' 100 200 ''  400 ''  '' ''  ''  ''  '1k' '2k' ''   '4k' ''   '6k' ''   ''   ''   '10k'    '20k' '' '40k' '' '60k' '' '' ''  '100k'    '200k' '' '400k' '' '600k' '' ''  ''  '1M'};
        % xtick_vec   = [2 4 6 10 20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 1000*[10 20   30  40   50  60   70 80 90]  10000*[10 20    30  40    50  60    70  80 90] 1000000];
        
        %pdi: new labels - consistency troughout :-)
        xlabel_vec  = {'0.1' '0.2' '' '0.4' '' '0.6' '' '' '' '1' '2' '' '4' '' '6' '' '' '' '10' '20' '' '40' '' '60' '' '' '' '100' '200' ''  '400' ''  '' ''  ''  ''  '1k' '2k' ''   '4k' ''   '6k' ''   ''   ''   '10k'    '20k' '' '40k' '' '60k' '' '' ''  '100k'    '200k' '' '400k' '' '600k' '' ''  ''  '1M' '5M'};
        xtick_vec   = [ 0.1   0.2  0.3   0.4   0.5  0.6  0.7  0.8  0.9 1   2  3   4   5  6  7  8  9   10 20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 1000*[10 20   30  40   50  60   70 80 90]  10000*[10 20    30  40    50  60    70  80 90] 1000000 5000000];
        
    case {'lin'}
        %XTicking -- Thanks to SFI!
        xlabel_vec  = {''   '2k'   '' '4k' ''   '6k' ''   '8k' ''  '10k'  ''   '12k'  ''   '14k'  ''    '16k' ''    '18k' ''   '20k'  ''   '22k'};
        xtick_vec   = [1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000 16000 17000 18000 19000 20000 21000 22000];
        
    case {'ansi'}
        freq            = ita_ANSI_center_frequencies;
        idxForKilo      = freq >= 1000;
        
        freqFormated    = freq;
        freqFormated(idxForKilo) = freqFormated(idxForKilo) / 1000;
              
        ansiLabel   = num2str(freqFormated', '%1.1f');
        
        labelCell = cell(size(ansiLabel,1), 1);
        for iLine = 1:size(ansiLabel,1)
            tmp =  ansiLabel(iLine,:);
            tmp = strrep(tmp, '.0', '');
            if idxForKilo(iLine)
                tmp = [ tmp 'k'];
            end
            labelCell{iLine} = tmp;
        end
        
        xlabel_vec  = labelCell;
        xtick_vec   = freq;        
        
    otherwise
        error([thisFuncStr 'What mode should this be?'])
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    
else
    % Write Data
    varargout{1} = xtick_vec;
    varargout{2} = xlabel_vec;
end

%end function
end