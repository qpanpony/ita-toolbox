function ita_verify_ita_get_surface_impedance()
% ITA_VERIFY_ITA_GET_SURFACE_IMPEDANCE - does ita_get_surface_impedance work correctly?
% This small test file shows that the implementation of the function
% ita_get_surface_impedance works correctly
% 
% We therefore calculate a surface impedance from the Delany Bazley model
% and use the spherical reflection factor for a forward calculation of the 
% field impedance at the measurement point. We then use the methods in
% ita_get_surface_impedance to recalculate the surface impedance.
% In the case of the iterative method by Jacobsen, it should be possible
% to get a perfect recalculation of the initial impedance

% <ITA-Toolbox>
% This file is part of the application MicroflownImpedanceProcessor for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


warning off %no 'divide by zero' warnnigs

emptyImp = itaAudio();
emptyImp.samplingRate = 44100;
emptyImp.timeData = zeros(2^10,1);
emptyImp.channelUnits = {'kg/(s m^2)'};
emptyImp.comment      = 'Default Impedance';
emptyImp.channelNames = {'Delany Bazley impedance'};


f      = emptyImp.freqVector;      % frequency
sigma  = 50000;                      % flow resistivity
rho0   = 1.205;
c      = 343.4;
k      = (2*pi*f)/c;                 % wave number
h_s    = 0.5;
h      = 0.05;

j = sqrt(-1);

Z0     = rho0*c;

z_surf = emptyImp;                 % initialize itaAudio() 
z_surf.freqData = (1+9.08*(1000*f/sigma).^(-0.75)) - (j*11.9*(1000*f/sigma).^(-0.73)); % Delany & Bazley Model - real original impedance

R      = (z_surf-1)/(z_surf+1);
alpha  = 1 - (abs(R))^2;

[ Q, dQdh ] = Sphfactor(z_surf.freqData,h_s,h,k);


P = (1/(h_s-h)) .* exp(-j.*k.*(h_s-h)) + Q .* (1./(h_s+h)) .* exp(-j.*k.*(h_s+h));
U = (1/(h_s-h)) .* (1+(1./(j.*k.*(h_s-h)))) .* exp(-j.*k.*(h_s-h)) - ...
    Q .* (1/(h_s+h)) .* (1+(1./(j.*k.*(h_s+h)))) .* exp(-j.*k.*(h_s+h)) + ...
    dQdh .* exp(-j.*k.*(h_s+h)) ./ (j.*k.*(h_s+h));

Zm = emptyImp;
Zm.freqData = P./U; % Simulated measurement

[z_res1, R_res1, alpha_res1] = ita_get_surface_impedance( ...
                                                 Zm, Zm, h, ...
                                                 'method', 1, ...
                                                 'fieldImp', 'yes' ...
                                                        );
z_res1.channelNames = {'Imp. mit Modell 1'};
                                                      
[z_res2, R_res2, alpha_res2] = ita_get_surface_impedance( ...
                                                 Zm, Zm, h, ...
                                                 'method', 2, ...
                                                 'fieldImp', 'yes', ...
                                                 'dSourceSample', h_s ...
                                                        );
z_res2.channelNames = {'Imp. mit Modell 2'};
                                                    
[z_res3, R_res3, alpha_res3] = ita_get_surface_impedance( ...
                                                 Zm, Zm, h, ...
                                                 'method', 3, ...
                                                 'fieldImp', 'yes', ...
                                                 'dSourceSample', h_s ...
                                                        );
                                                    
% ita_plot_spk(ita_merge(alpha, alpha_res1, alpha_res2), 'nodB', 'ylim', [0,1]);

ita_plot_cmplx(ita_merge(z_surf, z_res1, z_res2, z_res3), 'nodB');

end %function Verify_Iterative_Method

function [ Q, dQdh ] = Sphfactor(Za,hs,h,k)

j = sqrt(-1);
e = 1e-5;

integral    = j*exp( j.*k.*(hs+h)./Za ) .* expint( j.*k .* (hs+h) .* (Za+1)./Za );
intPlusEps  = j*exp( j.*k.*(hs+h+e)./Za ) .* expint( j.*k .* (hs+h+e) .* (Za+1)./Za );
intMinusEps = j*exp( j.*k.*(hs+h-e)./Za ) .* expint( j.*k .* (hs+h-e) .* (Za+1)./Za );

Q         = 1 - ( 2.*(k./Za) .* (hs+h) ./ exp(-j.*k.*(hs+h)) .* integral );
QPlusEps  = 1 - ( 2.*(k./Za) .* (hs+h+e) ./ exp(-j.*k.*(hs+h+e)) .* intPlusEps );
QMinusEps = 1 - ( 2.*(k./Za) .* (hs+h-e) ./ exp(-j.*k.*(hs+h-e)) .* intMinusEps );

dQdh = ( QPlusEps - QMinusEps ) / (2*e);

end %function Sphfactor 