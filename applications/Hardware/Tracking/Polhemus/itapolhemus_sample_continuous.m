%
%  ITAPolhemus Matlab Executable
%  Unterstützung für Tracking-Umgebungen in Matlab
%  Autor:   Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%  Version: $Date: 2012-04-19 12:30:34 +0200 (Do, 19 Apr 2012) $
%

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%  Datei:   itapolhemus_sample_continuous.m
%  Zweck:   Ein kleines Matlab-Skript welches die Funktionen demonstriert
%

fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');

ITAPolhemus('init');
c = ITAPolhemus('config');

for i=1:100
    S = ITAPolhemus('getsensorstates');
    
    for n=1:c.NumSensors
        s = S{n};
        if (s.attached)
            fprintf('Sensor %i: P=(%+0.3f, %+0.3f, %+0.3f), V=(%+0.3f, %+0.3f, %+0.3f), U=(%+0.3f, %+0.3f, %+0.3f)\n',...
                     n, ...
                     s.pos(1), s.pos(2), s.pos(3),...
                     s.view(1), s.view(2), s.view(3),...
                     s.up(1), s.up(2), s.up(3));
        end
    end            
    pause(0.1);
end

ITAPolhemus('finalize');

