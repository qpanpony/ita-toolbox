function cThis = interp(this,varargin)
% function this = interp(varargin)
%
% Function to calculate HRTFs for arbitrary field points using a N-th order
% spherical harmonics (SH) interpolation / range extrapolation, as described in [1],
% SH expansion coefficients are calculated by means of a least-squares
% approach with Tikhonov regularization
%
% Function may also be used for spatial smoothing of HRTF using
% the method described in [2]. As field input use the original
% measurement grid and set the desired order of the SH matrix /
% truncation order.
%
% INPUT:
%     varargin{1}      ...  itaCoordinates object (required)
%                           varargin{1}.phi: desired azimuth angles for HRTF interpolation [0 2*pi)
%                           varargin{1}.theta: desired zenith angles for HRTF interpolation [0 pi]
%                           varargin{1}.r: (optional) desired radius used for range extrapolation in [m],
%                                    set to 1 if no range extrapolation is required
%     order            ...  order of spherical harmonics matrix (default: 50)
%     epsilon          ...  regularization coefficient (default: 1e-8)
%
% OUTPUT:
%     itaHRTF object
%     .freqData: interpolated / range-extrapolated HRTFs for defined field points
%     .timeData: interpolated / range-extrapolated HRIRs for defined field points
%     .dirCoord: itaCoordinates object
%
% Required: SphericalHarmonics functions of ITA Toolbox
%
% [1] Pollow, Martin et al., "Calculation of Head-Related Transfer Functions
%     for Arbitrary Field Points Using Spherical Harmonics Decomposition",
%     Acta Acustica united with Acustica, Volume 98, Number 1, January/February 2012,
%     pp. 72-82(11)
%
% Author:  Florian Pausch <fpa@akustik.rwth-aachen.de>
% Version: 2016-02-05

% TODO: check why this is still not working (coordinate assignment???)

sArgs           = struct('order',50,'eps',1e-5);
sArgs           = ita_parse_arguments(sArgs,varargin,2);
if ~isa(varargin{1},'itaCoordinates'),error('itaHRTF:interp', ' An itaCoordinate object is needed!')
end
field_in        = varargin{1};

% only take unique direction coordinates (round to 0.01deg resolution) 
tempfield       = unique(round([field_in.phi_deg*100 field_in.theta_deg*100]),'rows'); % may cause problems with older Matlab versions (<=R2013)!
tempfield = tempfield./100;
temp_r          = this.dirCoord.r(1);
field           = itaCoordinates(size(tempfield,1));
field.r         = repmat(temp_r,size(tempfield,1),1);
field.phi_deg   = tempfield(:,1);
field.theta_deg = tempfield(:,2);

N               = sArgs.order;
epsilon         = sArgs.eps;                                   % regularization parameter
k               = this.wavenumber;                             % wave number
k(1)            = eps;
% add eps to avoid NaN's

Nmax            = floor(sqrt(this.nDirections/4)-1);

% construct vector of length (N+1)^2 regularization weights and,
% if needed, spherical hankel functions of second kind (for r0 and r1)
if ~isequal(this.dirCoord.r(1),field.r(1))
    kr0 = k*this.dirCoord.r(1);                         % measurement radius
    kr1 = k*field.r(1);                                 % extrapolation radius
    
    hankel_r0 = ita_sph_besselh(1:Nmax,2,kr0);
    hankel_r1 = ita_sph_besselh(1:Nmax,2,kr1);
    hankel_div = hankel_r1 ./ hankel_r0;
    
    hankel_rep = hankel_div(:,1);
end

dweights = 1 + (0:Nmax).*((0:Nmax)+1);                        % calculate regularization weights

