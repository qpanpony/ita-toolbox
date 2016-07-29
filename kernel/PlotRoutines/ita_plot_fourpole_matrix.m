function varargout = ita_plot_fourpole_matrix(fp)
%ITA_PLOT_FOURPOLE_MATRIX - Plot Fourpole Matrix Spectra in one plot
%  This function plot four spectra in a 4-by-4 figure
%
%  Syntax: ita_plot_fourpole_matrix([a11 a12 a21 a22])
%  Syntax: ita_plot_fourpole_matrix(fourpoleStruct)
%
%   fourpoleStruct has 4 channels containing a11,a12,a21,a22.
%
%   See also ita_fft, ita_ifft, ita_read, ita_write, ita_make_ita_header, ita_write, ita_BK_pulse_read, ita_split, ita_merge, ita_audioplay, ita_convolve, ita_process_impulseresponse, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_divide_spk, ita_multiply_spk, ita_JFilter, fridge_auralization_load, fridge_auralization_run, fridge_setup_tp_imp, fridge_setup_grommet, fridge_setup_sourcesignals, ita_fourpole_A2Z, ita_subtract_spk, ita_negate_spk, ita_invert_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_fourpole_matrix">doc ita_plot_fourpole_matrix</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  24-Jun-2008


%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
narginchk(1,1);
if isa(fp,'itaFourpole')
    data = fp.data;
    spk12 = data(1,2);
    spk21 = data(2,1);
    spk22 = data(2,2);
    spk11 = data(1,1);
else
    error('ITA_PLOT_FOURPOLE:Oh Lord. Please see syntax for fourpole input data.');
end

%% get dB values
ampl_dB{1}     = spk11.freqData_dB;   %amplitude in dB
ampl_dB{2}     = spk12.freqData_dB;   %amplitude in dB
ampl_dB{3}     = spk21.freqData_dB;   %amplitude in dB
ampl_dB{4}     = spk22.freqData_dB;   %amplitude in dB

%% strings
typeStr{1} = [fp.type '11'];
typeStr{2} = [fp.type '12'];
typeStr{3} = [fp.type '21'];
typeStr{4} = [fp.type '22'];

%% axis limits
abs_min = -100;
abs_max =  100;

%% Axy - Plotting of Amplitude
fgh = ita_plottools_figure();

%pre alloc
axh = cell(4,1); lnh = cell(4,1); titleStr = cell(4,1);

freqVec = spk11.freqVector;

for idx = 1:4
    axh{idx}    = subplot(2,2,idx);
    lnh{idx}    = semilogx(freqVec,ampl_dB{idx}); %Plot it all
    
    % Set Axis and that stuff...
    titleStr{idx} = [typeStr{idx} ' - ' spk12.comment ];
    title(titleStr{idx})
    xlabel('Frequency in Hz')
    ylabel('Amplitude in dB')
    set(fgh,'NumberTitle','off','Name', titleStr{idx})
    
    %XTicking -- Thanks to SFI!
    XTickLabel_val  = {20 '' 40 '' 60 '' '' '' 100 200 ''  400 ''  600 ''  ''  ''  '1k' '2k' ''   '4k' ''   '6k' ''   ''   ''   '10k' '20k'};
    XTickVec        = [20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 20000];
    set(gca,'XTick',XTickVec','XTickLabel',XTickLabel_val)
    xlim([min(XTickVec) max(freqVec)])
    
    %get nice axis
    ylim([abs_min abs_max]);
    
    %% Black background?
    ita_whitebg(repmat(~ita_preferences('blackbackground'),1,3))
    
    %get a grid
    grid on
    
    %% Save information in the axes userdata section
    limits = [xlim ylim];
    setappdata(axh{idx},'Limits',limits);
    setappdata(axh{idx},'samplingRate',spk11.samplingRate);
    setappdata(axh{idx},'YAxisType','db');  %Types: linear and db
    setappdata(axh{idx},'XAxisType','freq');  %Types: time and freq
    setappdata(axh{idx},'ChannelHandles',lnh{idx});
    
end

%% Save information in the figure userdata section
setappdata(fgh,'AllChannels',1);   %used for all channel /single channel switch
setappdata(fgh,'ActiveChannel',1); %used for all channel /single channel switch
setappdata(fgh,'Title',titleStr);
setappdata(fgh,'ChannelNames',spk11.channelNames);
setappdata(fgh,'Filename',spk11.fileName);
setappdata(fgh,'AxisHandles',cell2mat(axh));
setappdata(fgh,'ActiveAxis',axh{1});

if ispc
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    set(get(fgh,'JavaFrame'),'Maximized',1);
end

%% Output parameters
if nargout ~= 0
    varargout = {fgh};
end
