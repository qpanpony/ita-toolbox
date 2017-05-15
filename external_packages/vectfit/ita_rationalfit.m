function varargout = ita_rationalfit(freq,data,varargin)
%RATIONALFIT Perform rational function fitting to broadband data.
%   MODELOBJ = RATIONALFIT(FREQ,DATA) uses vector fitting with complex
%   frequencies S = j*2*pi*FREQ to construct a rational function fit
%
%            C(1)     C(2)           C(n)
%   F(S) =  ------ + ------ + ... + ------
%           S-A(1)   S-A(2)         S-A(n)
%
%   to broadband frequency-dependent DATA. FREQ is a column vector of
%   non-negative frequencies in Hz. DATA is a column vector (or a matrix of
%   vectors) of complex frequency-dependent data. The length of the DATA
%   vectors must be equal to the length of FREQ. The fit results are
%   returned as an RFMODEL.RATIONAL object.
%
%   MODELOBJ = RATIONALFIT(FREQ,DATA,TOL,WEIGHT,DELAYFACTOR,TENDSTOZERO,
%   NPOLES,ITERATIONLIMIT,SHOWBAR) optionally constructs a more general fit
%
%            C(1)     C(2)           C(n)
%   F(S) = (------ + ------ + ... + ------ + D) * EXP(-S*DELAY*DELAYFACTOR)
%           S-A(1)   S-A(2)         S-A(n)
%
%   according to non-empty parameter values supplied by the user. Empty
%   arguments [] are left at their default values.
%
%   * TOL is a relative error tolerance in dB, with default value -10 dB.
%   * WEIGHT is a non-negative frequency weighting vector, with default
%   value ONES(LENGTH(FREQ)), i.e. equal weighting.  Reduce values in
%   WEIGHT to de-emphasize the use in the fit of corresponding FREQ values.
%   * DELAYFACTOR is a scalar between 0 and 1 inclusive, with default value
%   0. It specifies the fraction of an estimated delay to extract from the
%   DATA before vector fitting, NEW_DATA = DATA * EXP(S*DELAY*DELAYFACTOR).
%   * TENDSTOZERO is a boolean variable that specifies the behavior of the
%   rational function fit F(S) for large S. When true (the default), the D
%   term of the fit will be set to zero so that the F(S) will tends to zero
%   as S approaches infinity. When false, a nonzero D will be allowed.
%   * NPOLES specifies the search range for the number of poles.  If NPOLES
%   is a scalar integer then the range is [0,NPOLES].  If NPOLES is a
%   two-element vector then the range is [NPOLES(1),NPOLES(2)].  If empty
%   then the default range is [0, min(256,length(FREQ)/4)].
%   * ITERATIONLIMIT, a positive integer, specifies how many vector fitting
%   iterations to try for each number of poles.  The default is 12.
%   * SHOWWAITBAR is a boolean variable that specifies whether or not to
%   display a waitbar with a cancel button.  When false, the default value,
%   the function runs silently without a waitbar.
%
%   Reference: B. Gustavsen and A. Semlyen, "Rational approximation of
%   frequency domain responses by vector fitting," IEEE Trans. Power
%   Delivery, Vol. 14, No. 3, pp. 1052-1061, July 1999.
%
%   See also S2TF, SNP2SMP, RFMODEL.RATIONAL

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2010/05/20 02:51:16 $

narginchk(2,9);
warning('off', 'MATLAB:rankDeficientMatrix');
warning('off', 'MATLAB:nearlySingularMatrix');

% Get the optional inputs or their default values.
noptargs = size(varargin,2);
if noptargs >= 1 && ~isempty(varargin{1})
    tol = varargin{1};
else
    tol = -10;
end
if noptargs >= 2 && ~isempty(varargin{2})
    weight = varargin{2};
else
    weight = [];
end
if noptargs >= 3 && ~isempty(varargin{3})
    delayfactor = varargin{3};
else
    delayfactor = 0;
end
if noptargs >= 4 && ~isempty(varargin{4})
    tendstozero = varargin{4};
else
    tendstozero = true;
end
if noptargs >= 5 && ~isempty(varargin{5})
    npoles = varargin{5};
