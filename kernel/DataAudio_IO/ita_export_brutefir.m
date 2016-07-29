function ita_export_brutefir(varargin)
%ITA_EXPORT_BRUTEFIR - export filter(s) and config file for bruteFIR
%  This function exports filters for convolution and if requested creates a
%  config file for bruteFIR for a given hardware and filter routing.
%
%  Syntax:
%   ita_export_brutefir(audioObjIn, options)
%
%   Options (default):
%           'fileName' ('brutefir_export') : filename
%           'fftDegree' (14)               : fftDegree
%           'minimumphase' (false)         : create minimumphase filter?
%           'nBlocks' (8)                  : split the filter into nBlocks
%           'writeConfig' (true)           : set to false to just write filters
%           'fileInput' (/dev/stdin)       : for using file I/O (offline convolution)
%           'fileOutput' (./tmp)           : for using file I/O (offline convolution)
%
%  Example:
%   ita_export_brutefir(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_export_brutefir">doc ita_export_brutefir</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  09-Nov-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'fileName','brutefir_export', 'fftDegree', 14, ...
                      'minimumphase', false, 'nBlocks',8,'sampleFormat','S16_NE','writeConfig',true, ...
                      'fileInput','/dev/stdin','fileOutput','./tmp');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

absPath = pwd; % for returning to the correct folder
samplingRate = input.samplingRate;
nBlocks = 2^nextpow2(sArgs.nBlocks); % for blockwise convolution
nFilters = input.nChannels;

ita_verbose_info([thisFuncStr 'I/O delay of BruteFIR will be ' num2str((2^(sArgs.fftDegree+1))/nBlocks/samplingRate) ' seconds!'],1);

%% some processing
if sArgs.minimumphase
    input = ita_minimumphase(input);
end

if input.fftDegree > sArgs.fftDegree
    ita_verbose_info([thisFuncStr 'your data vector is too long, I will cut it'],1);
    stopTime = (2^sArgs.fftDegree)/samplingRate;
    input = ita_extract_dat(ita_time_window(input,[0.95*stopTime 0.99*stopTime]),sArgs.fftDegree);
end

% normalize using rms (yes it is not defined for energy signals, I know)
% gives equal levels (better for comparison)
% flat rms is 1
input.signalType = 'energy';
input = input*1/double(max(input.rms));
% input.freq = input.freq./max(abs(input.freq(:))); % normalize in frequency domain

