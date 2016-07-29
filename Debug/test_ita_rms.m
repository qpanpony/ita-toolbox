function test_ita_rms()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ita_verbose_info('Testing RMS calculation',1)
%% energy signal: timedomain
imp14 = ita_generate('impulse', 1, 44100, 14);
imp15 = ita_generate('impulse', 1, 44100, 15);

if abs(imp14.rms - imp15.rms) / imp14.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Energy signal in time domain: okay',1)
else
    error('rms not equal for extended energy signal (calculated in time domain)')
end


%% energy signal: freqdomain
imp14F = imp14';
imp15F = imp15';

if abs(imp14F.rms - imp15F.rms) / imp14F.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Energy signal in freq domain: okay',1)
else
    error('rms not equal for extended energy signal (calculated in freq domain)')
end

%%


if abs(imp14F.rms - imp14.rms) / imp14F.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Energy signal in time vs freq domain: okay',1)
else
    error('rms not equal for energy signal (calculated in time vs. freq domain)')
end


%% power signal: timedomain
sin14 = ita_generate('sine',1,20000,44100,14,'fullperiod');
sin15 = ita_generate('sine',1,20000,44100,15,'fullperiod');


if abs(sin14.rms - sin15.rms) / sin14.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Power  signal in time domain: okay',1)
else
    error('rms not equal for extended power signal (calculated in time domain)')
end


%% power signal: freq
sin14F = sin14';
sin15F = sin15';

if abs(sin14F.rms - sin15F.rms) / sin14F.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Power  signal in freq domain: okay',1)
else
    error('rms not equal for extended power signal (calculated in freq domain)')
end


%% same result im both domains
if abs(sin14F.rms - sin14.rms) / sin14F.rms  < 0.0001 % 0.01 percent error okay
    ita_verbose_info('   Power  signal time vs freq domain: okay',1)
else
    error('rms not equal for power signal (calculated in time vs. freq domain)')
end

%%
ita_verbose_info('RMS test done',1)

end