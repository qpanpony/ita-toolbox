function result = ita_sph_order_energy(SH)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % Toblerone side view energy summed plot (mpo)
    %
    % gives [freq  x  SH-order]
    % you can use itaSuper (or children) or a plain matrix
    
    use_itaSuper = isa(SH,'itaSuper');
    
    if use_itaSuper
        result = SH;
        SH = SH.freq;
    end
    
    if min(size(SH)) == 1
        % only SH coefs, no frequency
        SH = SH(:).';
    end
    % [freq x SH]
 
    nSH = size(SH,2);
    n_max = ceil(sqrt(nSH) - 1);
    eyeMat = ita_sph_eye(n_max,'n-nm');
    order = abs(SH).^2*eyeMat.';
    
    if use_itaSuper
        result.freq = order;
    else
        result = order;
    end    
end
