function [varargout] = ita_filter(varargin)
%ITA_FILTER - Filter function
%  This function generates the transfer functions H(z)=H(exp(j*omega)) of 
%  several types of filters with the help of the known filter coefficients
%  and applies the filter to a given itaAudio object.
%
%  Syntax:
%   audioObj = ita_filter(audioObj,filter,type,specs,order);
%
%  Examples (specs: -3dbFrequency):
%   High- & low-pass:
%   [filtered_audio filterObj] = ita_filter(audio,'lowpass','butterworth',1000,'order',1);
%   [filtered_audio filterObj] = ita_filter(audio,'highpass','butterworth',1000,'order',1);
%
%   Shelf (specs: [gain -3dbFrequency]): 
%   [filtered_audio filterObj] = ita_filter(audio,'shelf','low',[20 200],1);
%   [filtered_audio filterObj] = ita_filter(audio,'shelf','high',[20 900],1);
%
%   See also: ita_make_filter, ita_mpb_filter
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_filter">doc ita_filter</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  19-May-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio','pos2_filter','string','pos3_type','string','pos4_specs','double','order',2);
[data,filter,type,specs,sArgs] = ita_parse_arguments(sArgs,varargin); 
% order   =   sArgs.order; %pdi commented out


%% Get data attributes
data_samplingrate = data.samplingRate;
data_frequencies  = data.freqVector;
data_fft_degree   = data.fftDegree;

fn = data_samplingrate/2;

%% Filter and type switch
switch lower(filter)
    case 'lowpass'
        switch type
            case 'butterworth'
                f1  =   specs(1); %% Get corner frequency from freq. string
                b   =   [1 0.12];
                a   =   [1 -exp(-pi*f1/fn)];
                n   =   (a(1)+a(2))/(b(1)+b(2));
                specs_string = ['-3dB@' num2str(specs(1),' %dHz')];
                
            otherwise
                error([thisFuncStr ': Specified type unknown.']);
        end
        
    case 'highpass'
        
        switch type
            case 'butterworth'
                f1  =   specs(1); %% Get corner frequency from freq. string        
                b   =   [1 -1];
                a   =   [1 -exp(-pi*f1/fn)];
                n   =   (a(1)-a(2))/(b(1)-b(2));
                specs_string = ['-3dB@' num2str(specs(1),' %dHz')];
                
            otherwise
                error([thisFuncStr ': Specified type unknown.']);
        end
        
    case 'shelf'
        
        switch type
            case 'low'
                gain_db  =   specs(1);
                gain_lin =  10^(gain_db/20);
                try
                    f1  =   specs(2);
                catch ME
                    error([thisFuncStr ': Frequency information missing.']);
                end
                f2  =   f1*gain_lin;
                b   =   [-1 exp(-pi*f2/fn)];
                a   =   [1 -exp(-pi*f1/fn)];
                n   =   (-a(1)+a(2))/(-b(1)+b(2));
                specs_string = [num2str(specs(1),' %ddB') ', -3dB@' num2str(specs(2),' %dHz')];
            
            case 'high'
                gain_db  =   specs(1);
                gain_lin =  10^(gain_db/20);
                try
                    f1  =   specs(2);
                catch ME
                    error([thisFuncStr ': Frequency information missing.']);
                end
                f2  =   f1/gain_lin;
                b   =   [-1 exp(-pi*f2/fn)];
                a   =   [1 -exp(-pi*f1/fn)];
                n   =   (a(1)+a(2))/(b(1)+b(2));
                specs_string = [num2str(specs(1),' %ddB') ', -3dB@' num2str(specs(2),' %dHz')];
            
            otherwise
                error([thisFuncStr ': Specified type unknown.']);
        end
        
    otherwise
        error([thisFuncStr ': Specified filter unknown.']);
end

%% Use freqz to get Filter
h = freqz(b,a,data_frequencies,data_samplingrate);

%% Normalize
h   =   h.*n;

%% Assemble filter
filterObj  =   ita_generate('flat',1,data_samplingrate,data_fft_degree);
filterObj = ita_extract_dat(filterObj,data.nSamples);
filterObj.signalType   =   'energy';
filterObj.comment   =   [filter '(' type ', ' specs_string ')'];
filterObj.channelNames{1}   =   filterObj.comment;
filterObj.freqData     =   filterObj.freqData.*h;

%% Apply filter
result  =   data*filterObj;

%% TODO: Assemble Numerator and Denominator yourself...
%num     = b1 + b2*exp(-1*1*omega) + b3*exp(-1*2*omega) + b4*exp(-1*3*omega);
%den     = a1 + a2*exp(-1*1*omega) + a3*exp(-1*2*omega) + a4*exp(-1*3*omega);
%result = b0 * ( num / den) ;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
varargout(1) = {result};
varargout(2) = {filterObj};
end