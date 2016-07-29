function test_ita_typecast
% Test cast@itaSuper

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


a = ita_generate('flatnoise',1,44100,6)/10000;
b = cast(a,'single');
b.channelNames = {'single'};
c = cast(a,'int32');
c.channelNames = {'int32'};
d = cast(a,'int16');
d.channelNames = {'int16'};
e = cast(a,'int8');
e.channelNames = {'int8'};
f = cast(a,'int64');
f.channelNames = {'int64'};

%ita_write(d,'test_typecast.ita');
%g = ita_read('test_typecast.ita');

%ita_plot_spk(merge([a d f]));
%ita_plot_dat(merge([a d g]));

%ita_plot_spk([a a/b a/c a/d a/e]);
%ita_plot_spk([a a-b a-c a-d a-e a-f]);
%title('Absolute error (double-x)')
%ylim([-350 10])
%close all;


end