function out = correlation_of_ideal_and_synthesised_directivity(this,in,varargin)

sArgs = struct('channels',[],'freq',this.freqVector,'nmax',this.nmax);

if nargin > 2
    sArgs = ita_parse_arguments(sArgs, varargin);
end

nCoef = (sArgs.nmax+1)^2;
freq = sArgs.freq; freq = sort(freq);
bla_e = 'What do you want?';

out = itaResult;
out.freqVector = freq;
out.freqData = zeros(length(freq),1);

if isa(in,'itaBalloon')
    v_cf = false; %gibbet nich, musste laden...
elseif length(in) == 1
    if mod(in,1), error(bla_e); end
    if in > nCoef, error(bla_e); end
    v_cf = zeros(1,nCoef);
    v_cf(in) = 1;
elseif length(in) == 2;
    in = ita_sph_degreeorder2linear(in(1),in(2));
    if mod(in,1), error(bla_e); end
    if in > nCoef, error(bla_e); end
    v_cf = zeros(1,nCoef);
    v_cf(in) = 1;
elseif length(in) == nCoef;
    if size(in,2) ~= nCoef
        v_cf = in.';
    else
        v_cf = in;
    end
    if size(v_cf > 1)
        error(bla_e);
    end
else
    error(bla_e);
end

idc = 1:(sArgs.nmax+1)^2;
for idxF = 1:length(freq)
    if ~v_cf
        coef = (in.freq2coefSH(freq(idxF),'nmax',sArgs.nmax)).';
    else
        coef = v_cf;
    end
   freq2block = this.idxFreq2block(this.freq2idxFreq(freq(idxF)));
   if ~exist('actBlock','var') || freq2block(1) ~= actBlock
       actBlock = freq2block(1);
      synthMatrix = this.read([this.folder filesep 'synthData' filesep 'freqDataSY_' int2str(actBlock)]);
      synthSpeaker = this.read([this.folder filesep 'synthSuperSpeaker' filesep 'freqDataSH_' int2str(actBlock)]);
   end
   res_cf = coef * squeeze(synthMatrix(idc,:,freq2block(2))) * squeeze(synthSpeaker(:,idc,freq2block(2)));
   out.freqData(idxF) = sum(abs(res_cf.*conj(coef))) / sum(abs(coef).^2);   
end
%%
plotOut = out; 
plotOut.freqData = sqrt(plotOut.freqData);
plotOut.plot_spk('ylim',[-3 0.1]);