function [result con] = maku_SYNTH_penalty_rot_error_2_max_cond(this)
%%
nSteps = 5;
maxVal = 6;

maxCond = 10.^(1: maxVal/(nSteps) :maxVal); 

rot_error = 0*pi/180;
WD_error = ita_sph_wignerD(this.nmax, -repmat(rot_error,1,3));

% freq = ita_ANSI_center_frequencies(this.freqRange,3);
freq = [250 500 1000 2000 4000 6000];

result = itaResult;
result.timeVector = maxCond;
result.timeData = zeros(length(maxCond),length(freq));

con = itaResult;
con.freqVector = freq;
con.freqData = zeros(length(freq),1);

for idxF = 1:length(freq)
    result.channelNames{idxF} = [int2str(freq(idxF)) ' Hz'];
    speaker = this.freq2coefSH_synthesisedSpeaker(freq(idxF),'nmax',this.nmax);
    
    con.freqData(idxF) = cond(speaker);
    for idx = 1:length(maxCond)
        disp([int2str(idxF) ', ' int2str(idx)]);
        
        sE = abs(maku_SYNTH_make_SynthMatrix(speaker, maxCond(idx), 0)...
            *(speaker * WD_error)).^2;
        divisor = sum(sE,2); divisor(~divisor) = 1;
        result.timeData(idx, idxF) = sqrt(mean(diag(sE) ./ divisor));
    end
end