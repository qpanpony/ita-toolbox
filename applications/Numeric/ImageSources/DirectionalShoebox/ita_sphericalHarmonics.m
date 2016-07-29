function Y_NMxQ = ita_sphericalHarmonics(base, N, Q_points_theta_grid, Q_points_phi_grid)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

theta = Q_points_theta_grid;
phi = Q_points_phi_grid;
j=sqrt(-1);

Q = length(theta);
theta = reshape(theta,1,[]);
phi = reshape(phi,1,[]);     

Yn0 = sqrt(1/(4*pi))*ones(1,Q);

Y = Yn0;
switch lower(base)
    case {'williams','complex'}
    for n=1:N,
        for m=0:n,
            norm_coeff_1xN(m+1) = sqrt( ((2*n+1)/(4*pi)) * factorial(n-m) / factorial(n+m) );
        end;
        norm_coeff_Nx1 = reshape(norm_coeff_1xN,[],1);
        norm_coeff_NxQ = repmat(norm_coeff_Nx1,1,Q);

        m=[0:n]';
        Ynm_positive = norm_coeff_NxQ .* legendre(n,cos(theta)) .* exp(j*m*phi) ;
            
        m=[-n:-1]';
        Ynm_negative = repmat((-1).^m,1,Q) .* conj(Ynm_positive(end:-1:2,:));
                
        Y = [Y; Ynm_negative; Ynm_positive];
    end
    case {'real','raven','zotter_dis'}
    for n=1:N,
        norm_coeff_1xN(1) = sqrt( (2*n+1)/(4*pi) );
        for m=1:n,
            norm_coeff_1xN(m+1) = (-1)^m * sqrt( (2*n+1) / (2*pi) * factorial(n-m) / factorial(n+m) );
        end;
        norm_coeff_Nx1 = reshape(norm_coeff_1xN,[],1);
        norm_coeff_NxQ = repmat(norm_coeff_Nx1,1,Q);

        m=[0:n]';
        theta_term = legendre(n,cos(theta));
        phi_term = cos(m*phi);

        norm_coeff_x_theta_term_NxQ = norm_coeff_NxQ .* theta_term;

        Ynm_positive = norm_coeff_x_theta_term_NxQ .* phi_term;
            
        m=[-n:-1]';
        switch base
        case {'raven'}
            phi_term = sin(-m*phi);
        case {'real','zotter_dis'}
            phi_term = sin(m*phi) ;
        end
        Ynm_negative = norm_coeff_x_theta_term_NxQ(end:-1:2,:) .* phi_term;
                
        Y = [Y; Ynm_negative; Ynm_positive];
    end
end

Y_NMxQ = Y;
