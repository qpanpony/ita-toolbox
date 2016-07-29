%
%  OpenDAFF
%

function [ c ] = daffv17_uprmul( a, b )
%DAFF_UPRMUL Calculate next higher multiple 
    r = mod(a,b);
    if (r == 0)
        c = a;
    else
        c = a + b - r;
    end
end
