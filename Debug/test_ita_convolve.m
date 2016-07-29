function test_ita_convolve

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Testinstanzen
I = [6 6
    8 6
    12 6
    ];

k = size(I,1);

for i=1:k
   m = I(i,1);
   n = I(i,2);

   A = ita_generate('noise',1,44100,m);
   B = ita_generate('impulse',1,44100,n);

   C1 = ita_convolve(A,B,'overlap_add',false);
   C1 = ita_ifft(C1);
   
   C2 = ita_convolve(A,B,'overlap_add',true);
   C2 = ita_ifft(C2);

   if ~(C1 == C2)
      error('test_convolve_overlap_add: Overlap-add and linear convolution dont return same results') 
   end
   
end
end