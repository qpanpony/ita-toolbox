classdef itaMSTFdummy < itaMSTF
    % This is a class to simulate Transfer Function or Impulse Response
    % measurements including transfer function, quantization, background
    % noise and nonlinearities.
    %
    % See also: itaMSTF
    
    % <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
  
    
    properties
        noiselevel              = []; % noise level in dBFS
        systemresponse          = []; % impulse response as itaAudio
        presystemresponse       = []; % impulse response before non-linearities
        nonlinearCoefficients   = 1; %coefficients for x^0 x^1 x^2...
        limitValue              = inf;
        
    end
    
    methods
        
        function this = itaMSTFdummy
            %constructor
            % do not use this to be able to include measurement chain
%             this.inputChannels  = 1;
%             this.outputChannels = 1;
        end
        
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            
            %% prepare for measurement
            result = this.final_excitation;
            
            %% quantize
            if ~isempty(this.nBits) && (this.nBits(1) ~= 0)
                %                 interval = 2^(this.nBits(1)-1)+1;
                delta = 2 / 2.^this.nBits(1);
                interval = 1/delta;
                % Dithering
                %                 result = ita_dither(result,'nBits',this.nBits(1),'type',this.ditherType);
                %                 result.timeData = (round(result.timeData.*interval./2-0.5)+0.5) ./interval.*2;
                result.timeData = (round(result.timeData.*interval./2-0.5)+0.5) ./interval.*2;
                
            end
            
            %% add pre system response
            if ~isempty(this.presystemresponse)
                nSamples = result.nSamples;
                result = ita_convolve(result,this.presystemresponse);
                result.nSamples = nSamples;
            end
            
            %% add nonlinearities
            if exist('ita_nonlinear_power_series.m','file')
                result = ita_nonlinear_power_series(result,this.nonlinearCoefficients);
                if this.filter && numel(this.nonlinearCoefficients) > 1
                   result = ita_mpb_filter(result,[this.freqRange(1),0]);
                end
            end
            
            %% limiter
            result = ita_nonlinear_limiter(result,this.limitValue);
            
            %% add system response
            if ~isempty(this.systemresponse)
                nSamples = result.nSamples;
                result = ita_convolve(result,this.systemresponse);
                result.nSamples = nSamples;
            end
            
            %% add noise
            if ~isempty(this.noiselevel)
                awgn   = 10^(this.noiselevel / 20) * ita_generate('noise', 1, this.samplingRate, result.nSamples); % Additive measurement noise
                result = result + awgn;
            end
            
            %% add impulsive noise
            %             %% add impulse
            %             start = round(rand(1) * result.nSamples);
            %             result.time(start) = 1;
            
            %% quantize
            if ~isempty(this.nBits) && (this.nBits(end) ~= 0)
                interval = 2^(this.nBits(end)-1)+1; %use last nBits for input quantization
                result.timeData = round(result.timeData.*interval./2 - 0.5)./interval.*2;
            end
            
            %% get max level
            max_rec_lvl = max(abs(result.timeData),[],1);
            
            %% replicate channels
            if numel(this.inputChannels > 1)
                
            end
            
        end
        
    end
    
end