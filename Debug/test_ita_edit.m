function varargout = test_ita_edit()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% get three signals and a tp
sr = 44100;
fftdeg = 10;
a       = ita_generate('sine',1,1000,sr,fftdeg);
b       = ita_generate('noise',1,sr,fftdeg);
c       = ita_merge(a,b);
d       = ita_generate_sweep('mode','exp','freqRange',[2 22000],'samplingRate',44100,'fftDegree',15);
tp      = ita_fft(ita_merge(a,a,a,a));
tp.signalType = 'energy';
tparray(1) = tp;
tparray(2) = tp;

%% used to test the transformation at the beginning of functions
timeData = b;
freqData = ita_fft(b);

%% test functions
%x = ita_import(a.dat,44100,'t');

e = ita_abs(a);

e = ita_amplify(c,6);
e = ita_amplify(c,'6');
e = ita_amplify(c,'6dB');
if ~(a == ita_amplify(ita_amplify(a,'3dB'),'-3dB')) 
    error('ITA_AMPLIFY:Oh Lord. Function seems not to work properly.')
end

e = ita_append(timeData,freqData);
e = ita_append(a,a);
if ~([a.dat a.dat] == e.dat) 
    error('ITA_APPEND:Oh Lord. Function seems not to work properly.')
end
e = ita_convolve(a,b); 
% 
% e = ita_CTC_filter(tp);

e = ita_envelope(c);

e = ita_extend_dat(c);
e = ita_extend_dat(c,10000);             %indirect call of extract
e = ita_extend_dat(c,100000);
e = ita_extend_dat(c,10000,'symmetric'); %indirect call of extract
e = ita_extend_dat(c,100000,'symmetric');
e = ita_extend_dat(a,d);

e = ita_extract_dat(c,50);
e = ita_extract_dat(c,5,'symmetric');
e = ita_extract_dat(c,5);
e = ita_extract_dat(c,4,'firstsample',16);
e = ita_extract_dat(c,6,'forcesamples');
if e.nSamples ~= 6
   error('forcesamples does not work') 
end
e = ita_extract_dat(c,4,'random');
if ~(a == ita_extract_dat(ita_extend_dat(a)))
    error('ITA_EXTRACT_DAT/ITA_EXTEND_DAT:Oh Lord. Function seems not to work properly.')
end

e = ita_imag(a);

e = ita_make_filter([100 1000],sr,20);
e = ita_make_filter([100 1000],sr,fftdeg);
e = ita_make_filter([100 1000],c);

e = ita_mean(tp);
tp.channelNames{1} = 'test';
e = ita_mean(ita_merge(tp,tp),'same_channelnames_only');
if ~(a == ita_mean(ita_merge(a,a,a,a)))
    error('ITA_MEAN:Oh Lord. Function seems not to work properly.')
end
e = ita_mean(tparray);


e = ita_median(tp);
if ~(a == ita_median(ita_merge(a,a,a,a)))
    ita_verbose_info('ITA_MEDIAN:Oh Lord. Function seems not to work properly.',0)
end

e = ita_merge(ita_fft(a),a);
e = ita_merge(ita_fft(a),b);
e = ita_merge(a,d);

e = ita_minimumphase(c);

e = ita_mpb_filter(c,[0 2000]);
e = ita_mpb_filter(c,[0 2000],'order',2);
e = ita_mpb_filter(c,[0 2000],'order',2,'class',0);
e = ita_mpb_filter(c,[0 2000],'zerophase');
e = ita_mpb_filter(c,[0 2000],'minimumphase'); 
 
e = ita_mpb_filter(a,'octaves',3);
e = ita_mpb_filter(a,'oct',3);

e = ita_mpb_filter(c,'c-weight');
e = ita_mpb_filter(c,'a-weight');

e = ita_mpb_filter(c,[2000 0]);

% e = ita_multiple_time_windows(a,'blocksize',1024);
% e = ita_multiple_time_windows(ita_merge(a,b),'blocksize',1024,'overlap',0.1);
% e = ita_multiple_time_windows(ita_merge(a,b),'blocksize',1024,'overlap',0.1,'channels',[2]);
% e = ita_multiple_time_windows(ita_merge(a,b),'blocksize',1024,'overlap',0.1,'channels',[],'window',@hann,'old_ita_format',true,'funfunction',[],'function_arguments',[]);

e = ita_normalize_dat(ita_merge(a,b));
e = ita_normalize_dat(ita_merge(b,c,d));