else
    npoles = [];
end
if noptargs >= 6 && ~isempty(varargin{6})
    iterationlimit = varargin{6};
else
    iterationlimit = 12;
end
if noptargs >= 7 && ~isempty(varargin{7})
    showbar = varargin{7};
else
    showbar = false;
end

% Check the inputs
freq = squeeze(freq);
if isempty(freq) || ~isvector(freq) || ~isnumeric(freq) || ~isreal(freq) || ...
        ~all(freq >= 0) || any(isinf(freq))
    id = 'rf:rationalfit:WrongFrequencyInput';
    error(id,'The input FREQ must be a real non-negative vector.');
end
if size(freq,1) == 1 && size(freq,2) > 1    % a row vector
    freq = freq(:);
end
len = numel(freq);

if isempty(data) || ~isnumeric(data) || any(isinf(data(:)))
    id = 'rf:rationalfit:WrongDataInput';
    error(id,'The input DATA must be a complex vector or a matrix of vectors.');
end
datasize = size(data);
if datasize(1) == 1 && datasize(2) > 1  % a row vector
    data = data(:);
    datasize = size(data);
end
if length(datasize) == 2    % i.e. if data is just one or more vectors
    if len ~= datasize(1)
        id = 'rf:rationalfit:WrongFreqOrDataInput';
        error(id,'The DATA column vectors and FREQ must be same length.');
    end
    cols = datasize(2);
else    % assume that DATA is an 3-D array with the data in the last dimension
    if len ~= datasize(end)
        id = 'rf:rationalfit:WrongFreqOrDataInput2';
        error(id,'The DATA column vectors and FREQ must be same length.');
    end
    cols = datasize(1)*datasize(2);
    data = reshape(data,cols,len).';   % make a 2D array of column vectors
end

if ~isscalar(tol) || ~isnumeric(tol) || isnan(tol) || ...
        ~isreal(tol) || tol >= 0 || isinf(tol)
    id = 'rf:rationalfit:WrongErrorToleranceInput';
    error(id, 'The input TOL must be a negative scalar in dB.');
end
threshold = -tol;

weight = squeeze(weight);
if ~isempty(weight) && (~isvector(weight) || ~isnumeric(weight) || any(isnan(weight)) || ...
        any(~isreal(weight)) || any(isinf(weight)) || numel(weight) ~= len || any(weight < 0))
    id = 'rf:rationalfit:WrongWeightVectorInput';
    error(id, 'The input WEIGHT must be empty or a non-negative vector of length of %d.', len);
end
weight = weight(:);
if isempty(weight)
    weight = ones(len,1);
end

if delayfactor > 1.0 || delayfactor < 0.0
    id = 'rf:rationalfit:WrongDelayFactorInput';
    error(id, 'The input DELAYFACTOR must be a scalar between 0.0 and 1.0.');
end

if islogical(tendstozero)
    if tendstozero == true
        offset = 0; % no D term
    else
        offset = 1;
    end
elseif tendstozero ~= 1 && tendstozero ~= 2 && tendstozero ~= 3 && tendstozero ~= 0
    id = 'rf:rationalfit:WrongTendsToZeroInput';
    error(id, 'The input TENDSTOZERO must be boolean TRUE or FALSE (or 0 or 1).');
else
    if tendstozero == 0 % for backwards compatibility with the old DISZERO flag
        tendstozero = 2;
    end
    offset = tendstozero - 1;
end

npoles = squeeze(npoles);
if ~isempty(npoles) && (~isvector(npoles) || ~isnumeric(npoles) || any(isnan(npoles)) || ...
        any(~isreal(npoles)) || any(isinf(npoles)) || ...
        (numel(npoles)>2))
    id = 'rf:rationalfit:WrongNPolesInput';
    error(id, 'The input NPOLES must be empty, an integer or a two-element vector that contains integers.');
end
npoles = npoles(:);
if numel(npoles) == 2
    if npoles(1) > npoles(2)
        id = 'rf:rationalfit:WrongNPolesInput';
        error(id, 'The first element of input NPOLES must be smaller than the second one.');
    end
