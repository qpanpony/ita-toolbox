n1 = [1, 1, 0];
n2 = [-1, 1, 0];
loc = [0, 0, -3];
w = itaInfiniteWedge(n1, n2, loc);
src = [-8, -1, -1];
rcv = [8, -1, 1];
ref = w.get_source_facing_side( src ); % reference wedge
p = [0, 0, 2];
len = 18;
wt = 'corner';

finw = itaFiniteWedge(n1, n2, loc, len);
finw.point_on_aperture(p)

res_finw = ita_diffraction_btm_finite_wedge(finw, src, rcv)
res_finw.pt;
res_finw.pf;

p2 = [0, -1.0001, 5];
finw.point_outside_wedge(p2)

f_s = 44100; % sampling rate
l = 1024; % filter length

res = ita_diffraction_btm_infinite_wedge(w, src, rcv, f_s, l)
res.pt;
% xlim([0, 0.006]);
res.pf;