%% get hardware (for the config file only)
if sArgs.writeConfig
    hw = playrec('getDevices');
    % for now only the ALSA sound system is supported (and file I/O)
    alsa = zeros(numel(hw),1);
    hw_names = cell(numel(hw),1);
    for i = 1:numel(hw)
        alsa(i) = strcmpi(hw(i).hostAPI,'alsa') || strcmpi(hw(i).hostAPI,'oss');
        hw_names{i} = hw(i).name;
    end
    hw_names = hw_names(logical(alsa));
    % for manually entering the soundcard, e.g. on a different computer
    hw_names = [hw_names; {'< enter settings manually >'}];
    % lets also add possibility for files
    hw_names = [hw_names; {'< input / output with files >'}];
    hw = hw(logical(alsa));
    
    % ask the user for the soundcard to use
    [sCardIdx,selectionMade] = listdlg('PromptString','Select the soundcard',...
        'SelectionMode','single','ListString',hw_names,'ListSize',[length(hw_names{1})*10 numel(hw_names)*20]);
    if selectionMade
        % manual mode
        if sCardIdx > numel(hw) && ~isempty(strfind(hw_names{sCardIdx},'manually'))
            hw = make_hardware_GUI();
        % file mode (e.g. read from stdin and return in raw tmp file (stereo)
        elseif ~isempty(strfind(hw_names{sCardIdx},'files'))
            hw = struct('name',sArgs.fileInput, 'outputName', sArgs.fileOutput, ...
                        'inputChans',2,'outputChans',2);
        else
            hw = hw(sCardIdx);
        end
    else
        hw = hw(1);
    end
    
    nInput = hw.inputChans;
    nOutput = hw.outputChans;
    % on unix systems, the soundcards usually contain hw, e.g. hw:0,0
    if ~isempty(strfind(hw.name,'hw'))
        deviceStr = hw.name(strfind(hw.name,'hw')+(0:5));
    else
        deviceStr = hw.name;
    end
    
    % display a GUI for the input / output relations
    if nInput <= 0 || nOutput <= 0
        error([thisFuncStr 'no input or output channels available']);
    else
        [fromStr,toStr,coeffStr] = make_filter_GUI(nInput,nOutput,nFilters);
        %     fromStr = {'0','1'};
        %     toStr = {'0','1'};
        %     coeffStr = {'1','2'};
    end
    
    inChannels = unique(str2double(fromStr));
    outChannels = unique(str2double(toStr));
    
    % export the basic config for brutefir
    filename = [sArgs.fileName '_config'];
    fid = fopen(filename,'wt');
    if fid~=-1
        % basic settings
        fprintf(fid,'%s\n',['sampling_rate: ' num2str(samplingRate) ';']);
        fprintf(fid,'%s\n',['filter_length: ' num2str((2^sArgs.fftDegree)/nBlocks) ',' num2str(nBlocks) ';']);
        fprintf(fid,'%s\n','show_progress: false;');
        fprintf(fid,'%s\n','');
        
        % filters
        fprintf(fid,'%s\n','## COEFFS ##');
        fprintf(fid,'%s\n','');
        if nFilters > 1
            for i = 1:nFilters
                fprintf(fid,'%s\n',['coeff "filter' num2str(i) '" {']);
                fprintf(fid,'%s\n',['     filename: ".' [filesep sArgs.fileName num2str(i)] '";']);
                fprintf(fid,'%s\n','};');
                fprintf(fid,'%s\n','');
            end
        else
            fprintf(fid,'%s\n','coeff "filter1" {');
            fprintf(fid,'%s\n',['     filename: ".' filesep sArgs.fileName '";']);
            fprintf(fid,'%s\n','};');
            fprintf(fid,'%s\n','');
        end
        
        % input / output
        inChStr = mat2str(inChannels).';
        inChStr = inChStr(~isspace(inChStr));
        if numel(inChannels) > 1
            inChStr = inChStr(2:end-1);
            inChStr = [inChStr [repmat(',',numel(inChannels)-1,1);' ']].';
        end
        inChStr2 = [num2str(nInput) '/' inChStr(:).'];
        
        fprintf(fid,'%s\n',['input ' inChStr(:).' ' {']);
        if ~isempty(strfind(hw_names{sCardIdx},'files'))
            fprintf(fid,'%s\n',['     device: "file" { path: "' hw.name '";};']);
        else
            fprintf(fid,'%s\n',['     device: "alsa" { device: "' deviceStr '"; ignore_xrun: true;};']);
        end
        fprintf(fid,'%s\n',['     sample: "' sArgs.sampleFormat '";']);
        fprintf(fid,'%s\n',['     channels: ' inChStr2 ';']);
        fprintf(fid,'%s\n','};');
        fprintf(fid,'%s\n','');
        
        outChStr = mat2str(outChannels).';
        outChStr = outChStr(~isspace(outChStr));
        if numel(outChannels) > 1
            outChStr = outChStr(2:end-1);
            outChStr = [outChStr, [repmat(',',numel(outChannels)-1,1);' ']].';
        end
        outChStr2 = [num2str(nInput) '/' outChStr(:).'];
        
        fprintf(fid,'%s\n',['output ' outChStr(:).' ' {']);
        if ~isempty(strfind(hw_names{sCardIdx},'files'))
            fprintf(fid,'%s\n',['     device: "file" { path: "' hw.outputName '";};']);
        else
            fprintf(fid,'%s\n',['     device: "alsa" { device: "' deviceStr '"; ignore_xrun: true;};']);
        end
        fprintf(fid,'%s\n',['     sample: "' sArgs.sampleFormat '";']);
        fprintf(fid,'%s\n',['     channels: ' outChStr2 ';']);
        fprintf(fid,'%s\n','     dither: true;');
        fprintf(fid,'%s\n','};');
        fprintf(fid,'%s\n','');
        
        % filter routing
        for i = 1:nFilters
            fprintf(fid,'%s\n',['filter ' num2str(i-1) ' {']);
            fprintf(fid,'%s\n',['     from_inputs: ' fromStr{i} ';']);
            fprintf(fid,'%s\n',['     to_outputs: ' toStr{i} ';']);
            fprintf(fid,'%s\n',['     coeff: "filter' coeffStr{i} '";']);
            fprintf(fid,'%s\n','};');
            fprintf(fid,'%s\n','');
        end
    end
end

%% export filter(s)
if nFilters > 1
    for i = 1:nFilters
        dlmwrite([absPath filesep sArgs.fileName num2str(i)],input.ch(i).time);
    end
else
    dlmwrite([absPath filesep sArgs.fileName],input.time);
end


%end function
end

%% subfunctions
function hw = make_hardware_GUI()

thisFuncStr  = [upper(mfilename) ':'];
pList = [];

ele = numel(pList) + 1;
pList{ele}.description = 'Soundcard data';
pList{ele}.datatype    = 'text';

ele = numel(pList) + 1;
pList{ele}.datatype    = 'line';

ele = numel(pList) + 1;
pList{ele}.description = 'Soundcard name';
pList{ele}.helptext    = 'The hardware name of your soundcard';
pList{ele}.datatype    = 'char';
pList{ele}.default     = 'hw:0,0';

ele = numel(pList) + 1;
pList{ele}.description = '# Input Channels';
pList{ele}.helptext    = 'The number of input channels of your soundcard';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 2;

ele = numel(pList) + 1;
pList{ele}.description = '# Output Channels';
pList{ele}.helptext    = 'The number of output channels of your soundcard';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 2;

pList = ita_parametric_GUI(pList,'Soundcard GUI');
if ~isempty(pList)
    hw.name = pList{1};
    hw.inputChans = double(pList{2});
    hw.outputChans = double(pList{3});
else
    error([thisFuncStr 'operation cancelled by user']);
end

end % end function

function [fromStr,toStr,coeffStr] = make_filter_GUI(nIn,nOut,nFilt)

thisFuncStr  = [upper(mfilename) ':'];
in_vec = 0:nIn-1;
out_vec = 0:nOut-1;
filt_vec = 1:nFilt;

pList = repmat({struct()},5*nFilt,1);

for i = 1:nFilt
    pList{(i-1)*5+1}.description = ['Filter routing #' num2str(i)];
    pList{(i-1)*5+1}.datatype    = 'text';
    
    pList{(i-1)*5+2}.description = ['Input Channel ' num2str(i)];
    pList{(i-1)*5+2}.helptext    = 'Input for Filter';
    pList{(i-1)*5+2}.datatype    = 'int_popup';
    pList{(i-1)*5+2}.default     = 0;
    pList{(i-1)*5+2}.list        = in_vec;
    
    pList{(i-1)*5+3}.description = ['Output Channel ' num2str(i)];
    pList{(i-1)*5+3}.helptext    = 'Output from Filter' ;
    pList{(i-1)*5+3}.datatype    = 'int_popup';
    pList{(i-1)*5+3}.default     = 0;
    pList{(i-1)*5+3}.list        = out_vec;
    
    pList{(i-1)*5+4}.description = ['Filter ' num2str(i)];
    pList{(i-1)*5+4}.helptext    = 'Which Filter to use' ;
    pList{(i-1)*5+4}.datatype    = 'int_popup';
    pList{(i-1)*5+4}.default     = 1;
    pList{(i-1)*5+4}.list        = filt_vec;
    
    pList{(i-1)*5+5}.datatype    = 'line';
end

pList = ita_parametric_GUI(pList,'Filter Routing GUI');

if ~isempty(pList)
    str = cellstr(num2str(cell2mat(pList).'));
    str = reshape(str,numel(str)/nFilt,nFilt);
    fromStr  = str(1,:);
    toStr    = str(2,:);
    coeffStr = str(3,:);
else
    error([thisFuncStr 'operation cancelled by user']);
end

end