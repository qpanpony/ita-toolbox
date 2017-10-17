%
%  OpenDAFF - A free, open-source software package for directional audio data,
%  OpenDAFF is distributed under the terms of the GNU Lesser Public License (LGPL)
% 
%  Copyright (C) Institute of Technical Acoustics, RWTH Aachen University
%
%  Visit the OpenDAFF homepage: http://www.opendaff.org
%
%  -------------------------------------------------------------------------------
%
%  File:    daff_create_dataset.m
%  Purpose: Creates an empty DAFF dataset
%  Author:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


function [ dataset ] = daffv15_create_dataset( varargin )
%DAFF_WRITE Creates an empty DAFF dataset
%
%  This function creates an empty DAFF dataset.
%  You must specify the number of channels and
%  the resolution/number of points of the spherical grid.
%  All angles are refer to degree [�].
%
%  --= Parameters =--
%     
%  channels     int         Number of channels             
%
%  alphares     float       Resolution of alpha-angles
%  betares      float       Resolution of beta-angles
%  alphapoints  int         Number of points over the alpha-range
%  betapoints   int         Number of points over the beta-range
%  alpharange   vector-2    Range of alpha-angles [start end]
%  betarange    vector-2    Range of beta-angles [start end]
%
%  quiet        none        Suppress information and warning messages
%

    % --= Option definitions =--
   
    % Options with integer number > 0 arguments
    ingzarg = {'alphapoints', 'betapoints', 'channels'};
    
    % Options with floating point number >= 0 arguments
    pfloatarg = {'alphares', 'betares'};

    floatvecarg = {'alpharange', 'betarange'};
             
    % Options with one argument
    onearg = [ingzarg pfloatarg floatvecarg];

	% Options without an argument
    nonarg = {'quiet'};
	
    % +------------------------------------------------+
    % |                                                |
    % |   Parsing and validation of input parameters   |
    % |                                                |
    % +------------------------------------------------+
    
    % Parse the arguments
    args = struct();
    for i=1:length(nonarg), args.(nonarg{i}) = false; end

    i=1;
    while i<=nargin
        if ~ischar(varargin{i}), error(['Parameter ' num2str(i) ': String expected']); end
        key = lower(varargin{i});
        i = i+1;
        r = nargin-i+1; % Number of remaining arguments
        
        switch key
		% Flag options without argument
        case nonarg
            args.(key) = true;
			
        % Options with one argument
        case onearg
            if (r < 1), error(['Option ''' key ''' requires an argument']); end
            args.(key) = varargin{i};
            i = i+1;
            
        otherwise
            error(['Invalid option (''' key ''')']);
        end        
    end
    
    % Validate the arguments
        
    for i=1:length(ingzarg)
        key = ingzarg{i};
        if isfield(args, key)
            if (~isscalar(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)) || (ceil(args.(key)) ~= args.(key)) || (args.(key) <= 0))
                error(['Argument for option ''' key ''' must be an integer > 0']);
            else
                % Type cast
                args.(key) = int32( args.(key) );
            end
        end
    end
   
    for i=1:length(pfloatarg)
        key = pfloatarg{i};
        if isfield(args, key)
            if (~isscalar(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)) || (args.(key) < 0))
                error(['Argument for option ''' key ''' must be a non-negative real number']);
            else
                % Type cast
                args.(key) = double( args.(key) );
            end
        end
    end
    
    for i=1:length(floatvecarg)
        key = floatvecarg{i};
        if isfield(args, key)
            if (~isvector(args.(key)) || ~any(isfinite(args.(key))) || ~isreal(args.(key)))
                error(['Argument for option ''' key ''' must be a vector of real numbers']);
            else
                % Type cast
                args.(key) = double( args.(key) );
            end
        end
    end
    
    % More validation
   
    % Number of channels
    if (~isfield(args, 'channels'))
        error('You must specify ''channels''');
    end
    
    % Angular ranges default values
    if (~isfield(args, 'alpharange')), args.alpharange = [0 360]; end
    if (~isfield(args, 'betarange')), args.betarange = [0 180]; end
       
    % Check range definitions
    if (length(args.alpharange) ~= 2)
        error('Argument for ''alpharange'' must be a two element vector');
    end
    
    if (length(args.betarange) ~= 2)
        error('Argument for ''betarange'' must be a two element vector');
    end
    
    % Correct angular range ordering
    alphastart = args.alpharange(1);
    alphaend = args.alpharange(2);
    betastart = min(args.betarange);
    betaend = max(args.betarange);
    
    if ((alphastart < 0) || (alphastart > 360))
        error('Alpha range values must lie within the interval [0, 360]');
    end
    
    if ((betastart < 0) || (betastart > 180))
        error('Beta range values must lie within the interval [0, 180]');
    end
    
    if (alphastart > alphaend)
        alphaspan = 360 - alphastart + alphaend;
    else
        alphaspan = alphaend - alphastart;
    end
    
    betaspan = betaend - betastart;
    
    % Alpha points and resolution
    if (~isfield(args, 'alphapoints') && ~isfield(args, 'alphares'))
        error('You must specify ''alphapoints'' or ''alphares''');
    end
    
    if (isfield(args, 'alphapoints') && isfield(args, 'alphares'))
        error('Specify either ''alphapoints'' or ''alphares'', but not both');
    end
    
    if isfield(args, 'alphares')
        
        % [fwe] Bugfix 2011-07-05
        % If the azimuth span does not wrap around the whole sphere
        % we need to add another point. Otherwise there will be no
        % point at alphaend. Moreover we need to cast to double
        % explicitly, otherwise the division is evaluated in integers.
        
        if (alphaspan == 360)
            % Full alpha coverage
            % Last point of the interval (360�) coincides with the first (0�)
            args.alphapoints = alphaspan / double( args.alphares );
        else
            % Partial alpha coverage
            % First and last point do not coincide.
            % Therefore the last point is within the span
            args.alphapoints = round(alphaspan / double( args.alphares ) + 1);
        end  
      
        if (ceil(args.alphapoints) ~= args.alphapoints)
            error('Alpha range and alpha resolution are not an integer multiple')
        end
       
    else
        % [fwe] Bugfix 2011-07-05 (see above)
        if (alphaspan == 360)
            args.alphares = alphaspan / double( args.alphapoints );
        else
            args.alphares = alphaspan / double( args.alphapoints - 1 );
        end
    end
   
    % Beta points and resolution
    if (~isfield(args, 'betapoints') && ~isfield(args, 'betares'))
        error('You must specify ''betapoints'' or ''betares''');
    end
    
    if (isfield(args, 'betapoints') && isfield(args, 'betares'))
        error('Specify either ''betapoints'' or ''betares'', but not both');
    end
    
    if isfield(args, 'betares')
        % [fwe] Bugfix 2011-07-05
        % We need to cast to double explicitly, otherwise
        % the division is evaluated in integers.
        
        args.betapoints = (betaspan / double( args.betares )) + 1;
        if (ceil(args.betapoints) ~= round(args.betapoints))
            error('Beta range and beta resolution are not an integer multiple')
        end
    else
        args.betares = betaspan / double( args.betapoints-1 );
    end
    
    % +------------------------------------------------+
    % |                                                |
    % |   Creation of the dataset                      |
    % |                                                |
    % +------------------------------------------------+
      
    % Count the number of records
    % (Important: just one record at the poles)
    args.betapoints = round(args.betapoints);
    numRecords = args.alphapoints * args.betapoints;
    if (betastart == 0), numRecords = numRecords - args.alphapoints + 1; end;
    if (betaend == 180), numRecords = numRecords - args.alphapoints + 1; end;

    % Create the cell array and insert the data
    dataset.channels = args.channels;
    dataset.alphapoints = args.alphapoints;
    dataset.alphares = args.alphares;
    dataset.alpharange = [alphastart alphaend];
    dataset.betapoints = args.betapoints;
    dataset.betares = args.betares;
    dataset.betarange = [betastart betaend];
    dataset.numrecords = numRecords;    
    dataset.records = cell(1, numRecords);  % Empty record matrices
    dataset.metadata = struct;              % Empty metadata
    
	% Iteration over both angular dimensions
    i = 1;
    for b=1:args.betapoints
        beta = double( betastart + (b-1)*args.betares );
        
		% Note: Here we compute normalized area weights for each point.
		% The area weight is the normalized surface area of the equivalent
		% Voronoi cell of the point. For equiangular lattitude-longitude
		% sphere grids, we can compute it using the surface area of a
		% band spanning around the sphere, which is determined by a
		% elevation (beta) angle span. Normalized means, the area weights
		% of all points sum up to 1.
		
        % Important: just one record at the poles
        if ((beta == 0) || (beta == 180))
            points = 1;
            
            % Area weight: Pole cap with aperture of betares/2
            % Note: Including normalization by 1/4pi
            weight = (1-cos(dataset.betares/2 * pi/180))/2;
        else
            points = args.alphapoints;
            
            % Area weight: Sphere ring divided by the number of tiles
            % Note: Including normalization by 1/4pi
            weight = (cos((beta-dataset.betares/2) * pi/180) - cos((beta+dataset.betares/2) * pi/180))/(2*dataset.alphapoints);
        end
        
        for a=1:points
            alpha = mod( double( alphastart + (a-1)*args.alphares ), 360.0);

            % DEBUG: fprintf('Record %d (A%0.1f�, B%0.1f�)\n', i, alpha, beta);
            dataset.records{i}.alpha = alpha;
            dataset.records{i}.beta = beta;
            dataset.records{i}.data = [];				% Empty data matrix
            dataset.records{i}.metadata = struct;		% Empty metadata struct
            dataset.records{i}.areaweight = weight;		% Normalized area weight
            
            i = i + 1;
        end
    end    

	if (~args.quiet)
		% Print a summary of the information
		fprintf('--= DAFF dataset summary =--------------------------\n\n');
		fprintf('  Num channels:      \t%d\n', args.channels);
		fprintf('  Num alpha points:  \t%d\n', args.alphapoints);
		fprintf('  Alpha range:       \t[%0.3f�, %0.3f�]\n', alphastart, alphaend);
		fprintf('  Alpha resolution:  \t%0.3f�\n', args.alphares);
		fprintf('  Num beta points:   \t%d\n', args.betapoints);
		fprintf('  Beta range:        \t[%0.3f�, %0.3f�]\n', betastart, betaend);
		fprintf('  Beta resolution:   \t%0.3f�\n', args.betares);
		fprintf('  Num records:       \t%d\n', numRecords); 
        fprintf('\n----------------------------------------------------\n\n');
	end
end
