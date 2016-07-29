function ita_menucallback_ThieleSmallParameters(varargin)

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


assignin('base','TS',ita_thiele_small_gui())
evalin('base','TS.show');
warndlg('Your result is a new variable "TS" in your workspace','Thiele-SmallParameters calculated!');

end