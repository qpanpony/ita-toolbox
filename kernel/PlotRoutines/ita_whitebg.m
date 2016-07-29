function ita_whitebg(fig,c)
%ITA_WHITEBG - Change axes background color a little different than MATLAB does

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


rgbspec = [1 0 0;0 1 0;0 0 1;1 1 1;0 1 1;1 0 1;1 1 0;0 0 0];
cspec = 'rgbwcmyk';
def = ['wk' % Default text colors
    'wk' % Default axesxcolors and xlabel colors
    'wk' % Default axesycolors and ylabel colors
    'wk' % Default axeszcolors and zlabel colors
    'wk' % Default patch face color
    'kk' % Default patch and surface edge color
    'wk' % Default line colors
    ];

if nargin==0,
    fig = [gcf]; %pdi: was zero before in the end
    if ischar(get(fig(1),'defaultaxescolor')),
        c = 1 - get(fig(1),'color');
    else
        c = 1 - get(fig(1),'defaultaxescolor');
    end
    
elseif nargin==1,
    if isequal(size(fig),[1 3]) && max(fig(:))<=1,
        c = fig; fig = [gcf]; %pdi: was zero before in the end
    elseif ischar(fig),
        c = fig; fig = [gcf]; %pdi: was zero before in the end
    else
        c = zeros(length(fig),3);
        for i=1:length(fig),
            if ischar(get(fig(i),'defaultaxescolor')),
                if fig(i)==0,
                    c(i,:) = 1 - get(fig(i),'defaultfigurecolor');
                else
                    c(i,:) = 1 - get(fig(i),'color');
                end
            else
                c(i,:) = 1 - get(fig(i),'defaultaxescolor');
            end
        end
    end
end

if length(fig)~=size(c,1) && ~ischar(c)
    c = c(ones(length(fig),1),:);
end

% Deal with string color specifications.
if ischar(c),
    k = find(cspec==c(1));
    if isempty(k)
        error('MATLAB:whitebg:InvalidColorString','Unknown color string.');
    end
    if k~=3 || length(c)==1,
        c = rgbspec(k,:);
    elseif length(c)>2,
        if strcmpi(c(1:3),'bla')
            c = [0 0 0];
        elseif strcmpi(c(1:3),'blu')
            c = [0 0 1];
        else
            error('MATLAB:whitebg:UnknownColorString', 'Unknown color string.');
        end
    end
    c = c(ones(length(fig),1),:);
end

n = size(c,1);

for k=1:n,  % Change all the requested figures
    lum = dot([.298936021 .58704307445 .114020904255],c(k,:));
    mode = (lum>=.5) + 1; % mode = 1 for black, mode = 2 for white.
    set(fig(k),'defaulttextcolor',def(1,mode))
    set(fig(k),'defaultaxesxcolor',def(2,mode))
    set(fig(k),'defaultaxesycolor',def(3,mode))
    set(fig(k),'defaultaxeszcolor',def(4,mode))
    set(fig(k),'defaultpatchfacecolor',def(5,mode))
    set(fig(k),'defaultpatchedgecolor',def(6,mode))
    set(fig(k),'defaultsurfaceedgecolor',def(6,mode))
    set(fig(k),'defaultlinecolor',def(7,mode))

    %   Possibly complement the figure color if axis color isn't 'none'
    if ~ischar(get(fig(k),'defaultaxescolor')),
        fc = get(fig(k),'defaultaxescolor');
        clum = (dot([.298936021 .58704307445 .114020904255],fc) >= .5) + 1;
        if fig(k)==0,
            set(fig(k),'defaultfigurecolor',brighten(0.2*(mode==1)+0.8*c(k,:),.3))
        else
            set(fig(k),'color',brighten(.2*(mode==1)+0.8*c(k,:),.3))
        end
        set(fig(k),'defaultaxescolor',c(k,:))
        if (clum==1 && mode==2) || (clum==2 && mode==1),
            %       set(fig(k),'defaultaxescolororder',1-co)
        end
    else
        disp('unten')
        if fig(k)==0,
            set(fig(k),'defaultfigurecolor',c(k,:))
        else
            fc = get(fig(k),'color');
            set(fig(k),'color',c(k,:))
        end
    end
    
    % Blindly turn InvertHardcopy on
    if fig(k)==0,
        set(fig(k),'defaultfigureinverthardcopy','on');
    else
        set(fig(k),'inverthardcopy','on');
    end
    
    if fig(k)~=0,
        % Now set the properties of the figure and axes in the current figure.
        h = get(fig(k),'children');
        for i=1:length(h),
            if strcmp(get(h(i),'Type'),'axes'),
                % Complement the figure and their contents if necessary
                if ~ischar(get(h(i),'color')),
                    ac = get(h(i),'color');
                else
                    ac = fc;
                end
                clum = (dot([.298936021 .58704307445 .114020904255],ac) >= .5) + 1;
                if (clum==1 && mode==2) || (clum==2 && mode==1),
                    complement = 1;
                else
                    complement = 0;
                end
                if complement
                    co = get(h(i),'colororder');
                    set(h(i),'colororder',1-co);
                end
                hh = [get(h(i),'Title')
                    get(h(i),'xlabel')
                    get(h(i),'ylabel')
                    get(h(i),'zlabel')
                    get(h(i),'children')];
                for j=1:length(hh),
                    tt = get(hh(j),'Type');
                    if  strcmp(tt,'text') %|| strcmp(tt,'line'),
                        if isequal(get(hh(j),'Color'),ac),
                            set(hh(j),'Color',c(k,:))
                        elseif complement,
                            set(hh(j),'Color',1-get(hh(j),'Color')) %important line
                        end
                    elseif strcmp(tt,'surface'),
                        if ~ischar(get(hh(j),'FaceColor'))
                            if isequal(get(hh(j),'FaceColor'),ac),
                                set(hh(j),'FaceColor',c(k,:))
                            elseif complement,
                                set(hh(j),'FaceColor',1-get(hh(j),'FaceColor'))
                            end
                            if ~ischar(get(hh(j),'EdgeColor'))
                                if isequal(get(hh(j),'EdgeColor'),ac),
                                    set(hh(j),'EdgeColor',c(k,:))
                                elseif complement,
                                    set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
                                end
                            end
                        elseif strcmp(get(hh(j),'FaceColor'),'none')
                            if ~ischar(get(hh(j),'EdgeColor'))
                                if isequal(get(hh(j),'EdgeColor'),ac),
                                    set(hh(j),'EdgeColor',c(k,:))
                                elseif complement,
                                    set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
                                end
                            end
                        end
                    elseif strcmp(tt,'patch')
                        if ~ischar(get(hh(j),'EdgeColor'))
                            if isequal(get(hh(j),'EdgeColor'),ac),
                                set(hh(j),'EdgeColor',c(k,:))
                            elseif complement,
                                set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
                            end
                        end
                        if ~ischar(get(hh(j),'FaceColor'))
                            if isequal(get(hh(j),'FaceColor'),ac),
                                set(hh(j),'FaceColor',c(k,:))
                            elseif complement,
                                set(hh(j),'FaceColor',1-get(hh(j),'FaceColor'))
                            end
                        end
                    end
                end
                
                % Set the color of the axes if necessary
                set(h(i),'xcolor',def(2,mode))
                set(h(i),'ycolor',def(3,mode))
                set(h(i),'zcolor',def(4,mode))
                if ~ischar(get(h(i),'color')) || ~ischar(get(fig(k),'defaultaxescolor'))
                    set(h(i),'color',c(k,:))
                end
            end
        end
    end
end
