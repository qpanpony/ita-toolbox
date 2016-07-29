function objS = test_rbo_FIR_lagrange_delay(varargin)
Delay           = varargin{1};
obj             = varargin{2};

% Input: obj itaAudio Object
%        Delay total time of the delay - only positive shifts are allowed
% Output: Shifted itaAudio
if Delay < 0
    error('test_rbo_FIR_lagrange_delay:Delay','Please, no negative shifts')
end

lFilter         = obj.nSamples;
nFilter         = lFilter-1;                    % filter order
mFilter         = floor(nFilter/2);             % middle value
h               = ones(numel(Delay),nFilter+1);
Samples_int     = floor(Delay*obj.samplingRate);

for iDelay = 1:numel(Delay)
    fracSamples = mod(Delay(iDelay),1/obj.samplingRate)*obj.samplingRate;
    D           = fracSamples+mFilter;   % integer part closest to middle
    
    % Lagrange Interpolation - splitting the Unit Delay (Laakso & Välimäki, 1996)
    k           = 0:nFilter;
    for n = 0:nFilter
        kTmp            = k;
        kTmp(k==n)      = [];
        h(iDelay,n+1)   = prod((D-kTmp)./(n-kTmp));
    end
    h(iDelay,:) = h(iDelay,:)/sum(h(iDelay,:));
end

FIR_Lagrange            = obj;
FIR_Lagrange.timeData   = h';
objSubS                 = ita_multiply_spk(obj,FIR_Lagrange);

objS = ita_time_shift(objSubS,Samples_int-mFilter,'samples');
end

% objS = objSubS;
% z = ita_merge(obj,objS);

% if Samples_int==3
%     test = ita_merge(objS, obj);
%     test.channelNames{1} = 's';
%     test.channelNames{2} = 'o';
%     test.pt
% end
%         h2 = hlagr2(lFilter,fracSamples);
%         h2 = h2/sum(h2);
%         plot(h(iDelay,:)); hold all;
%         plot(h2+1); hold off
% %         pause(1)
% function h = hlagr2(L,x)
% % HLAGR2
% % MATLAB m-file for fractional delay approximation
% % by LAGRANGE INTERPOLATION method
% % h = hlagr2(L,x) returns a length L (real) FIR
% % filter which approximates the fractional delay
% % of x samples.
% % Input: L = filter length (filter order N = L-1)
% %        x = fractional delay (0 < x <= 1)
% % Output: Filter coefficient vector h(1)...h(L)
% % Subroutines: standard MATLAB functions
% %
% % Timo Laakso 27.12.1992
% % Revised 14.01.1996 by Timo Laakso
% %         17.01.1996 by Vesa Valimaki
% N = L-1;                    % filter order
% M = N/2;                    % middle value
% if (M-round(M))==0 D=x+M;   % integer part closest to middle
% else D=x+M-0.5; end;
% %
% h=ones(1,(N+1));
% %
% for n=0:N
%     n1=n+1;
%     for k=0:N
%         if (k~=n)
%             h(n1) = h(n1)*(D-k)/(n-k);
%         end  % if
%     end; % for k
% end; % for n
% end