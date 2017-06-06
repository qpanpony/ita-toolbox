function varargout = ita_sph_modal_strength(varargin)
%ITA_SPH_MODAL_STRENGTH - Calculate the modal strength function for a spherical array
%  This function calculates the modal strength for a plane wave incident 
%  onto a spherical microphone aray. The output is a diagonal matrix if the sampling 
%  has a unique radius. If not, the output is a matrix with full rank. In case the wave 
%  number k is given as a vector the output is of size N x M x nBins.
%
%  Syntax:
%   B = ita_sph_modal_strength(sampling, Nmax, k, 'rigid')
%
%   Options (default):
%           'transducer' (microphone)	: microphone or loudspeaker array
%           'hankelKind' (2)			: choose kind of Hankel function
%
%  Example:
%   B = ita_sph_modal_strength(sampling, Nmax, k, 'rigid')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_modal_strength">doc ita_sph_modal_strength</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  26-Feb-2016 

%% Initialization and Input Parsing
sArgs = struct('pos1_sampling','itaCoordinates',...
               'pos2_maxOrder','integer', ...
               'pos3_k','double',...
               'pos4_type','string',...
               'transducer','microphone',...
               'scatterer',[],...
               'hankelKind',2,...
			   'dist',2);
[sampling,Nmax,kVec,type,sArgs] = ita_parse_arguments(sArgs,varargin);

% check if the sampling has a unique radius
if numel(unique(sampling.r)) > 1
    uniRSort = sort(unique(sampling.r));
    if uniRSort(1) > uniRSort(end)*(1-2*eps) && uniRSort(end) < uniRSort(1)*(1+2*eps)
        sampling.r = repmat(mean(uniRSort),size(sampling.r));
        uniqueRad = mean(uniRSort);
        B = zeros((Nmax+1)^2,(Nmax+1)^2,numel(kVec));
    else
        [uniqueRad,~,idxSamplingPos] = unique(sampling.r);
        B = zeros(sampling.nPoints,(Nmax+1)^2,numel(kVec));
    end
else
    uniqueRad = unique(sampling.r);
end

% calculate impedance only once to avoid dealing with units
if (strcmp(sArgs.transducer,'ls'))
    Z_air = double(ita_constants('z_0'));
end

n = (0:Nmax).';
for idxRad = 1:numel(uniqueRad)
    switch type
        case {'open','interior'}
            bn = ita_sph_besselj(n,uniqueRad(idxRad)*kVec);
        case 'rigid'
            if isempty(sArgs.scatterer)
                % if the scatterer and the sampling share the same radius
                % use the wronskian for speed reasons
                bn = 1./ita_sph_besselh_diff(n,sArgs.hankelKind,uniqueRad(idxRad)*kVec);
            else
                % if a spherical scatterer with a radius different than the
                % radius of the sampling is used we cannot use the
                % wronskian relation
                bn = ita_sph_besselj(n,uniqueRad(idxRad)*kVec) - ...
                    ita_sph_besselj_diff(n,sArgs.scatterer*kVec) ./ ...
                    ita_sph_besselh_diff(n,sArgs.hankelKind,sArgs.scatterer*kVec) .* ...
                    ita_sph_besselh(n,sArgs.hankelKind,uniqueRad(idxRad)*kVec);
            end
        case 'cardioid'
            bn = ita_sph_besselj(n,uniqueRad(idxRad).*kVec) - ...
                1i.*ita_sph_besselj_diff(n,1,uniqueRad(idxRad).*kVec);
        otherwise
            ita_verbose_info('This is not a valid design type.',0);
            varargout{1} = [];
            return
    end
    
    switch sArgs.transducer
        case {'microphone','mic'}
            if strcmp(type,'rigid') && isempty(sArgs.scatterer)
                bn = bn.*(4*pi*(1i.^(n-1))*(1./(kVec.*uniqueRad(idxRad)).^2));
            else
                bn = diag(4*pi*1i.^n)*bn;
            end
        case {'loudspeaker','ls'}
            if strcmp(type,'rigid') && isempty(sArgs.scatterer)
                bn = diag((-1i) * (-1)^sArgs.hankelKind * Z_air)*bn.*ita_sph_besselh(n,sArgs.hankelKind,sArgs.dist*kVec);
            else
                ita_verbose_info('This design type makes no sense for a loudspeaker array.',0);
                varargout{1} = [];
                return
            end
        otherwise
            ita_verbose_info('I do not know this kind of transducer.',0);
            varargout{1} = [];
            return
    end
    
    if kVec(1) == 0
        bn(:,1) = real(bn(:,2));
    end
    
    bn = ita_sph_eye(Nmax,'n-nm').'*bn;
    if numel(uniqueRad) > 1
        B(idxSamplingPos==idxRad,:,:) = repmat(permute(bn,[3,1,2]),[numel(idxSamplingPos(idxSamplingPos==idxRad)),1,1]);
    else
        for idxFreq = 1:numel(kVec)
            B(:,:,idxFreq) = diag(bn(:,idxFreq));        
        end
    end
end

varargout{1} = B;
end
