function result = ita_write_mf(varargin)
%ITA_WRITE_MF - Write audioObj to disk as MF data file
%   This functions writes data as MF-spectrum (.spk) or time data (.dat) files
%
%   Call: ita_write_mf (itaAudio,filename, Options)
%
%   See also ita_read, ita_audioplay, ita_make_header.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_write">doc ita_write</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% TODO: allow flexible number of bits
NBITS = 32;

%% Init
thisFuncStr  = [upper(mfilename) ':'];    

%% ToDo: Help!
if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.spk';
    result{1}.comment = 'MF spectrum (*.spk)';
    result{2}.extension = '*.dat';
    result{2}.comment = 'MF time data (*.dat)';
    return;
end

sArgs = struct('pos1_data','itaSuper','pos2_filename','char','overwrite',false);
[ao, filename, sArgs] = ita_parse_arguments(sArgs,varargin); 

if exist(filename,'file') && ~sArgs.overwrite % Error because file exists
    error('FILE_EXISTS',[thisFuncStr 'Careful, file already exists, use overwrite option to disable error']);
end
% Everything ok, save

switch lower(filename((end-3):end))
    case '.dat'
        ita_verbose_info('saving MF time data (*.dat)');
        ao = ao.';
    case '.spk'
        ita_verbose_info('saving MF spectrum (*.spk)');
        ao = ao';
    otherwise
        error('please report this bug => mpo')
end

%% Start Writing to File
fod = fopen (filename,'w');		 % Open File
if (fod == -1)
    error([ thisFuncStr 'Oh Lord. File could not be opened!'])
else
    h = ita_make_MF_header(ao);
    
    %% normalization
    max_abs = max(max(abs(ao.data)));
    if max_abs > 1
        h.VoltageRange = 1 * max_abs;
    end
    
    %% Writing Header to File
    fwrite (fod,h.Samples,  'long');
    fwrite (fod,h.SamplingRate,'double');
    fwrite (fod,h.ADofs,       'ushort');
    fwrite (fod,h.nChannels,   'schar');
    fwrite (fod,h.KanalNr,     'schar');
    fwrite (fod,h.alleBearb,   'char');
    fwrite (fod,h.Preemph,     'char');
    fwrite (fod,h.LiCursAct,   'char');
    fwrite (fod,h.CursCross,   'char');
    fwrite (fod,h.CursLock,    'char');
    fwrite (fod,h.DrawMode,    'char');
    fwrite (fod,h.ODrawMode,   'char');
    fwrite (fod,h.Wei,         'char');
    fwrite (fod,h.nur0,        'char');
    fwrite (fod,h.NormMax0dB,  'char');
    fwrite (fod,h.Yzoom,       'char');
    fwrite (fod,h.Xlog,        'char');
    fwrite (fod,h.Ylog,        'char');
    fwrite (fod,h.VerNr,       'char');
    fwrite (fod,h.FFTnorm,     'char');
    fwrite (fod,h.VoltageRange,'double');
    fwrite (fod,h.Reserviert,  'schar');
    fwrite (fod,h.Hun,         'schar');
    fwrite (fod,h.Sec,         'schar');
    fwrite (fod,h.Min,         'schar');
    fwrite (fod,h.Hour,        'schar');
    fwrite (fod,h.Day,         'schar');
    fwrite (fod,h.Month,       'schar');
    fwrite (fod,h.Year,        'ushort');
    fwrite (fod,h.Start,       'long');
    fwrite_string(h.xAxUnit,3,fod)
    fwrite_string(h.yAxUnit,3,fod)
    fwrite (fod,h.Rand,        'long');
    fwrite (fod,h.Cursor,      'long');
    fwrite (fod,h.MainDelay,   'double');
    
    %% bug fix % TODO % - correct ontopdb etc for mf files
    h.OnTopdB = 50;
    h.Dyn = 100;
%     if strcmpi(h.Channel(1).Name,'Pa')
%         h.Volt0dB = 2e-5;
%     else
%         h.Volt0dB = 1;
%     end
    fwrite (fod,h.OnTopdB,     'double');
    fwrite (fod,h.Dyn,         'double');
    fwrite (fod,h.Volt0dB,     'double');
    fwrite (fod,h.LcursOld,    'ushort');
    fwrite (fod,h.RcursOld,    'ushort');
    fwrite_string(h.ADDAident,20,fod)

    %fix comment length
    if length(h.Comment) < 71
        h.Comment = [h.Comment repmat(' ',1,71-length(h.Comment))];
    else
        h.Comment = h.Comment(1:71); % pdi bug fixed
    end
    fwrite_string(h.Comment,71,fod)


    %% Writing Data to File
    if ao.isFreq
        % -----------------Writing Spectrum -----------------------------------------------------------------
            % check values
            ao.freq(1,:)   = real(ao.freq(1,:));
            ao.freq(end,:) = real(ao.freq(end,:));
            switch(NBITS)
                case {8,16,24,32}
                    for i = 1:h.nChannels
                        fwrite (fod,(real(ao.freq(:,i))),'float32');
                        fwrite (fod,(imag(ao.freq(:,i))),'float32');
                    end
                case 64
                    for i = 1:h.nChannels
                        fwrite (fod,(real(ao.freq(:,i))),'float64');
                        fwrite (fod,(imag(ao.freq(:,i))),'float64');
                    end
                otherwise
                    error([thisFuncStr 'Oh Lord. Wrong SampleSize and Bits.'])
            end

            % -----------------Writing Time Signal---------------------------------------------------------------
    elseif ao.isTime
            %Conversion using Quantization and VoltageRange: float -> integer
            %Quantisierung = str2num(h.ADDAident(1,1:2));  %#ok<ST2NM> pdi
            %pdi: nonsense 
            if NBITS == 24
                disp('ITA_WRITE:Sorry 24 bit time data does not work. Writing 32 bit.')
                NBITS = 32;
            end
            ao.time = ao.time * (2^(NBITS-1)-1) / h.VoltageRange;
            ao.time = ao.time + h.ADofs;
            % Fill Buffer with Data
            for j = 1:h.nChannels,
                buff(j:h.nChannels:h.Samples*h.nChannels) = ao.time(:,j);
            end;
            % Write DATA
            if NBITS == 8        % 1 Byte  per Sample
                fwrite (fod,buff,'schar');

            elseif NBITS == 16       % 2 Bytes per Sample
                fwrite (fod,buff,'short');

            elseif NBITS == 24       % 3 Bytes per Sample
                fwrite (fod,buff,'long');
                if verboseMode, disp('ITA_WRITE:Oh Lord. I am writing 32 anyways'), end;
            elseif NBITS == 32       % 4 Bytes per Sample
                fwrite (fod,buff,'long');
            else
                error('TODO')
%                 if verboseMode, disp(['ITA_WRITE:Oh Lord. A SampleSize of ' num2str(h.nSamplesize) '. I will take 4 instead.']), end;
%                 fwrite (fod,buff,'long');
            end;
    end
end
fclose all;		% Closing all Files
% cd(current_dir)
% warning(s_warn);

%% ---------------- Local Functions -------------------------------------------------------
function[]= fwrite_string (StringText,...    %Text (Textl?nge <= StringLength
    StringLength,...  %maximale Zeichenl?nge
    FileID)           %ID der ge?ffneten Datei
StrLen = length(StringText);
for ind = 1:StrLen,             StrText(ind) = StringText(ind);end %#ok<AGROW>
for ind = StrLen+1:StringLength,StrText(ind) = 0;            end
fwrite (FileID,StrLen,'char');
fwrite (FileID,StrText);
end

result = 1;
end
