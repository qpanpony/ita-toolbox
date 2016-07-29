function ita_plottools_buttonpress_spherical(src,evnt)
%ITA_PLOTTOOLS_BUTTONPRESS_SPHERICAL - Provide key press functions to spherical plots
%
%   This function is normally not used by the user!
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_buttonpress_spherical">doc ita_plottools_buttonpress_spherical</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  16-Sep-2008

%% get additional info in the user section of the figure
userdata = get(gcf,'userdata');
userdata.hfig = gcf;
userdata.axh = gca;

SCALINGCONSTANT = 1.5; % for + and -

%% Get ITA Toolbox preferences
% mpo: batch commenting of: "Mode % global variable is loaded very fast" 
verboseMode = ita_preferences('verboseMode'); % mpo, batch replacement, 15-04-2009

%% Decide what to do
if verboseMode, disp(['ITA:VERBOSE_MODE - Key: ' evnt.Key ' - Character: ' evnt.Character ]), end;
switch (evnt.Key)

    case {'s'} %save figure as file
        ita_savethisplot();
        
    case {'b'} %switch to between black and white background
        ita_whitebg();
        menu = get(userdata.hfig,'menubar');
        if strcmp(menu,'none')
            set(userdata.hfig,'menubar', 'figure')
        else    
            old_position = get(userdata.hfig, 'Position');
            set(userdata.hfig,'menubar', 'none')            
        end
        
    case {'g'}
        grid;
        
    case {'i'}
        shading interp;
    case {'f'}
        shading faceted;
               
    case {'multiply'}
        newFreqIndex = userdata.sphericalData.freqIndex + 1;
        if newFreqIndex > length(userdata.sphericalData.usedFreqs), return; end
        hSurfaceplot = findobj('Type','surface');
        set(hSurfaceplot, 'XData', userdata.sphericalData.X(:,:,newFreqIndex));
        set(hSurfaceplot, 'YData', userdata.sphericalData.Y(:,:,newFreqIndex));
        set(hSurfaceplot, 'ZData', userdata.sphericalData.Z(:,:,newFreqIndex));
        set(hSurfaceplot, 'CData', userdata.sphericalData.color(:,:,newFreqIndex));

%        title(['f = ' num2str(userdata.sphericalData.usedFreqs(newFreqIndex))]);        
        title([userdata.sphericalData.comment ', f = ' num2str(userdata.sphericalData.usedFreqs(newFreqIndex))]);        
        
        drawnow;
        userdata.sphericalData.freqIndex = newFreqIndex;
    case {'divide'}
        newFreqIndex = userdata.sphericalData.freqIndex - 1;
        if newFreqIndex < 1, return; end
        hSurfaceplot = findobj('Type','surface');
        set(hSurfaceplot, 'XData', userdata.sphericalData.X(:,:,newFreqIndex));
        set(hSurfaceplot, 'YData', userdata.sphericalData.Y(:,:,newFreqIndex));
        set(hSurfaceplot, 'ZData', userdata.sphericalData.Z(:,:,newFreqIndex));
        set(hSurfaceplot, 'CData', userdata.sphericalData.color(:,:,newFreqIndex));

%        title(['f = ' num2str(userdata.sphericalData.usedFreqs(newFreqIndex))]);        
        title([userdata.sphericalData.comment ', f = ' num2str(userdata.sphericalData.usedFreqs(newFreqIndex))]);        


        drawnow;
        userdata.sphericalData.freqIndex = newFreqIndex;
    case {'leftarrow'} %Left arrow: move cursor left
        [az,el] = view;
        az = mod(az + userdata.sphericalData.stepSizeAzimuth, 360);
        view(az,el);
    case {'rightarrow'} %Left arrow: move cursor left
        [az,el] = view;
        az = mod(az - userdata.sphericalData.stepSizeAzimuth, 360);
        view(az,el);
    case {'uparrow'}
        [az,el] = view;
        el = el - userdata.sphericalData.stepSizeElevation;
        if el <= -90, el = -89.99; end; % >-90 to avoid ugly jump of axes
        view(az,el);
    case {'downarrow'}
        [az,el] = view;
        el = el + userdata.sphericalData.stepSizeElevation;
        if el > 90, el = 89.99; end; % <90 to avoid ugly background color change
        view(az,el);
        
    case {'subtract'}
        if ~strcmp(userdata.sphericalData.type, 'sphere')
            set(gca, 'Xlim', get(gca, 'Xlim') .* SCALINGCONSTANT)
            set(gca, 'Ylim', get(gca, 'Ylim') .* SCALINGCONSTANT)
            set(gca, 'Zlim', get(gca, 'Zlim') .* SCALINGCONSTANT)
        end
    case {'add'}
        if ~strcmp(userdata.sphericalData.type, 'sphere')
            set(gca, 'Xlim', get(gca, 'Xlim') ./ SCALINGCONSTANT)
            set(gca, 'Ylim', get(gca, 'Ylim') ./ SCALINGCONSTANT)
            set(gca, 'Zlim', get(gca, 'Zlim') ./ SCALINGCONSTANT)
        end
               
%     case {'z'} % TODO % save current cursor position, otherwise cursor position is lost
%         zoom;
%         hManager = uigetmodemanager(userdata.hfig); 
%         set(hManager.WindowListenerHandles,'Enable','off'); 
%         set(userdata.hfig,'KeyPressFcn',@ita_plottools_buttonpress)
%         ita_plottools_cursors('update',[],userdata.axh);    %TODO: correct update behaviour
        
    case {'q'}
        close;
    otherwise
        %         disp('Oh Lord. Relax, we are still working on the Function
        %         Keys!')
end

%% write back actual userdata
set(gcf,'userdata',userdata)

end