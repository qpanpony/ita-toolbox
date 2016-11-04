function x = gauss_seidel(A,b,x,tol,maxIter,silentFlag)
% solve linear system of equations using Gauss-Seidel method in matrix form

% Author: MMT -- Email: markus.mueller-trapet@rwth-aachen.de
% Created:  02-Nov-2016

lastx = x.*(1 + 10*tol);
nIter = 0;

%% Gauss-Seidel (with LU decomposition)
% U = triu(A,1);
% L = tril(A,0);
% T = -L\U;
% C = L\b;

N_scan = numel(b);

while norm(lastx-x)/norm(x) > tol && nIter < maxIter
    nIter = nIter + 1;
    lastx = x;    
    % from Brooks and Humphreys Paper
    for n = 1:N_scan
        x(n) = max(0,b(n) - (A(n,1:(n-1))*x(1:(n-1)) + A(n,(n+1):N_scan)*x((n+1):N_scan)));
    end
    for n = N_scan:-1:1
        x(n) = max(0,b(n) - (A(n,1:(n-1))*x(1:(n-1)) + A(n,(n+1):N_scan)*x((n+1):N_scan)));
    end
    % LU method
%     x = max(0,T*x + C);
    x(x < 1e-5.*max(x)) = 0; %limit dynamic range
end

%% check for convergence
if ~silentFlag
    if nIter == maxIter
        disp(['GaussSeidel: convergence not achieved after ' num2str(nIter) ' iterations']);
        x(:) = 0;
    else
        disp(['GaussSeidel: converged after ' num2str(nIter) ' iterations']);
    end
end

end % function