function ita_export_bassyst(varargin)
%ITA_EXPORT_BASSYST - export SPL or Impedance for the Bassyst program
%  This function accepts an itaAudio object and a filename and writes the
%  data into a text file that can be imported by the program Bassyst.
%  Possible data types are pressure and impedance data, the data is written
%  in columns as frequency, SPL/abs(Z) and phase (in degree).
%
%  Caution: Bassyst only accepts less than 16k values! The function will
%  take care of this.
%
%  If the input object has more than one channel, the function is called
%  recursively and a file is produced for each channel.
%
%  Syntax:
%   ita_export_bassyst(audioObjIn, filename, options)
%
%   Options (default):
%           'limits' ([0 22050]) : vector with the frequency limits (in Hz)
%
%  Example:
%   ita_export_bassyst(audioObjIn,'bassyst_export.txt')
%   ita_export_bassyst(audioObjIn,'bassyst_export.txt','limits',[0 8000])
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_export_bassyst">doc ita_export_bassyst</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  01-Oct-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,6);
sArgs        = struct('pos1_data','itaSuper','pos2_filename','string','limits',[0 22050]);
[data,filename,sArgs] = ita_parse_arguments(sArgs,varargin); 
sArgs.limits(2) = min(sArgs.limits(2),max(data.freqVector));

    
%% prepare the data
if data.nChannels > 1 || size(data.freq,2) > 1
    ita_verbose_info([thisFuncStr 'More than one channel, you''ll get a file per channel!'],1);
    nChannels = data.nChannels;
    for i=1:nChannels
        new_filename = [filename(1:strfind(filename,'.txt')-1) num2str(i) '.txt'];
        ita_export_bassyst(data.ch(i),new_filename,'limits',sArgs.limits);
    end
    return;
end

% make sure to have 16k values at most
f = linspace(sArgs.limits(1),sArgs.limits(2),2^14);
ids =data.freq2index(f);
% leave out zero frequency
if round(f(1)) == 0
    ids = ids(2:end);
    f = f(2:end);
end

if strcmpi(data.channelUnits{1},'Pa') || strcmpi(data.channelUnits{1},'Pa/V') % pressure level
    ita_verbose_info([thisFuncStr 'This seems to be pressure data, writing SPL!'],1);
    firstLine = 'Freq [Hz]\tdBSPL\tPhase [Deg]';
    M = [f(:),20.*log10(abs(data.freq(ids)./20e-6)),angle(data.freq(ids)).*180/pi];
else % impedance
    ita_verbose_info([thisFuncStr 'Assuming this is impedance data, writing Impedance!'],1);
    firstLine = 'Freq [Hz]\tOhm\tPhase [Deg]';
    M = [f(:),abs(data.freq(ids)),angle(data.freq(ids)).*180/pi];
end

%% write data
fid = fopen(filename,'wt');
if fid ~= -1
    fprintf(fid,firstLine);
    fprintf(fid,'\r% 6.2f\t% 6.2f\t % 6.2f',M.');
    fclose(fid);
end

%end function
end