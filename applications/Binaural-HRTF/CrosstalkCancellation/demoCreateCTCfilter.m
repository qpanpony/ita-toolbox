open ./D200/D200V000/V000H000.DAT;

% <ITA-Toolbox>
% This file is part of the application Binaural for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

open ./D200/D200V000/V000H045.DAT;
open ./D200/D200V000/V000H315.DAT;

ctc = ita_CTC_filter(V000H315,V000H045,V000H000, 'filterType', 'wiener_reg' );