function phase = wrap(unwrapped_phase);
%function phase = wrap(unwrapped_phase);
%
%vector based function
%does the opposite of unwrap

a=  unwrapped_phase;
b=  a/(2*pi);
c=  round(b);
d=  c*2*pi;
e=  d-a;
e=  -e;

phase=e;
return