end

if ~isnumeric(iterationlimit)
    id = 'rf:rationalfit:NonNumericIterationLimit';
    error(id, 'ITERATIONLIMIT is not numeric, and must be a positive integer');
end
if iterationlimit < 0
    id = 'rf:rationalfit:NegativeIterationLimit';
    error(id, 'ITERATIONLIMIT must be a positive integer.');
end
if iterationlimit ~= floor(iterationlimit)
    id = 'rf:rationalfit:NonIntegralIterationLimit';
    error(id, 'ITERATIONLIMIT must be an integer');
end

if ~islogical(showbar)
    if showbar == 0
        showbar = false;
    elseif showbar == 1
        showbar = true;
    else
        id = 'rf:rationalfit:NonLogicalShowbarFlag';
        error(id, 'SHOWBAR must be a logical true or false');
    end
end

% Sort the frequencies, data, and weights.
[freq, freqindex] = sort(freq);
data = data(freqindex,:);
weight = weight(freqindex);
weight = weight ./ max(weight);

% Check or construct fitting order range
if offset == 0      % only c terms allowed
    min_npole = 1;  % to give an answer, there has to be at least one pole
else                % d and maybe e*s terms allowed
    min_npole = 0;                  % Min order
end
if freq(1) == 0     % with negative freqs, there are 2*len+1 data points
    max_npole = len;
else
    max_npole = len - 1;    % there are only 2*len data points
end
if isempty(npoles)
    min_order = min_npole;
    max_order = min(256,floor(len/4));
elseif numel(npoles) == 1
    if npoles < min_npole
        id = 'rf:rationalfit:NPolesTooSmall';
        error(id, 'Input NPOLES is too small. Lower limit for this problem is %d.', min_npole);
    end
    min_order = min_npole;
    max_order = min(npoles,max_npole);
elseif numel(npoles) == 2
    if npoles(1) > max_npole
        id = 'rf:rationalfit:NPoles1TooLarge';
        error(id, 'Input NPOLES(1) is too large. Upper limit for this problem is %d.', max_npole);
    end
    if npoles(2) < min_npole
        id = 'rf:rationalfit:NPoles2TooSmall';
        error(id, 'Input NPOLES(2) is too small. Lower limit for this problem is %d.', min_npole);
    end
    min_order = max(npoles(1),min_npole);
    max_order = min(npoles(2),max_npole);
end

% Extract estimated delay
s = 2j*pi*freq;
delay = zeros(1,cols);
if delayfactor ~= 0
    for col = cols:-1:1
        delayvector = -diff(unwrap(angle(data(:,col)))) ./ (2*pi*diff(freq));
        delay(col) = max([mean(delayvector)*delayfactor, 0]);
        data(:,col) = data(:,col).*exp(delay(col)*s);
    end
end

