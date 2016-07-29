function [A B C D] = ita_tpa_isolator(m,n,w,fftDegree,sr,F_units,v_units)
%ITA_TPA_ISOLATOR - Isolator Elements
%  This function realizes an isolator by fourpole modelling
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tpa_isolator">doc ita_tpa_isolator</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  04-Aug-2011 



%% Initialization and Input Parsing
s               = itaAudio();
s.fftDegree     = fftDegree;
s.samplingRate  = sr;
s.freq          = 1i * 2 * pi * s.freqVector;
s               = s * itaValue('Hz');
Null            = repmat(0*s/itaValue('Hz'),3,3);

%% units INIT
for idx = 1:numel(F_units)
    for jdx = 1:numel(v_units)
        Aunit(idx,jdx) = itaValue(0,ita_deal_units(F_units{idx}, F_units{jdx},'/'));
        Bunit(idx,jdx) = itaValue(0,ita_deal_units(F_units{idx}, v_units{jdx},'/'));
        Cunit(idx,jdx) = itaValue(0,ita_deal_units(v_units{idx}, F_units{jdx},'/'));
        Dunit(idx,jdx) = itaValue(0,ita_deal_units(v_units{idx}, v_units{jdx},'/'));
    end
end
Ainit = Null * Aunit + eye(3);
Binit = Null * Bunit;
Cinit = Null * Cunit;
Dinit = Null * Dunit + eye(3);

%% Two-port with mass / moment of inertia
% values
r = itaValue(0.005,'m');
l = itaValue(0.005,'m');
J = m *(r^2/4 + l^2/12);

A  = Ainit;B = Binit; C=Cinit;D = Dinit;

B(1,1) = - s * m;
B(2,2) = - s * J;
B(3,3) = - s * J;

T_mass = [A B; C D];


%% Two Port with spring and damper
%values
n_rot = n / itaValue(00.1 , 'm^2');

A  = Ainit;B = Binit; C=Cinit;D = Dinit;
w = w * (0*s/itaValue('Hz') +1);
C(1,1) =  - ((s * n ) | 1/w);
C(2,2) =  - ((s * n_rot) | 1/w/itaValue(1,'m^2'));
C(3,3) =  C(2,2);

T_spring = [A B; C D];

%% Isolator
T3 = T_mass * T_spring * T_mass;
DOF = 3;
idx = 1:DOF;
A = T3(idx,idx);
B = T3(idx,idx+DOF);
C = T3(idx+DOF,idx);
D = T3(idx+DOF,idx+DOF);


%end function
end