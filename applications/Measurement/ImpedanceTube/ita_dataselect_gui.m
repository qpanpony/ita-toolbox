function varargout = ita_dataselect_gui(varargin)
%ITA_DATASELECT_GUI - GUI to select data from your current directory,
%special for kundt measurements, used by ita_kundt_postprocessing_gui
%  
% Author: Ruth Herbertz-- Email: herbertz@akustik.rwth-aachen.de
% Created:  04-Oct-2010

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Import filenumber
filefilter = '*_raw.ita';
allrawfiles = dir(filefilter);
fileno = numel(allrawfiles);



%% Draw - 8 files in a row
if ~mod(fileno,8)
    height = out/8;
else
    height = (fileno - mod(fileno,8))/8 + 1;
end


%figure
figheight    = (3 + height + 1) * 40;
file_width  = 70;
width     = (8+3)*(file_width - 15);
persistent hFig
if ~isempty(hFig) && ishandle(hFig) && strcmpi(get(hFig,'Name'),'Select Files from your current directory')
   close(hFig) 
end
hFig = figure('Name','Select Probes from your Current Directory to plot',...
    'Position',[300 200 width figheight],...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'HandleVisibility','on',...
    'NumberTitle','off', ...
    'Color', [0.8 0.8 0.8]);

%ITA toolbox logo with grey background
a_im = importdata(which('ita_toolbox_logo.png'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [20 20 200 35]); %TODO: later set correctly the position



%% Headline Text
if fileno
    uicontrol(...
        'Parent', hFig,...
        'Position',[20 (1+height+2)*40-20 200 20],...
        'HorizontalAlignment','left',...
        'String','Probes',...
        'FontSize',13,...
        'FontWeight','bold',...
        'Style', 'text',...
        'ForegroundColor', [0 0 0],...
        'BackgroundColor', [0.8 0.8 0.8]);
end
%% Input filenames and checkboxes

for jdx = 1:numel(allrawfiles)
    uicontrol(...
        'Parent', hFig,...
        'Position',[5+(mod(jdx-1,8))*file_width (3-(jdx-mod(jdx-1,8)+1)/8)*80+2 60 15],...
        'HorizontalAlignment','right',...
        'String', [ num2str(allrawfiles(jdx).name(1:end-8))],...
        'Style', 'text',...
        'ForegroundColor', [1 .1 .1],...
        'BackgroundColor', [0.8 0.8 0.8]);
end



for jdx = 1:numel(allrawfiles)
    
   h(jdx).file=uicontrol(...
        'Parent', hFig,...
        'Position',[50+(mod(jdx-1,8))*file_width (3-(jdx-mod(jdx-1,8)+1)/8)*80-5 20 10],...
        'Style', 'checkbox',...
        'ForegroundColor', [0 0 .7],...
        'BackgroundColor', [0.8 0.8 0.8]);
end
%% Buttons
% Cancel Button
uicontrol(...
    'Parent', hFig, ...
    'Position',[330 20 80 30],...
    'String', 'Cancel',...
    'Style', 'pushbutton',...
    'Callback', @CancelButtonCallback,...
    'BackgroundColor', [0.7 0.7 0.7]);

% Ok Button
uicontrol(...
    'Parent', hFig, ...
    'Position',[430 20 80 30],...
    'String', 'OK',...
    'Style', 'pushbutton',...
    'Callback', @OkayButtonCallback,...
    'BackgroundColor', [0.7 0.7 0.7]);

uiwait(hFig);


%% Callbacks
    function CancelButtonCallback(hObject,eventdata) %#ok<INUSD>
        uiresume(gcf);
        close(hFig)
        
    end

    function OkayButtonCallback(hObject,eventdata) %#ok<INUSD>
        files = [];
        for jdx2 = 1:fileno
            if get(h(jdx2).file,'Value') == 1
                files = [files allrawfiles(jdx2)]; %#ok<*AGROW>
                
            end
        end
        ita_setinbase('filestoplot', files);
        
        uiresume(gcf);
        close(hFig)
        
        %choose output arguments
        outstring = [];
        for jdx3=1:numel(files)-1
            outstring = [outstring files(jdx3).name(1:end-8) ', '];
        end
        outstring = [outstring files(numel(files)).name(1:end-8)];
        varargout{1} = outstring;
        
        

       
        
        return;
        
    end
end
