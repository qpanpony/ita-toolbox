function x = focuss(A,b,x,tol,maxIter,silentFlag)
% solve linear system of equations using FOCUSS (sparse solution)

% Author: MMT -- Email: markus.mueller-trapet@rwth-aachen.de
% Created:  02-Nov-2016

lastx = x.*(1 + 10*tol);
nIter = 0;

%% regularized FOCUSS
p = 0;
while norm(lastx-x)/norm(x) > tol && nIter < maxIter
    nIter = nIter + 1;
    lastx = x;
    Wp = diag(abs(x).^(1-p/2));
    AW = A*Wp;
    AWinv = (AW'*AW + 1e-6.*norm(AW).*eye(size(A)))\AW';
    x = Wp*(AWinv*b);
    x = max(0,x);
%     x(x < 1e-3.*max(x)) = 0; %limit dynamic range
end

%% check for convergence
if ~silentFlag
    if nIter == maxIter
        disp(['FOCUSS: convergence not achieved after ' num2str(nIter) ' iterations']);
        x(:) = 0;
    else
        disp(['FOCUSS: converged after ' num2str(nIter) ' iterations']);
    end
end

end % function