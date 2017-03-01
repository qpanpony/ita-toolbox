function correcPhase = correct_phase(phase,fs)
%function correcPhase = correct_phase(phase,fs);
%
%
%WRAPPED phase expected!!!
%length = N/2+1 expected!!! dc..nqy
%
%phase correction as suggested by [Mueller & Massarani 2001], p.38 
%
%[Mueller & Massarani 2001]
% Mueller, S. & Massarani, P. (2001). Transfer-Function Measurement with
% Sweeps. Directors Cut Including Previously Unreleased Material And Some
% Corrections. JAES, 49 (6), 443-471.

len=length(phase);

%get Parameters needed for calculation
phi_end=phase(end);
N=(len-1)*2;
df=fs/N;

%build a vector of length(phase) that keeps the correction
temp=ones(len,1);
temp=cumsum(temp)-1;
offset=df*phi_end/(fs/2);
correc=temp*offset;
%CORRECTING:
correcPhase=phase-correc;


%DISPLAYING last 3 values
if 0
    fprintf('\tPhase @ NYQ-2: %10.4f  \n',correcPhase(len-2));
    fprintf('\tPhase @ NYQ-1: %10.4f  \n',correcPhase(len-1));
    fprintf('\tPhase @ NYQ: %10.4f  \n',correcPhase(len));
end