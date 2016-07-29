classdef itaSphericalLoudspeakerThieleSmall < itaSphericalLoudspeaker

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    
    properties(Constant)
        M = 11.6;
        n = 230e-6;
        m = 8.9e-3;
        w = 1.6;
        Re = 12.3;
        Le = 375e-6;
    end
    
    methods
        function this = itaSphericalLoudspeakerThieleSmall(varargin) %Constructor
            this = this@itaSphericalLoudspeaker(varargin{:});                    
        end
        
        function volt = velocity2voltage(this, vel)
            % see ActaAcustica Paper, Vol. 95 (2009) 1082 - 1092
            % (Variable Directivity for Platonic Sound Sources
            % Based on Spherical Harmonics Optimization)
                         
            omega = 2 * pi * vel.freqVector;
            % electrical impedance
            Ze = this.Re + j*omega*this.Le;
            % mechanical impedance
            Zm = this.w + j*omega*this.m + 1./(j*omega*this.n);
            
            % radius of dodecahedron
            a = this.r(1);
            r_mem = this.r_mem;
            if numel(r_mem) ~= 1
                disp('r_mem is supposed to be set to a scalar value');
            end
            
            Sd = r_mem.^2 * pi;
            c = this.m_c0;
            
            % volume of single compartment
            V0 = 4/3*pi*a^3 / vel.nChannels;
            % compliance of enclosed air volume
            ng = V0 / (this.m_rho0 * c.^2 .* Sd.^2);
            
            k = omega ./ c;
            
            % surface velocity in SH coefs [nBins x nSH]
            velSH = vel.freq * this.apertureSH.';
            % pressure on surface in SH coefs [nBins x nSH]
            pressureFactor = this.pressureFactor(k,a);
            pressSH = pressureFactor .* velSH;
            
            Fn_out = a^2 * pressSH * conj(this.apertureSH);
            Fn_in = -bsxfun(@times,vel.freq,1./(j*omega*ng));
            
            Fn = bsxfun(@plus, Fn_out, -Fn_in);
            
            % apply Eq.18 to get the required input voltages
            voltFreq = bsxfun(@times, (this.M + (Ze .* Zm)./this.M), ...
                bsxfun(@plus, vel.freq, bsxfun(@rdivide, Fn, (Zm./this.M + this.M./Ze))));
            % convert to itaAudio
            volt = itaAudio(voltFreq,vel.samplingRate,'freq');
            % apply a large bandpass filter
%             voltFiltered = ita_mpb_filter(volt,[200 16000]);%,'zerophase');
%             voltFiltered = volt;
%             voltFiltered.freq(1,:) = 0;
            
        end
    end
end
