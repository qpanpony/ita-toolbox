function this = ita_hearingaids_set_channelCoordinates(this)
% Set channelCoordinates according to channelNames for Hoertnix

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


for idx = 1:numel(this.channelNames)
    thisname = lower(this.channelNames{idx});
    if strfind(thisname,'bte') % its an BTE
        %d1 = 0.009; % Mic Abstand
        d2 = 0.1468; % Kopf Breite bzw Hörgeräteabstand
        h1 = 0.0595; %Höhe über Ohr, vorne
        h2 = 0.0552; %Höhe über Ohr, hinten
        setback1 = 0.0112; %Setback des vorderen Microphones hinter dem Ohr
        setback2 = 0.0228; %Setback des hinteren Microphones hinter dem Ohr
        
        
        if strfind(thisname,'left') % its left
            if strfind(thisname,'front') % its front
                this.channelCoordinates.cart(idx,:) = [-setback1 -d2/2 h1]; % BTE left front
            else
                this.channelCoordinates.cart(idx,:) = [-setback2 -d2/2 h2]; % BTE left back
            end
        else
            if strfind(thisname,'front') % its front
                this.channelCoordinates.cart(idx,:) = [-setback1 +d2/2 h1]; % BTE right front
            else
                this.channelCoordinates.cart(idx,:) = [-setback2 +d2/2 h2]; % BTE right back
            end
        end
    else % its an ITC
        d1 = 0.0067;
        d2 = 0.1654;
        
        if strfind(thisname,'left') % its left
            if strfind(thisname,'front') % its front
                this.channelCoordinates.cart(idx,:) = [0 -d2/2 0]; % ITC left front
            else
                this.channelCoordinates.cart(idx,:) = [-d1 -d2/2 0]; % ITC left back
            end
        else
            if strfind(thisname,'front') % its front
                this.channelCoordinates.cart(idx,:) = [0 d2/2 0]; % ITC right front
            else
                this.channelCoordinates.cart(idx,:) = [-d1 d2/2 0]; % ITC right back
            end
        end
        
        
        
    end
    
    
end
end