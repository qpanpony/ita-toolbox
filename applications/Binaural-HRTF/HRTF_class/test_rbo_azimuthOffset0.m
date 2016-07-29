function varargout = test_rbo_azimuthOffset0(varargin)

HRTFin = varargin{1};
if ~iscell(HRTFin), HRTF{1} = HRTFin;
else HRTF = HRTFin;
end
iHRTF = numel(HRTF);

if nargin == 1
    theta   = 90;
    phi     = rad2deg(HRTF{1}.phi_Unique);
end

idxLU   = 20;
idxML   = 160;
idxMU   = 200;
idxUL   = 340;

phi0    = zeros(iHRTF,3); 
for iP = 1:iHRTF
    HRTFring = HRTF{iP}.sphericalSlice('theta_deg',theta);
    HRTFringS = ita_time_shift(HRTFring);
    
    ITDs = -HRTFringS.ITD('method', 'xcorr', 'filter' , [200 2000]);
    try
        [cPhi,I]    = sort(HRTFring.dirCoord.phi_deg);
        ITDsI       = ITDs(I);
        
        [~,pL1]     = min(cPhi);
        pL2         = find(cPhi>= idxLU,1,'first');
        pM1         = find(cPhi>= idxML,1,'first');
        pM2         = find(cPhi>= idxMU,1,'first');
        pU1         = find(cPhi>= idxUL,1,'first');
        [~,pU2]     = max(cPhi);
        
        pL          = polyfit(cPhi(pL1:pL2)',ITDsI(pL1:pL2),1); 
        pM = polyfit(cPhi(pM1:pM2)',ITDsI(pM1:pM2),1);
        pU = polyfit(cPhi(pU1:pU2)',ITDsI(pU1:pU2),1);
        
        phi0(iP,1)     = -pL(2)/pL(1);
        phi0(iP,2)     = -pM(2)/pM(1)-180;
        phi0(iP,3)     = -pU(2)/pU(1)-360;
    catch
        disp(num2str(iP))
    end
end

%%
varargout{1} =   -mean(phi0,2);
end