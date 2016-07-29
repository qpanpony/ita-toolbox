%function show_nah(varargin)

% <ITA-Toolbox>
% This file is part of the application NAH for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%sArgs = struct('pos1_input', 'itaAudio', 'save', false);
%[input sArgs] = ita_parse_arguments(sArgs, varargin);

scrsz = get(0,'ScreenSize');
figure('Position',[1 1 scrsz(3) scrsz(4)]);
X = repmat(unique(input.channelCoordinates.x), 1, size(k,2));
Y = repmat(unique(input.channelCoordinates.y),1,size(k,2))';
% Abbildung des gemessenen Drucks, und des örtlichen Filters
% erste Reihe (Messebene)
a=subplot (3,3,1);    
mesh(unique(input.channelCoordinates.x),unique(input.channelCoordinates.y),abs(p_i)); 
%contourf(X,Y,abs(p_i),'EdgeColor','none','LevelStep',1)
title(['Druck bei F= ' num2str(f(i))]); 
axis tight;  set(gca,'ZScale','log')
zlim = get(gca, 'ZLim');
zlim_min=min(zlim);
zlim_max=max(zlim);

b=subplot (3,3,2);    
mesh(unique(input.channelCoordinates.x),unique(input.channelCoordinates.y),F_a);      
title('örtlicher Filter'); 
axis tight; set(gca,'ZScale','log')

c=subplot (3,3,3);    
mesh(unique(input.channelCoordinates.x),unique(input.channelCoordinates.y),abs(p_if)); 
title('gefilterter Druck'); 
axis tight; set(gca,'ZScale','log')
zlim = get(gca, 'ZLim');
if zlim_min >min(zlim)
    zlim_min=min(zlim);
end
if zlim_max <max(zlim)
    zlim_max=max(zlim);
end
set(a,'ZLim',[zlim_min zlim_max]);
set(b,'ZLim',[zlim_min zlim_max]);
set(c,'ZLim',[zlim_min zlim_max]);

% zweite Reihe (k-Space)
subplot 334;    
mesh(unique(kx), unique(ky),abs(W));   
title(['k-Space, wobei k=' num2str(k(1))]); 
axis tight; set(gca,'ZScale','log')

subplot 335;    
mesh(unique(kx), unique(ky),F_k);      
title(['k-Space Filter mit kcut= ' num2str(k_cutoff(i))]); 
axis tight; set(gca,'ZScale','log')

subplot 336;    
mesh(unique(kx), unique(ky),abs(Wk));  
title('gefilterter k-Space'); 
axis tight; set(gca,'ZScale','log')

% Ergebniss + g propagator (Ausbreitungsfunktion)
% dritte Reihe (Berechnete Oberfläche)
subplot 337;    
mesh(unique(kx), unique(ky),abs(G));   
title('G: Ausbreitungsfunktion'); 
axis tight; set(gca,'ZScale','log')

subplot 338;    
mesh(unique(kx), unique(ky),abs(W_zh)); 
title('k-Space auf der Oberfläche'); 
axis tight; set(gca,'ZScale','log')

subplot 339;    
mesh(unique(input.channelCoordinates.x),unique(input.channelCoordinates.y),abs(squeeze(w(i,:,:)))); 
title('Oberflächenschnelle'); 
axis tight; set(gca,'ZScale','log')

if 0
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [29.7 21.0]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 29.7 21.0]); 
    
    set(gcf, 'renderer', 'painters');
    
    print(gcf, '-dpdf', [num2str(f(i)) '.pdf']);
   % print(gcf, '-depsc2', [num2str(f(i)) '.eps']);
    close gcf;
end

