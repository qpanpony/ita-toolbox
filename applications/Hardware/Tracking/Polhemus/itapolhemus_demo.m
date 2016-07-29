%
%  ITAPolhemus Matlab Executable
%  Unterstützung für Tracking-Umgebungen in Matlab
%  Autor:   Jonas Stienen (stienen@akustik.rwth-aachen.de)
%  Version: $Date: 2012-04-19 12:30:34 +0200 (Do, 19 Apr 2012) $
%
%  Datei:   itapolhemus_demo.m
%  Zweck:   Ein kleines Matlab-Skript welches die Funktionen demonstriert
%

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%addpath('./win64');

ITAPolhemus('help')
fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');
ITAPolhemus('init')
c = ITAPolhemus('config')
c.NumSensors

S = ITAPolhemus('getsensorstates')

pause on
pause(2)

if (S{1}.attached)
    s = ITAPolhemus('getsensorstate', 1); 
    s.pos    
end

ITAPolhemus('finalize')