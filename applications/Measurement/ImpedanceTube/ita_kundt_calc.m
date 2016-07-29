function varargout = ita_kundt_calc(hObject,eventdata)
%ITA_KUNDT_CALC - used by ita_kundt_gui

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 



%% get data from workspace
rawdata = ita_getfrombase('Kundt_Raw_Data');
kundtsetup = ita_getfrombase('Kundt_Kundt_Setup');

%% Get probe name
fighandle = get(hObject,'Parent');
allHandles = get(fighandle,'UserData');
probename = get(allHandles{1}.ProbeName,'String');
projectpath = get(allHandles{1}.DataPath,'String');

%% Calc
if ~isempty(rawdata)  && ~isempty(kundtsetup)

    if kundtsetup.timewindow
        rawdata = ita_time_shift(rawdata);
        filtered_data = ita_time_window(rawdata,kundtsetup.timeframe,'time','symmetric');
        ita_setinbase('Kundt_Filtered_Data',filtered_data);
    else
        filtered_data = rawdata;
    end
   
    if ~isempty(kundtsetup.dist)
        geometry = kundtsetup.dist;
    else
        geometry = kundtsetup.tube;
        if isempty(geometry)
            errordlg('No Tube specified!')
            return
        end
    end

    result = ita_kundt_calc_impedance(filtered_data, geometry);
    result.comment = probename;
    result.channelNames = {probename};
    ita_setinbase('Kundt_Result',result);
    if kundtsetup.keepresult
       ita_setinbase(ita_guisupport_removewhitespaces(probename),result) 
    end
    ita_plot_freq(ita_convert_RT_alpha_R_Z(result,'inQty','Z','outQty','alpha'),'nodb','xlim',[20 12000],'ylim',[-0.1 1.1]);
    disp('Done')
    ita_kundt_save(hObject, eventdata);
end
end