function varargout = ita_tpa_plot_matrix_condition_number(M,eigenfreq)
%ITA_TPA_PLOT_MATRIX_CONDITION_NUMBER - Plot condition number of itaSuperMatrix
%  This function calculates and plots the condition number of a matrix of
%  itaSuper Objects.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tpa_plot_matrix_condition_number">doc ita_tpa_plot_matrix_condition_number</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-June-2011 



%% get Data
for idx = 1:size(M,1)
    for jdx = 1:size(M,2)
        data(idx,jdx,:) = M(idx,jdx).freqData;
    end
end

%% find cond number
res = 0*M(1,1);
condNumber = res.freqData;
for fidx = 1:M(1,1).nBins
    condNumber(fidx) = cond(data(:,:,fidx));
end
res.comment  = ['condition number - ' res.comment];
res.channelUnits{1} = '';
res.freqData = condNumber;

%% eigenfreq
if exist('eigenfreq','var')
    eF = res.ch(1) * 0;
    eF.freq(eF.freq2index(eigenfreq)) = res.freq(eF.freq2index(eigenfreq));
    res = merge(res,eF);
end

%% Set Output
if nargout
    varargout(1) = {res};
else
    res.plot_spk('nodb')
end

%end function
end