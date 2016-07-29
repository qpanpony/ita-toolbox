function ita_generate_protocol_for_revChamber_absMeas(daten,result,bild)

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


[tex_path bild_tex] = generate_folder_structure(bild);

fid = fopen([tex_path filesep 'chap' filesep 'protocol.tex'],'w');

% get room data from channelUserData
roomData = result(1).userData;


% protocol header
fprintf(fid,'\\begin{center}\n\t \\Huge{\\textbf{Messprotokoll}}\\\\\n');
fprintf(fid,'\t\\Large{vom %s}\\\\\n\t',daten.date);
fprintf(fid,'\\textbf{Prüfobjekt: }%s\\end{center}\\vspace{0.3cm}\n', daten.object');
%fprintf(fid,'\\indent %s\n\\vspace{0.5cm}\n\n');

% Data tabular
fprintf(fid,'\\section{Objekt- und Raumdaten}\n\t');
fprintf(fid,'\\begin{table}[h!]\n\t\\centering\n\t\\begin{tabular}{|l|l|}\n\t\t\\hline\n');
fprintf(fid,'\t\t\\textbf{Objektpositionen}                           & %i                    \\\\\n\t\t\n', daten.nObj);
fprintf(fid,'\t\t\\textbf{Lautsprecherpositionen}                     & %i                    \\\\\n\t\t\n', daten.nLS);
fprintf(fid,'\t\t\\textbf{Mikrofonpositionen}                         & %i                    \\\\\n\t\t\\hline\n', daten.nMic);
fprintf(fid,'\t\t\\textbf{Hallraumvolumen}                             & $%4.1f ~ \\text{m}^3          $\\\\\n\t\t\n',roomData.roomVolume);
fprintf(fid,'\t\t\\textbf{Hallraumfläche}                              & $%4.1f ~ \\text{m}^2          $\\\\\n\t\t\\hline\n',roomData.roomSurface);
fprintf(fid,'\t\t\\textbf{Prüfobjekt}                               & %s \\\\\n\t\t\n',daten.object);
fprintf(fid,'\t\t\\textbf{Objektvolumen}                               &  $%3.2f ~ \\text{m}^2         $\\\\\n\t\t\n',roomData.objectVolume);
fprintf(fid,'\t\t\\textbf{Objektfläche}                                &  $%3.2f ~ \\text{m}^2         $\\\\\n\t\t\\hline\n',roomData.objectSurface);
fprintf(fid,'\t\t\\textbf{Temperatur ohne Objekt}              & $(%3.1f \\pm %3.1f)$\\textdegree C\\\\\n\t\t\n', 100* roomData.meanTempAtRefMeas,100*roomData.stdTempAtRefMeas);
fprintf(fid,'\t\t\\textbf{Relative Luftfeuchte ohne Objekt}        & $(%3.1f \\pm %3.1f)~ \\%%                 $\\\\\n\t\t\n', 100*roomData.meanHumidityAtRefMeas,100*roomData.stdHumidityAtRefMeas);
fprintf(fid,'\t\t\\textbf{Adiabatischer Ruhedruck ohne Objekt} & $(%5.1f \\pm %5.1f)~ \\text{mBar} ~ \\%%  $\\\\\n\t\t\\hline\n',100*roomData.meanAdiabaticPressureAtRefMeas,100*roomData.stdAdaibaticPressureAtRefMeas);
fprintf(fid,'\t\t\\textbf{Temperatur mit Objekt}              & $(%3.1f\\pm %3.1f)$ \\textdegree C   \\\\\n\t\t\n', 100*roomData.meanTempAtObjMeas,100*roomData.stdTempAtObjMeas);
fprintf(fid,'\t\t\\textbf{Relative Luftfeuchte mit Objekt}        & $(%3.1f \\pm %3.1f) ~ \\%%          $\\\\\n\t\t\n', 100*roomData.meanHumidityAtObjMeas,100*roomData.stdHumidityAtObjMeas);
fprintf(fid,'\t\t\\textbf{Adiabatischer Ruhedruck mit Objekt} & $(%5.1f \\pm %5.1f) ~ \\text{mBar}  $\\\\\n\t\t\\hline\n', 100*roomData.meanAdiabaticPressureAtObjMeas,100*roomData.stdAdiabaticPressureAtObjMeas);
fprintf(fid,'\t\\end{tabular}\n\\end{table}\n\n');

% comment
if ~isempty(daten.comment)
    fprintf(fid,'\\section{Kommentar}\n');
    for i = 1:length(daten.comment)
        fprintf(fid,'%s\n',daten.comment{i});
    end
end

fprintf(fid,'\\newpage');
% absorption tabular
fprintf(fid,'\\section{Messdaten}\n\t');
fprintf(fid,'\\begin{table}[H]\n\t\\centering\n\t\\begin{tabular}{|c|c|c|c|c|}\n\t\t\\hline');
fprintf(fid,'\t\t\\textbf{Frequenz} & $\\mathbf{\\alpha}$ & \\textbf{A} &\\textbf{Nachhallzeit leer}  &\\textbf{Nachhallzeit mit Objekt} \\\\\n');
fprintf(fid,'\t\t\\textbf{[Hz]} & & \\textbf{[$\\text{m}^2$]} & \\textbf{[s]} & \\textbf{[s]}\\\\\n\t\t\\hline\n');
fprintf(fid,'\t\t%5.1f & $%1.2f \\pm %2.2f$ & $%2.2f \\pm %2.2f$ & $%2.2f\\pm %2.2f$  & $%2.2f\\pm %2.2f$\\\\\n\t\t\\hline\n',[result(1).freqVector,result(1).freq,result(2).freq,result(3).freq,result(4).freq,result(5).freq,result(6).freq,result(7).freq,result(8).freq]');
fprintf(fid,'\t\\end{tabular}\n\\end{table}\n\n');

%Plot Absorption
h = ita_plot_spk(merge(result(1),result(1)+result(2),result(1)-result(2)), 'nodB', 'ylim', [-0.1, 1.1]);

fig_children_handles = get(h,'Children');
types_fig_children = get(fig_children_handles(:),'Type');
idx1 = find(strcmpi(types_fig_children, 'axes'));
axes_children_handles = get(fig_children_handles(idx1), 'Children');
types_axes_children = get(axes_children_handles(:),'Type');
lineIndices = find(strcmpi(types_axes_children, 'line'));
  
set(axes_children_handles(lineIndices(1)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(2)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(3)),'Color',[0 0 0],'LineStyle', '-','LineWidth', 2);

title({'Absorptionsgrad'},'FontSize',28);
xlabel(gca,'Frequenz in Hz', 'Fontsize', 16);
ylabel(gca,'Absorptionskoeffizient', 'Fontsize', 16);

print('-dpng', fullfile(tex_path,'Absorptionsgrad.png')); 
close;

%Plot Aequivalente Absorptionsfläche
h=ita_plot_spk(merge(result(3),result(3)+result(4),result(3)-result(4)), 'nodB', 'ylim', [0, max(result(3).freqData)*1.1]);

fig_children_handles = get(h,'Children');
types_fig_children = get(fig_children_handles(:),'Type');
idx1 = find(strcmpi(types_fig_children, 'axes'));
axes_children_handles = get(fig_children_handles(idx1), 'Children');
types_axes_children = get(axes_children_handles(:),'Type');
lineIndices = find(strcmpi(types_axes_children, 'line'));
  
set(axes_children_handles(lineIndices(1)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(2)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(3)),'Color',[0 0 0],'LineStyle', '-','LineWidth', 2);

title({'Äquivalente Absorptionsfläche'},'FontSize',28);
xlabel(gca,'Frequenz in Hz','Fontsize', 16);
ylabel(gca,'Äquivalente Absorptionsfläche in m²','Fontsize', 16);

print('-dpng', fullfile(tex_path,'AequivalenteAbsorptionsflaeche.png')); 
close;

%Plot Nachhallzeit
maxy=max(result(5).freqData);
if max(result(5).freqData)< max(result(7).freqData)
    maxy=max(result(7).freqData);
end
h=ita_plot_spk(merge(result(5),result(5)+result(6),result(5)-result(6),result(7),result(7)+result(8),result(7)-result(8)), 'nodB','ylim', [0,maxy*1.1]);

fig_children_handles = get(h,'Children');
types_fig_children = get(fig_children_handles(:),'Type');
idx1 = find(strcmpi(types_fig_children, 'axes'));
axes_children_handles = get(fig_children_handles(idx1), 'Children');
types_axes_children = get(axes_children_handles(:),'Type');
lineIndices = find(strcmpi(types_axes_children, 'line'));
  
set(axes_children_handles(lineIndices(1)),'Color',[1 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(2)),'Color',[1 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(3)),'Color',[1 0 0],'LineStyle', '-','LineWidth', 2);
set(axes_children_handles(lineIndices(4)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(5)),'Color',[0.5 0.5 0.5],'LineStyle', '--','LineWidth', 1);
set(axes_children_handles(lineIndices(6)),'Color',[0 0 0],'LineStyle', '-','LineWidth', 2);

title({'Nachhallzeit'},'FontSize',28);
xlabel(gca,'Frequenz in Hz', 'Fontsize', 16);
ylabel(gca,'Nachhallzeit in s','Fontsize', 16);

print('-dpng', fullfile(tex_path,'Nachhallzeit.png')); 
close;

%graphics
fprintf(fid,'\\section{Graphische Darstellung der Messdaten}\n\t');

fprintf(fid,'\\begin{figure}[H]\n\t\\centering\n');
fprintf(fid,'\t\\includegraphics[width=0.75\\textwidth]{Absorptionsgrad.png}\n\\caption{Absorptionsgrad mit Standardabweichung}\n\\end{figure}\n\n');

fprintf(fid,'\\begin{figure}[H]\n\t\\centering\n');
fprintf(fid,'\t\\includegraphics[width=0.75\\textwidth]{AequivalenteAbsorptionsflaeche.png}\n\\caption{Äquivalente Absorptionsfläche mit Standardabweichung}\n\\end{figure}\n\n');

fprintf(fid,'\\begin{figure}[H]\n\t\\centering\n');
fprintf(fid,'\t\\includegraphics[width=0.75\\textwidth]{Nachhallzeit.png}\n\\caption{Nachhallzeit leer (schwarz), Nachhallzeit mit Absorber (rot)}\n\\end{figure}\n\n');

fprintf(fid,'\\newpage');

% graphics
if ~isempty(bild_tex)
    fprintf(fid,'\\section{Weitere Bilder und Graphiken zur Messung}\n\t');
    for i = 1:length(bild_tex)
        if isempty(bild_tex{i}.caption)
            fprintf(fid,'\\begin{figure}[H]\n\t\\centering\n');
            fprintf(fid,'\t\\includegraphics[width=0.75\\textwidth]{./figs/%s}\n\\end{figure}\n\n',bild_tex{i}.datenpfad);
        else
            fprintf(fid,'\\begin{figure}[H]\n\t\\centering\n');
            fprintf(fid,'\t\\includegraphics[width=0.75\\textwidth]{./figs/%s}\n\\caption{%s}\n\\end{figure}\n\n',bild_tex{i}.datenpfad,bild_tex{i}.caption);
        end
    end
end



fclose(fid);


%% generate folder structure
function [tex_path bild_tex] = generate_folder_structure(bild)

tex_path = uigetdir('','Ordner für TeX-Protokoll auswählen.');

mkdir(tex_path, 'logos')
mkdir(tex_path, 'figs')
mkdir(tex_path, 'chap')

copyfile([ita_toolbox_path filesep 'applications' filesep 'RoomAcoustics' filesep 'latexroomacoustics' filesep 'absorption_protocol.tex'], tex_path)
copyfile([ita_toolbox_path filesep 'applications' filesep 'RoomAcoustics' filesep 'latexroomacoustics' filesep 'logos' filesep 'ita-logo.pdf'], [tex_path filesep 'logos'])
copyfile([ita_toolbox_path filesep 'applications' filesep 'RoomAcoustics' filesep 'latexroomacoustics' filesep 'logos' filesep 'rwth-logo.pdf'], [tex_path filesep 'logos'])

if ~isempty(bild)
    for i = 1:length(bild)
        copyfile(bild{i}.datenpfad, [tex_path filesep 'figs'])
        bild_tex{i}.caption = bild{i}.caption;
        [pathstr, name, ext, versn] = fileparts(bild{i}.datenpfad);
        bild_tex{i}.datenpfad = [name ext];
    end
else bild_tex = '';

end