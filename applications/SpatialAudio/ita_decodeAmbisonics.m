function [ loudspeakerSignals ] = ita_decodeAmbisonics( Bformat, LoudspeakerPos, varargin )
%ITA_DECODEAMBISONICS Summary of this function goes here
%   Detailed explanation goes here

opts.decoding='remax' % Decoding strategy (remax,inphase,plane)

opts = ita_parse_arguments(opts,varargin);


% Initializing further parameters
nmax=numel(Bformat);

% Weighting for Inphase/ReMax
g_re=ones(nmax,1); %init weighting factors for ReMax
g_in=g_re; %init weighting factors for InPhase


% ReMax Decoding
if(sum(strcmp(lower(opts.decoding),{'remax' 'both'})))
    %             Calculates the B-Format channel weights for ReMax-Decoding
    %             see J.Daniel Thesis p.312 A.67/A.68
    weightsReMax=zeros(nmax,1); % init weights
    % g_m=P_m(r_E) with n=0 for P
    % r_E is largest root of P_(order+1)
    syms x;
    f=1/2^(TheOrder+1)/factorial(TheOrder+1)*diff(((x^2-1)^(TheOrder+1)),(TheOrder+1));%Legendre Polynom n=0 m=order+1
    maxroot=max(eval(solve(f))); %find maximum root(Nullstelle)
    for k=1:nmax
        leggie=legendre(ita_sph_linear2degreeorder(k),abs(maxroot)); % g_m=P_m(r_E)
        weightsReMax(k)=leggie(1);% pick n=0
    end
    g_re=weightsReMax;
end

% Inphase Decoding
if(sum(strcmp(lower(opts.decoding),{'inphase' 'both'})))
    %             Calculates the B-format channel weights for InPhase-Decoding
    TheOrder = obj.ambGetOrder; % amb order from sim room
    nmax = (TheOrder+1)^2; % number of channels
    weightsInPhase=zeros(nmax,1);
    N=numel(obj.monitorRoom.getSourcePosition)/3;% get number of loudspeaker
    %Dissertation J.Daniel p.314, 'preserve Energy' in 0. order
    %g_0=sqrt[N*(2*M+1)/(M+1)^2]
    weightsInPhase(1)=sqrt(N*(2*TheOrder+1)/(TheOrder+1)^2);
    
    for k=2:nmax
        m=ita_sph_linear2degreeorder(k);
        % Dissertation J.Daniel p.314
        % g_m=M!*(M+1)!/[(M+m+1)!*(M-n)!]
        weightsInPhase(k)=factorial(TheOrder)*factorial(TheOrder+1)/factorial(m+TheOrder+1)/factorial(TheOrder-m);
    end
    g_in=weightsInPhase;
end

weights=g_in.*g_re; %merge weighting factors
for k=1:numel(weights)
        Bformat(:,k)=weights(k).*Bformat(:,k); %Apply weighting factors
end
% SH and inversion
Y = ita_sph_base(LS,TheOrder,'williams',false); % generate basefunctions
Yinv=pinv(Y); % calculate Pseudoinverse


if isa(Bformat,'itaAudio')
    for k=1:LS.nPoints
        OutputSignals(k)=sum(Bformat*Yinv(:,k)');
    end
    OutputSignals=ita_merge(OutputSignals(:));
else
    OutputSignals=Bformat*Yinv;
end



end
