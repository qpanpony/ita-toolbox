%
%  OpenDAFF
%

function [ c ] = daffv17_lwrmul( a, b )
%DAFF_LWRMUL Calculate next lower multiple 
    r = mod(a,b);
    if (r == 0)
        c = a;
    else
        c = a - r;
    end
end
