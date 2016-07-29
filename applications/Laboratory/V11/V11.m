%% V11 - Dispersion - Acoustic Laboratory 
% Author: Pascal Dietrich - August 2011

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


ccx

%% Measurement Setup
MS = ita_measurement_setup_signals(1:2,17,[0 0]);

%%
N = 10;
% ss = cell( 1 , N );
% for idx = 1 : N
%      pause
%      disp( num2str(idx))
   
    s0 = MS.run;
    

    figure;
    plot( s0 ); 
%     figure;
    
%     s1 = ita_time_shift( s0 , '-30dB' );
%      plot( s1 )
%      ss{ idx } = s0;
     
  
% end


%%  time windowing 

% for idx = 1 : N;
%     plot( ss{ idx })
%     pause
% end

% s1 = ita_time_window( s0 ,[ 0.62 0.65 ],'time');

% s1 = ita_time_window( s0 ,[ 0.62 0.65 ],'time');
s1 = ita_time_window( s0 ,[ 0 0.02 0 -0.01 ] , 'time','adaptive');
% test = c.ch(2) / c.ch(1)
% test.plot_spkgdelay


%%  calculate the group velocity


    a = 0.005;
    
    E = 105e9;
    
    rou = 8600;
    
    B = a^2/4*E
    
    
    f = s1.freqVector;
    
    w = 2.*pi .* f;
    
    c_ph_theoretical =  sqrt( w ) .* ( B ./ rou )^(1/4);
    
    
%     c_gr =  2 .* c_ph;
    
    c_gr_theoretical = 2 .* c_ph_theoretical;



%%
 

%   s0_a = ita_generate( 'impulse' , 1 , 44100 , 15 );
%   s0_a = ita_time_shift( s0_a, 0.1 ,'time')  
%   s0_b = ita_time_shift( s0_a, 0.2 ,'time')
%   
%   s1 = ita_merge( s0_a , s0_b );



   ch1_freq = s1.freqData( : , 1 );
   ch2_freq = s1.freqData( : , 2 );
  
  
   phase_delay_angle =   unwrap ( angle( s1.freqData ) );
   
   
   
   delta_angle = phase_delay_angle( : , 1 ) - phase_delay_angle( : ,2 );
   
   
   delta_t = delta_angle ./ ( 2.*pi.* s1.freqVector );
   
   
   x = 0.82;
%    plot( s1.freqVector , delta_t );  title(' Delta  t ') ; 
   
   c_ph_measure =  x./( delta_t );
   
   c_gr_meassure = 2 .* c_ph_measure;
   
%    c_gr_measure_all( : , idx ) = c_gr_meassure;
   
%    plot( s1.freqVector , phase_delay_angle ); title('phase delay angle')
    
   figure;
   subplot( 2 ,1 , 1 )
   plot( s1.freqVector ,[ c_ph_measure , c_ph_theoretical ] ); title(  'velocity' );
   
    xlabel( ' Frequency / Hz ') ; ylabel( ' Phase Velocity / ( M/sec ) ')
    legend(  ' measurement' , 'theoretical velocity' )
     xlim( [ 200 , 10000 ] ); grid on;
%    hold on;   
%   
%    plot( s1.freqVector , c_gr_theoretical ,'r' );
%    
   
   subplot( 2 , 1 , 2 );
   plot(  s1 );  
   legend(  'CH1' , 'CH2' )
   
   