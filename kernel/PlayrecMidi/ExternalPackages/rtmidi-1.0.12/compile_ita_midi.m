% Author: Pascal Dietrich, ITA, RWTH Aachen, March 2011
% http://www.music.mcgill.ca/~gary/rtmidi/index.html#compiling

clear mex
ccx %ITA-Toolbox -- ccx: the best clear ever !!!

%% Compiler and Linker Call
% Linux 	ALSA Sequencer 	__LINUX_ALSASEQ__ 	asound, pthread 	g++ -D__LINUX_ALSASEQ__ -o ita_midi ita_midi.cpp RtMidi.cpp -lasound -lpthread
% Macintosh OS X 	CoreMidi 	__MACOSX_CORE__ 	CoreMidi, CoreAudio, CoreFoundation 	g++ -Wall -D__MACOSX_CORE__ -o midiprobe midiprobe.cpp RtMidi.cpp -framework CoreMidi -framework CoreAudio -framework CoreFoundation
% Irix 	MD 	__IRIX_MD__ 	md, pthread 	CC -Wall -D__IRIX_MD__ -o midiprobe midiprobe.cpp RtMidi.cpp -laudio -lpthread
% Windows 	Multimedia Library 	__WINDOWS_MM__ 	winmm.lib, multithreaded 	compiler specific

if ismac()
    cd(fileparts(which('compile_ita_midi.m')))
    clc
    mex -v -D__RTMIDI_DEBUG__ -D__MACOSX_CORE__ LDFLAGS='\$LDFLAGS -Wall -framework CoreMidi -framework CoreAudio -framework CoreFoundation' ita_midi.cpp RtMidi.cpp
end

if ~ismac() && isunix()
    cd(fileparts(which('compile_ita_midi.m')))
    clc
    mex -v -D__LINUX_ALSASEQ__ LDFLAGS=\$LDFLAGS -D__LINUX_ALSASEQ__ -o ita_midi ita_midi.cpp RtMidi.cpp -lasound -lpthread
end

if ispc()
    cd(fileparts(which('compile_ita_midi.m')))
    clc
    if strcmpi(computer,'pcwin')
        disp('pcwin')
        mex -v -D__WINDOWS_MM__ ita_midi.cpp RtMidi.cpp LINKFLAGS="$LINKFLAGS winmm.lib"
    else
        % 64 bit
        mex -v -D__WINDOWS_MM__ ita_midi.cpp RtMidi.cpp LDFLAGS=\$LDFLAGS -lwinmm
    end
end

%%
movefile([fileparts(which('compile_ita_midi.m')) filesep 'ita_midi.' mexext],[fileparts(which('ita_portaudio_run.m')) filesep 'ita_midi.' mexext] )

disp('finished')
return