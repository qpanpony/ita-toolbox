function varargout = ita_sph_aperture_function_sla(varargin)
%ITA_SPH_APERTURE_FUNCTION_SLA - +++ Short Description here +++
% Calculate the coefficients of the vibrating polar cap model at the given
% sampling positions.
% The matrix G will be either diagonal if only one membrane radius is used
% or a full matrix in case varying membrane radii are used

%
%  Syntax:
%   audioObjOut = ita_sph_aperture_function_sla(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_sph_aperture_function_sla(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_aperture_function_sla">doc ita_sph_aperture_function_sla</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  29-Mar-2016 


%% Initialization and Input Parsing
sArgs = struct('pos1_sampling','itaCoordinates',...
               'pos2_Nmax','integer',...
               'pos3_rMem','double',...
               'diag',false,...
               'r',[]);
[sampling,Nmax,rMem,sArgs] = ita_parse_arguments(sArgs,varargin);

rMemUnique = unique(rMem);
if ~isempty(sArgs.r)
    alpha = asin(unique(rMem) / sArgs.r);
else
    % aperture angle of the polar cap
    alpha = asin(unique(rMem)/unique(sampling.r));
end
arg = cos(alpha);

gn = zeros((Nmax+1)^2,numel(alpha));
gn(1,:) = (1-arg)*2*pi^2;

for idxAlpha=1:numel(alpha)
    for n = 1:Nmax
        % gn(n^2+1:(n+1)^2,idxAlpha) = (repmat(legendreP(n-1, arg(idxAlpha)),(n+1)^2-n^2,1) - repmat(legendreP(n+1, arg(idxAlpha)),(n+1)^2-n^2,1)).*(4*pi^2/(2*n+1));

        % calculate the Legendre polynomials from the associated Legendre 
        % functions Pnm  as this is faster than the matlab legendreP function
        % Pn(x) = Pn0(x)
        PlegendreMinus = legendre(n-1,arg(idxAlpha));
        PlegendrePlus = legendre(n+1,arg(idxAlpha));
        gn(n^2+1:(n+1)^2,idxAlpha) = (repmat(PlegendreMinus(1),(n+1)^2-n^2,1) - repmat(PlegendrePlus(1),(n+1)^2-n^2,1)).*(4*pi^2/(2*n+1));
    end
end


% find the sampling positions corrsponding to the membrane radii
% idxMem = zeros(numel(rMem),numel(rMemUnique));
G = zeros(sampling.nPoints,(Nmax+1)^2);
checkIdx = zeros(sampling.nPoints,(Nmax+1)^2);
if numel(rMemUnique) > 1 || ~sArgs.diag
    for idxMemUnique = 1:numel(rMemUnique)
        idxMem = ismember(rMem,rMemUnique(idxMemUnique));
        idxMem = repmat(idxMem,1,(Nmax+1)^2);
        checkIdx = or(checkIdx,idxMem);
        G = idxMem.*repmat(gn(:,idxMemUnique),1,sampling.nPoints).' + G;
    end
    
    % check if all sampling positions have been adressed
    if isempty(find(checkIdx ~= 0,1))
        ita_verbose_info('Some sampling positions were not addressed correctly! Aborting...',0);
        G = [];
        return;
    end
    
else
    G = diag(gn);
end

varargout{1} = G;

end