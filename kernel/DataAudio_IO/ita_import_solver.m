function varargout = ita_import_solver(varargin)
%ITA_IMPORT_SOLVER - Imports Solver export files to itaAudio
%  This function imports Solver export textfiles containing a frequency
%  vector and the coresponding amplitude vector (in this order).
%
%  Syntax:
%   audioObj = ita_import_solver(sampling_rate,unit,name,[file])
%
%  Example:
%   result = ita_import_solver(44100,'Pa','Solver Import','./solver_file.txt');
%   result = ita_import_solver(44100,'Pa','Solver Import');
%   Or the same without target variable => Save result GUI.
%
%   See also: ita_import
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_import_solver">doc ita_import_solver</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  17-Jun-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(3,4);
sArgs        = struct('pos1_samplingrate','integer','pos2_unit','string','pos3_identifier','string');

[samplingrate,unit,identifier,sArgs] = ita_parse_arguments(sArgs,varargin(1:3)); %#ok<NASGU>

if nargin >= 4
    file    =   varargin{4};
else
    [data_file data_path]=uigetfile('*.txt');
    file = [data_path data_file];
end

%% Import
data_import = importdata(file);

%% Get frequencies and bins
freq_data   =   data_import(1:end,1)';
bin_dist    =   mean(diff(freq_data));
low_idx     =   round(freq_data(1)/bin_dist)+1;

%% Get complex data
real_data   =   data_import(1:end,2);
imag_data   =   data_import(1:end,3);
cmplx_data  =   complex(real_data,imag_data);

%% Construct itaAudio data array
nBins   =   round(samplingrate./2 ./ bin_dist);     %nBins of resulting itaAudio
a       =   zeros(1,nBins);

a(1,low_idx:low_idx+length(cmplx_data)-1)   =   cmplx_data;

%% Generate additional slopes

% slope_factor=   2^6;
% slope_begin =   (mean(diff(cmplx_data(1:2))))/slope_factor;
% slope_end   =   (mean(diff(cmplx_data((end-1):end))))/slope_factor;
% 
% n_begin             =   low_idx-1;
% frequencies_begin   =   linspace(cmplx_data(1)-(n_begin*slope_begin),cmplx_data(1)-(1*slope_begin),n_begin);
% n_end               =   length(a)-low_idx-length(cmplx_data)+1;
% frequencies_end     =   linspace(cmplx_data(end)+(1*slope_end),cmplx_data(end)+(n_end*slope_end),n_end);  
% 
% a(1,1:low_idx-1)                            =   frequencies_begin;
% a(1,low_idx+length(cmplx_data):end)         =   frequencies_end;

%% Assemble result
result = itaAudio(a,samplingrate,'freq');
result.comment          =   identifier;
result.channelNames{1}  =   result.comment;
result.channelUnits{1}  =   unit;
result.signalType = 'energy';

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Postprocessing
% result = ita_time_window(result,[0.00065 0.00100],'time');
% result = ita_extend_dat(result,ceil(ita_fft_degree(result)));
% result=ita_fft(result);

%% Bandwidth warning 
disp([thisFuncStr ' Result only exact for frequencies ' num2str(freq_data(1)) ' to ' num2str(freq_data(end)) '.']);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_plot_freq(result);
    ita_write(result);    
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end