e = ita_real(a);

e = ita_resample(tp,48000);

%e = ita_rms(a);



e = ita_smooth(a,'LinFreqBins', 10,'Real');
e = ita_smooth(d,'LinTimeSec', 1/3,'Real');
e = ita_smooth(d,'LinTimeSamp', 20,'Real');
e = ita_smooth(ita_fft(d),'LinTimeSec', 0.5,'Real');  %LinTimeSec => dateType = 'real'
e = ita_smooth(ita_fft(d),'LinTimeSamp', 5,'Real');  %LinTimeSam => dateType = 'real'

e = ita_smooth(ita_fft(a),'LinFreqBins', 10,'Real');
e = ita_smooth(ita_fft(a),'LinFreqBins', 10,'Abs');
e = ita_smooth(ita_fft(a),'LinFreqBins', 10,'Complex');
e = ita_smooth(ita_fft(a),'LinFreqBins', 10,'GDelay');
e = ita_smooth(ita_fft(a),'LinFreqBins', 10,'Abs+GDelay');

e = ita_smooth(ita_fft(d),'LinFreqHertz',5,'Real');
e = ita_smooth(ita_fft(d),'LinFreqHertz',5,'Abs');
e = ita_smooth(ita_fft(d),'LinFreqHertz',5,'Complex');
e = ita_smooth(ita_fft(d),'LinFreqHertz',5,'GDelay');
e = ita_smooth(ita_fft(d),'LinFreqHertz',5,'Abs+GDelay');

e = ita_smooth(ita_fft(d),'LogFreqOctave1',1/3,'Real');
e = ita_smooth(ita_fft(d),'LogFreqOctave1',1/3,'Abs');
e = ita_smooth(ita_fft(d),'LogFreqOctave1',1/3,'Complex');
e = ita_smooth(ita_fft(d),'LogFreqOctave1',1/3,'GDelay');
e = ita_smooth(ita_fft(d),'LogFreqOctave1',1/3,'Abs+GDelay');

e = ita_smooth(ita_fft(a),'LogFreqOctave2', 1/3,'Real');
e = ita_smooth(ita_fft(a),'LogFreqOctave2', 1/3,'Abs');
e = ita_smooth(ita_fft(a),'LogFreqOctave2', 1/3,'Complex');
e = ita_smooth(ita_fft(a),'LogFreqOctave2', 1/3,'GDelay');
e = ita_smooth(ita_fft(a),'LogFreqOctave2', 1/3,'Abs+GDelay');

[e1 e2] = ita_split(tp,[1 2],[3 4],'substring',true);
[ee1 ee2] = ita_split(tp,[1 2 3]);
e = ita_split(e1);
if ~(a == ita_split(ita_split(ita_merge(a,a,a))))
    error('ITA_SPLIT:Oh Lord. Function seems not to work properly.')
end

e = ita_time_crop(a,[1 10],'samples');
e = ita_time_crop(d,[0.1 0.2],'time');    %odd number of time samples, reducing by one


e = ita_time_reverse(d);
if ~(a == ita_time_reverse(ita_time_reverse(a)))
    error('ITA_TIME_REVERSE:Oh Lord. Function seems not to work properly.')
end

e = ita_time_shift(a);
e = ita_time_shift(a,'auto');
e = ita_time_shift(a,'10dB');
e = ita_time_shift(a,10);
e = ita_time_shift(a,0.2,'time');
if ~(a == ita_time_shift(ita_time_shift(a,-0.001),0.001))
    error('ITA_TIME_SHIFT:Oh Lord. Function seems not to work properly.')
end
e = ita_time_window(d,[0.2,0.1, 0.19,0.20],@hann,'time');
e = ita_time_window(d,[0.4,0.1],'time',@hann,'symmetric');
% e = ita_time_window(d,[0.4,0.5],'time','crop');
%        commented as there is a problem with odd number of samples

e = ita_uncle_hilbert(tp);

e = ita_xfade_spk(a,a,[1 3]);

e = ita_zerophase(tp);


% ir = ita_time_shift(ita_mpb_filter(ita_generate('impulse',1,5,44100),[200 4000]),20,'samples');
% ir1 = ita_interpolate_spk(ir,8,'absphase',false);
% ir2 = ita_interpolate_spk(ir,8,'absphase',true);

%% Find output parameters - using it for testing...
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {c}; 
end

%end function
end