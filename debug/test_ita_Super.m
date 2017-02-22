function test_ita_Super()
%Test itaSuper

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


a = itaSuper([100 1],1); %Create 100x100 itaSupers with 1 data-elem
b = itaSuper([100 1],1);

tic
for idx = 1:numel(a)
    a(idx).data = 1;
end
t1 = toc;

tic
for idx = 1:numel(b)
    b(idx).data = 1;
end
t2 = toc;

disp(t2/t1);
