function [z,p,k,varargout] = ita_zpk_reduce(z,p,k,varargin)
%ITA_ZPK_REDUCE - Reduce poles and zeros
%  This function checks for poles and zeros with distance smaller than the
%  specified threshold.
%
%  Syntax:
%   [z,p,k, (cancelled_points)] = ita_zpk_reduce(z,p,k, options)
%
%   Options (default):
%           'dist' (1e-2)       : Distance between poles and zeros
%           'zplane' (false)    : plot the remaning poles and zeros
%
%  Example:
%   [z,p,k] = ita_zpk_reduce(z,p,k,'dist',5e-4);
%
%  See also:
%   ita_plot_zplanepz, ita_prony_analysis
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zpk_reduce">doc ita_zpk_reduce</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal/Bruno -- Email: pdi/bma@akustik.rwth-aachen.de
% Created:  30-Aug-2010 


%% Initialization and Input Parsing
sArgs   = struct('dist',0.001,'zplane', false);
[sArgs] = ita_parse_arguments(sArgs,varargin); 

%% search for poles and zeros in vicinity of each other
[zeros_orig,poles_orig,gain] = deal(z,p,k);

%% classify poles and zeros in complex or real and intern or extern to the
%% unity circle

% inner search
z_in = zeros_orig(abs(zeros_orig)<= 1);
p_in = poles_orig(abs(poles_orig)<= 1);
[p_in_conj,p_in_real,z_in_conj,z_in_real] = split_imaginary(z_in,p_in);
[z_in_conj,p_in_conj,z_1,p_1] = cancellation_conj(z_in_conj,p_in_conj,sArgs.dist);
[z_in_real,p_in_real,z_2,p_2] = cancellation_real(z_in_real,p_in_real,sArgs.dist);

% outer search
z_out = zeros_orig(abs(zeros_orig)> 1);
p_out = poles_orig(abs(poles_orig)> 1);
[p_out_conj,p_out_real,z_out_conj,z_out_real] = split_imaginary(z_out,p_out);
[z_out_conj,p_out_conj,z_3,p_3] = cancellation_conj(z_out_conj,p_out_conj,sArgs.dist);
[z_out_real,p_out_real,z_4,p_4] = cancellation_real(z_out_real,p_out_real,sArgs.dist);

% concatenate significant poles and zeros.
z = [z_in_conj; z_in_real; z_out_conj; z_out_real];
p = [p_in_conj; p_in_real; p_out_conj; p_out_real];

% concatenate insignificant pz's
cancel.p = [p_1; p_2; p_3; p_4];
cancel.z = [z_1; z_2; z_3; z_4];

if sArgs.zplane
    ita_plot_zplanepz(z,p,gain)
end

ita_verbose_info([ num2str(length(cancel.p)) ' pairs of poles and zeros deleted.'],0);

if nargout
    varargout{1} = cancel;
end
%end function
end

function [p_conj,p_real,z_conj,z_real] = split_imaginary(z,p)
    z = cplxpair(z);
    p = cplxpair(p);

    ind = find(abs(imag(p)) <= 100*eps(class(p))*abs(p));
    p_real = p(ind);  
    p_conj = p; p_conj(ind) = [];

    ind = find(abs(imag(z)) <= 100*eps(class(z))*abs(z));
    z_real = z(ind);  
    z_conj = z; z_conj(ind) = [];
end

function [z,p,z_canc,p_canc] = cancellation_conj(z,p,threshold)
    % exclude poles/zeros too near to each other
    z_canc = [];
    p_canc = [];

    [z_aux,p_aux] = meshgrid(z(1:2:end),p(1:2:end));
    dist = abs(z_aux - p_aux);

    while ~isempty(dist)
        if min(min(dist)) <=  threshold
            [p_ind,z_ind] = find(dist == min(min(dist)));
            z_ind = 2*z_ind-1:2*z_ind; p_ind = 2*p_ind-1:2*p_ind;
            z_canc = [z_canc; z(z_ind)]; z(z_ind) = [];
            p_canc = [p_canc; p(p_ind)]; p(p_ind) = [];

            [z_aux,p_aux] = meshgrid(z(1:2:end),p(1:2:end));
            dist = abs(z_aux - p_aux);
        else
            dist = [];
        end
    end
end

function [z,p,z_canc,p_canc] = cancellation_real(z,p,threshold)
    % exclude poles/zeros too near to each other
    z_canc = [];
    p_canc = [];
    
    [z_aux,p_aux] = meshgrid(z,p);
    dist = abs(z_aux - p_aux);
    
    while ~isempty(dist)
        if min(min(dist)) <=  threshold
            
            [p_ind,z_ind] = find(dist == min(min(dist)));
            z_canc = [z_canc; z(z_ind)]; z(z_ind) = [];
            p_canc = [p_canc; p(p_ind)]; p(p_ind) = [];
            
            [z_aux,p_aux] = meshgrid(z,p);
            dist = abs(z_aux - p_aux);
        else
            dist = [];
        end
    end
end