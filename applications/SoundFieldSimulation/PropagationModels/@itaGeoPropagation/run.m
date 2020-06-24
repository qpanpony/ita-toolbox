function [ freq_data_linear ] = run( obj )
%RUN Calculates the transfer function (tf) of the superimposed (geometrical) propagation path in frequency domain

freq_data_linear = ones( obj.num_bins, 1 );

% Iterate over propagation paths, calculate transfer function and sum up
for n = 1:numel( obj.pps )

    pp = obj.pps( n );
    pp_tf = obj.tf( pp );
	freq_data_linear = freq_data_linear + pp_tf;
            
end

end
