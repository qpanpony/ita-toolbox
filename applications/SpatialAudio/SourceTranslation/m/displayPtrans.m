function displayPtrans(params, state);
% displayPtrans.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% displayPtrans(params, state);
% Display the translated function p(k,th,ph).
%
% Input Parameters:
%   params - input parameters of main simulation.
%   state - intermediate results.
%
% Output Parameters;
%   none.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display interpolated p(k,th,phi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K = params.fft.K;
kr = params.center.kr_freqs_x_1;
N = params.source.N;
f_khz = (params.fft.f)/1000;
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto')
fontsize = 20;
set(gca,'fontsize',fontsize,'fontweight','bold');
for k_ind = 1:K
    surf(params.display.grid, state.translation.interp_p(:,k_ind));
    title(sprintf('p(k,th,ph) at %3.1f KHz',f_khz(k_ind)));
    set(gca,'fontsize',fontsize,'fontweight','bold');
end
