function varargout = ita_fht(input)
%=======================================================
%FUNCTIONS FOR 1-D SEQUENCY(WALSH),DYADIC(PALEY) AND 
%NATURAL(HADAMARD)ORDERED FAST WALSH-HADAMARD TRANSFORM
%=======================================================

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



data = input.timeData;


varargout{1} = fhtnat(data);

if nargout > 2
    if input.nChannels > 1
        ita_verbose_info('warning: only first channel is calculated for sequency and dyadic ')
    end
    input.timeData = fhtseq(data);
    varargout{2} = input;
end

if nargout == 3
    varargout{3} = fhtdya(data);
end

end
%-------------------------------------------------------
%1D sequency(Walsh)ordered Fast Walsh-Hadamard Transform
%-------------------------------------------------------
function x=fhtseq(data)
% The function implement the 1D sequency(Walsh)ordered 
% fast Walsh-Hadamard transform,
% This algorithm is implemented in N log2 N additions and subtractions. 
% Data sequence length should be an integer power of 2.
% Otherwise last elements will be truncated.
% The inverse transform is the same as the forward transform 
% except for the multiplication factor N.
% 
% Example:
% x=[1 2 1 1]
% y=fhtseq(x)
% 
% Author: Gylson Thomas
% e-mail: gylson_thomas@yahoo.com
% Asst. Professor, Electrical and Electronics Engineering Dept.
% MES College of Engineering Kuttippuram,
% Kerala, India, February 2005.
% copyright 2007.

x=bitrevorder(data);
N=length(x);
k1=N; k2=1; k3=N/2;
for i1=1:log2(N)  % In-place iteration begins here 
    L1=1;
    for i2=1:k2
        for i3=1:k3
            i=i3+L1-1; j=i+k3;
            temp1= x(i); temp2 = x(j); 
            if(mod(i2,2) == 0)
              x(i) = temp1 - temp2;
              x(j) = temp1 + temp2;
            else
              x(i) = temp1 + temp2;
              x(j) = temp1 - temp2;
            end
        end
            L1=L1+k1;
    end
        k1 = k1/2;  k2 = k2*2;  k3 = k3/2;
end
x=inv(N)*x; %Delete this line for inverse transform
end

%------------------------------------------------------
%1D Dyadic(Paley)ordered Fast Hadamard Transform
%------------------------------------------------------
function x=fhtdya(data)
% The function implement the 1D dyadic (Paley) ordered fast Hadamard transform,
x=bitrevorder(data);
N=length(x);
k1=N; k2=1; k3=N/2;
for i1=1:log2(N)   
    L1=1;
    for i2=1:k2
        for i3=1:k3
            i=i3+L1-1; j=i+k3;
            temp1= x(i); temp2 = x(j); 
            x(i) = temp1 + temp2;
            x(j) = temp1 - temp2;
        end
            L1=L1+k1;
    end
        k1 = k1/2;  k2 = k2*2;  k3 = k3/2;
end
x=inv(N)*x; %Delete this line for inverse transform
end

%------------------------------------------------------
%1D Natural(Hadamard)ordered Fast Hadamard Transform
%------------------------------------------------------
function x=fhtnat(data)
% The function implement the 1D natural(Hadamard)ordered Fast Hadamard Transform,
N = pow2(floor(log2(length(data))));
x = data(1:N,:);
k1=N; k2=1; k3=N/2;
for i1=1:log2(N)
    L1=1;
    for i2=1:k2
        for i3=1:k3
            i=i3+L1-1; j=i+k3;
            temp1= x(i,:); temp2 = x(j,:); 
            x(i,:) = temp1 + temp2;
            x(j,:) = temp1 - temp2;
        end
            L1=L1+k1;
    end
        k1 = k1/2;  k2 = k2*2;  k3 = k3/2;
end
% x=inv(N)*x; %Delete this line for inverse transform
end

%------------------------------------------------------
% Function for bit reversal
%------------------------------------------------------
function R = bitrevorder(X)
%Rearrange vector X to reverse bit order,upto max 2^k size <= length(X)
[f,e]=log2(length(X));
I=dec2bin(0:pow2(0.5,e)-1);
R=X(bin2dec(I(:,e-1:-1:1))+1);
end