function s = motor_setup(comPort,motorID)

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% setup serial connection
s = serial(comPort,'BaudRate',19200,'DataBits',8,'StopBits',1,'OutputBufferSize',3072);
s.TimeOut = 5;
s.Terminator = 13;
s.BytesAvailableFcnMode = 'terminator';
fopen(s);

% Setup motor
fwrite(s,sprintf('#%dJ1\r',motorID)); % send status after move
fwrite(s,sprintf('#%dU0\r',motorID)); % error correction off
fwrite(s,sprintf('#%dO1\r',motorID)); % decay time after move
fwrite(s,sprintf('#%dz0\r',motorID)); % steps after change of direction
fwrite(s,sprintf('#%di25\r',motorID)); % set current (%)
fwrite(s,sprintf('#%dr5\r',motorID)); % set holding current (%)

% sequence parameters
fwrite(s,sprintf('#%d!1\r',motorID)); % position mode
fwrite(s,sprintf('#%dp1\r',motorID)); % relative positioning

% empty serial buffer
flushinput(s);
fclose(s);

end
% end function