dweights_rep  = zeros(sum(2*(0:Nmax)'+1),1);
dweights_rep(1)=dweights(1);
counter = 2;
for n=1:Nmax
    nTimes = 2*n+1;
    dweights_rep(counter:counter+nTimes-1)=dweights(n+1)*ones(nTimes,1);
    
    if ~isequal(this.dirCoord.r(1),field.r(1))
        hankel_rep=[hankel_rep, repmat(hankel_div(:,n),1,2*n+1)];
    end
    counter = counter + nTimes;
end

%% move data from earcenter
ear_d       =   [-0.07 0.07];

%% Weights
[~,w]= this.dirCoord.spherical_voronoi;         % calculate weighting coefficients (Voronoi surfaces <-> measurement points)

% sG_full = ita_sph_sampling_equiangular(73,144,'theta_type','[]','phi_type','[)');
% % sG_full = ita_sph_sampling_gaussian(71);
% sG = sG_full;
% isOnArc = sG.theta < 2.75;
% sG.cart = sG.cart(isOnArc,:);
% sG.weights = sG.weights(isOnArc);
% % rescale the weights for the sum to be 4*pi again
% w = sG.weights .* 4.*pi ./ sum(sG.weights);

W = sparse(diag(w));                                      % diagonal matrix containing weights
D = sparse(diag(dweights_rep));                                  % decomposition order-dependent Tikhonov regularization
Y = ita_sph_base(this.dirCoord,Nmax,'orthonormal',false);   % calculate real-valued SHs using the measurement grid

%% Calculate HRTF data for field points
if Nmax > 25
    ita_disp('[itaHRTF.interp] Be patient...')
end
    
% init.
hrtf_arbi = zeros(this.nBins,2*field.nPoints); % columns: LRLRLR...
for ear=1:2
    
    freqData_temp   = this.freqData(:,ear:2:end);
    

%     newCoords = this.dirCoord;
%     newCoords.y = newCoords.y + ear_d(ear);
%     
%     data.channelCoordinates = newCoords;
%     data.freqData = freqData_temp;
%     data.freqVector = this.freqVector;
%     data.c_meas = 344;
%     data = process_result_delay_correction(data,this.dirCoord.r(1));
%     % calculate weighted SH coefficients using a decomposition order-dependent Tikhonov regularization
%     
%     freqData_temp = data.freqData;
%     Y = ita_sph_base(data.channelCoordinates,Nmax,'orthonormal',false);
    
    a0              = (Y.'*W*Y + epsilon*D) \ Y.'*W * freqData_temp.';
    %a0 = (Y.'*W*Y + epsilon*D) \ Y.' *
    %this.freqData(:,ear:2:end).'; % fpa version
    %a0 = pinv(Y)* this.freqData(:,ear:2:end).'; % jck version
    
    if ~isequal(this.dirCoord.r(1),field.r(1))
        % calculate range-extrapolated HRTFs
        a1 = a0 .* hankel_rep.';
        
        Yest = ita_sph_base(field,N,'orthonormal',false);  % use real-valued SH's
        hrtf_arbi(:,ear:2:end) = (Yest*a1).';           % interpolated + range-extrapolated HRTFs
    else
        Yest = ita_sph_base(field,Nmax,'orthonormal',false);  % use real-valued SH's
        hrtf_arbi(:,ear:2:end) = (Yest*a0).';           % interpolated HRTFs
    end
end


%% move back to head center
% todo

% for ear=1:2
%     
%     newCoords = field;
%     newCoords.y = newCoords.y - ear_d(ear);
%     
%     freqData = hrtf_arbi(:,ear:2:end);
%   
%     
%     data.channelCoordinates = newCoords;
%     data.freqData = freqData;
%     data.freqVector = this.freqVector;
%     data.c_meas = 344;
%     data = process_result_delay_correction(data,this.dirCoord.r(1));
%     
%     hrtf_arbi(:,ear:2:end) = data.freqData;
%     
% end


% set new direction coordinates
sph                         = zeros(field.nPoints*2 ,3);
sph(1:2:end,:)              = field.sph;
sph(2:2:end,:)              = field.sph;

% write new HRTF data set
cAudio                      = itaAudio(hrtf_arbi, 44100, 'freq');
cAudio.channelCoordinates.sph= sph;

cThis                       = itaHRTF(cAudio);
cThis.freqData              = hrtf_arbi;

if ~isequal(cThis.dirCoord.r(1),field.r(1))%???
    cThis.dirCoord.r = field.r;
end

if N > 25
    ita_disp('[itaHRTF.interp] ...calculation finished!')
end
end


function result = process_result_delay_correction(result, target_d)
    % shift every measurement point to target_d by applying a
    % phase shift to the channel: (simplified!)
    freq_L              =   result.freqVector;

    add_phase_L         =   (result.channelCoordinates.r - target_d)* (freq_L./result.c_meas)' .* 2.*pi;
    
    result.freqData  =   result.freqData .* exp(1i.*add_phase_L');
    
    result.channelCoordinates.r  =   target_d;

end