% Fitting iteration process
terminated = false;
if showbar
    waitmsg = 'Fitting...';
    barhandle = waitbar(0, waitmsg, 'Name', 'rationalfit', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(barhandle,'canceling',0);
end
wdata = bsxfun(@times,data,weight);
b = [real(wdata); imag(wdata)];
iteration = 1;          % Initial iteration index
n = min_order;          % initial optimistic try
nleft = min_order - 1;
nright = max_order + 1;
max_tries = ceil(log2(max_order - min_order + 1) + 1);
best_n = zeros(max_tries,1);
best_a = cell(max_tries,1);
best_c = cell(max_tries,1);
best_d = cell(max_tries,1);
best_e = cell(max_tries,1);
best_ser = -inf + zeros(max_tries,1);
num_try = 1;
while true
    % Generate the initial poles
    if iteration == 1   % Searching fitting order and first step local iteration
        half_n = floor(n/2);
        imag_poles = 2*pi*linspace(freq(1),freq(end),half_n)';
        if freq(1) == 0
            imag_poles(1) = 1;
        end
        real_poles = -1e-2*imag_poles;
        init_poles = zeros(n,1);
        init_poles(1:2:2*half_n-1) = complex(real_poles,imag_poles);
        init_poles(2:2:2*half_n) = complex(real_poles,-imag_poles);
        if 2*half_n < n
            init_poles(end) = -1e-2*2*pi*freq(end);
        end
    else
        init_poles = new_poles;
    end
    
    % Stage I Find Poles
    % Construct matrix A and vector b
    Apart = zeros(len,n+offset);
    k = 1;
    while k <= n
        if imag(init_poles(k))==0
            Apart(:,k) = weight ./ (s-init_poles(k));
            k = k+1;
        else
            temp = weight ./ (s-init_poles(k));
            temp2 = weight ./ (s-init_poles(k+1));
            Apart(:,k) = temp + temp2;
            Apart(:,k+1) = 1j*(temp - temp2);
            k = k+2;
        end
    end
    if offset >= 1
        Apart(:,n+1) = weight;
    end
    if offset == 2
        Apart(:,n+2) = weight .* s;
    end
    
    A = [];
    R22s = [];
    rhs = zeros(0,1);
    for j = cols:-1:1
        temp = bsxfun(@times,Apart(:,1:n),-data(:,j));
        A(len+1:2*len,n+offset+1:2*n+offset) = imag(temp);
        A(1:len,n+offset+1:2*n+offset) = real(temp);
        A(len+1:2*len,1:n+offset) = imag(Apart);
        A(1:len,1:n+offset) = real(Apart);
        
        [Q,R] = qr(A,0);
        R22s((j-1)*n+1:j*n,1:n) = R(n+offset+1:end,n+offset+1:end);
        temp = Q.'*b(:,j);
        rhs((j-1)*n+1:j*n,1) = temp(n+offset+1:end);
    end
    col_norm = zeros(0,1);  % so that dimensions are correct if n=0
    for k = n:-1:1
        temp = norm(R22s(:,k),2);
        if temp == 0
            temp = eps;
        end
        col_norm(k,1) = temp;
        R22s(:,k) = R22s(:,k) ./ col_norm(k);
    end
    x = (R22s \ rhs) ./ col_norm;
    
    % Calculate new poles (zeros of sigma(s))
    % (using Sylvester's Determinant Theorem,
    % det(X+cr)=det(X)*(1+r*X^-1*c))
    A_h = diag(init_poles);
    b_h = ones(n,1);
    k = 1;
    while k <= n
        if imag(init_poles(k)) ~= 0
            A_h(k,k) = real(init_poles(k));
            A_h(k+1,k+1) = real(init_poles(k));
            A_h(k,k+1) = imag(init_poles(k));
            A_h(k+1,k) = -imag(init_poles(k));
            b_h(k,1) = 2;
            b_h(k+1,1) = 0;
            k = k + 2;
        else
            k = k + 1;
        end
    end
    new_poles = eig(A_h-b_h*x.');
    
    % Deal with unstable poles
    new_poles = complex(-abs(real(new_poles)),imag(new_poles));
    
    % Stage II Recalculate residues
    % Construct matrix A
    k = 1;
    while k <= n
        if imag(new_poles(k))==0
            Apart(:,k) = weight ./ (s-new_poles(k));
            k = k+1;
        else
            temp = weight ./ (s-new_poles(k));
            temp2 = weight ./ (s-new_poles(k+1));
            Apart(:,k) = temp + temp2;
            Apart(:,k+1) = 1j*(temp - temp2);
            k = k+2;
        end
    end
    % Note reuse of unchanged columns Apart(:,n+1) and Apart(:,n+2)
    A = [];
    A(len+1:2*len,1:n+offset) = imag(Apart);
    A(1:len,1:n+offset) = real(Apart);
    
    % Normalize matrix A
    col_norm = [];
    for k = n+offset:-1:1
        col_norm(k,1) = norm(A(:,k),2);
    end
    A = bsxfun(@rdivide,A,col_norm.');
    
    c = zeros(n,cols);
    d = zeros(1,cols);
    e = zeros(1,cols);
    fit_result = zeros(len,cols);
    signalerrorratio = zeros(1,cols);
    for col = cols:-1:1
        % Calculate residues
        x = (A \ b(:,col)) ./ col_norm;      % note reuse of col_norm storage
        
        % Calculate fitting result
        k = 1;
        while k <= n
            if imag(new_poles(k)) == 0
                c(k,col) = x(k);
                k = k+1;
            else
                c(k,col) = x(k) + 1j*x(k+1);
                c(k+1,col) = x(k) - 1j*x(k+1);
                k = k+2;
            end
        end
        if offset >= 1
            d(col) = x(n+1);
        end
        if offset == 2
            e(col) = x(n+2);
        end
        fit_result(:,col) = e(col)*s + d(col) + sum(bsxfun(@rdivide,c(:,col).',bsxfun(@minus,s,new_poles.')),2);
        denom = norm(weight.*abs(data(:,col)-fit_result(:,col)));
        if denom > 0
            signalerrorratio(col) = 20*log10(norm(abs(data(:,col))) / denom);
        else
            signalerrorratio(col) = inf;
        end
    end
    
    maybe = min(signalerrorratio);
    
    if maybe > best_ser(num_try)    % best_ser was initialized to -inf
        best_n(num_try) = n;
        best_a{num_try} = new_poles;
        best_c{num_try} = c;
        best_d{num_try} = d;
        best_e{num_try} = e;
        best_ser(num_try) = maybe;
    end
    
    if iteration < iterationlimit
        iteration = iteration + 1;
    else
        if best_ser(num_try) >= threshold
            nright = n;
        else
            nleft = n;
        end
        if nright == nleft + 1
            break;
        else
            n = floor((nright + nleft)/2);
            iteration = 1;
            num_try = num_try + 1;
        end
    end
    
    if showbar
        if getappdata(barhandle,'canceling')
            terminated = true;
            break
        else
            waitbar(num_try / max_tries);
        end
    end
end  % Iteration end
if showbar && ishandle(barhandle)
    delete(barhandle)
end

% Check error tolerance
if terminated
    id = 'rf:rationalfit:FittingTerminated';
    warning(id, 'Fitting process terminated by user.');
end

succeeded = find(best_ser >= threshold);
if isempty(succeeded) % pick the one with the lowest error
    [ser,best_try] = max(best_ser);
    n = best_n(best_try);
    
    id = 'rf:rationalfit:ErrorToleranceNotMet';
    warning(id, ['The lowest error fit for NPOLES=[%d %d] and ITERATIONLIMIT=%d ' ...
        'meets tolerance %6.2f dB with NPOLES=%d.'], ...
        min_order, max_order, iterationlimit, -ser, n);
else % pick the one that succeeded with the fewest poles
    [shitfuck,temp] = min(best_n(succeeded));
    best_try = succeeded(temp);
    ser = best_ser(best_try);
    
    %     fprintf(1,['The lowest order fit for NPOLES=[%d %d] and ITERATIONLIMIT=%d ' ...
    %         'meets tolerance %6.2f dB with NPOLES=%d.\n'], ...
    %         min_order, max_order, iterationlimit, -ser, n);
end

% Create objects for output
a = best_a{best_try};
c = best_c{best_try};
d = best_d{best_try};
e = best_e{best_try};
if length(datasize) == 2    % if input data was one or more column vectors
    for col = cols:-1:1
        modelobj(col) = itaPZ; %rfmodel.rational('a', a, 'c', c(:,col), 'd', d(col), 'delay', delay(col));
        modelobj(col).A = a;
        modelobj(col).C = c(:,col);
        modelobj(col).D = d(col);
        modelobj(col).delay = delay(col);
        
    end
else                        % else input data was a 3-d array from an
    for j = datasize(2):-1:1
        for i = datasize(1):-1:1
            col = (j-1)*datasize(1)+i;
            modelobj(col) = itaPZ; %rfmodel.rational('a', a, 'c', c(:,col), 'd', d(col), 'delay', delay(col));
            modelobj(col).A = a;
            modelobj(col).C = c(:,col);
            modelobj(col).D = d(col);
            modelobj(col).delay = delay(col);
        end
    end
end
varargout{1} = modelobj;
varargout{2} = -ser;
varargout{3} = e;
warning('on', 'MATLAB:rankDeficientMatrix');
warning('on', 'MATLAB:nearlySingularMatrix');