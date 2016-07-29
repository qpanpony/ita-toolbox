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

%  Datei:   itapolhemus_sample_on_button.m
%  Zweck:   Ein kleines Matlab-Skript welches die Funktionen demonstriert
%

fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');

ITAPolhemus('init');
c = ITAPolhemus('config');

for i=1:100
    S = ITAPolhemus('getsensorstates');
    for n=1:c.NumSensors
        s = S{n};
        % Only show first sensor that has a button
        if (s.hasButton)
            if (s.buttonPressed)
                fprintf('Sensor %i button pressed.\n', n);
            else
                fprintf('Sensor %i button not pressed.\n', n);
            end
        end
    end
    pause(0.1)
end

ITAPolhemus('finalize');

