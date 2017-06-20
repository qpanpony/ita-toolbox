function plot_basis_functions(sampling, Nmax, Y)
% Helper function for plotting the SH basis functions
%
% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  Jun-2017

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


spatVec = zeros(sampling.nPoints, (Nmax + 1)^2);
for idx = 1:(Nmax + 1)^2
    shVec = zeros((Nmax + 1)^2, 1);
    shVec(idx) = 1;
    spatVec(:, idx) = Y(:,1:(Nmax+1)^2) * shVec;
end


mPlot = numel(-Nmax:Nmax);
nPlot = Nmax+1;
figure;

for n = 0:Nmax
    idxmPlot = ceil(mPlot / 2);
    for m = -n:n
        nm = ita_sph_degreeorder2linear(n, m);
        subplot(nPlot,mPlot, (n * mPlot) + idxmPlot + m)
        surf(sampling,spatVec(:,nm),'complex',~isreal(Y));
        view([140,21])
        if (n == 0)
            title('Spherical harmonic basis functions')
        end
    end
end

end