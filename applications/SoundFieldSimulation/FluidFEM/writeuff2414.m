function writeuff2414(varargin)
% The function writes a *.unv file Function gets the filename (unvFilename)
% as a string and the nodes, the real part and the imaginary part of the
% pressure as a struct.
% - k und i anpassen

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
%--------------------------------------------------------------------------
% Number of Input Arguments
narginchk(2,3);
% Find Data
if isstruct(varargin{2})
    Data = varargin{2};
    if ischar(varargin{1})
        unvFilename = varargin{1};
    else
        error('writeuff2414::Something is wrong with the filename.')
    end
else
    error('writeuff2414::Second argument has to be a struct.')
end

%% Body
nodes  = Data.nodes(:);
p_real = Data.p_real(:);
p_imag = Data.p_imag;
freq   = Data.freq(:);
Type   = Data.Type;

space  = '         ';
zeroString = '0.0000E+000';
format      = '%1.4E';

freqStr     = num2str(freq(:),format);          
DataSetName = num2str(freq(:));             % Pressure @ frequency
DataSetLoc  = '1';                          % Data @ nodes
ModelType   = '0';                          % 0 = unknown
AnalysisType= '5';                          % 5 = frequency response
DataCharact = '1';                          % 1 = scalar
ResultType  = '301';                        % 301 = Sound pressure
DataType    = '5';                          % 5 = Single precision complex
DataValue   = '1';                      
realStr     = num2str(p_real(:),format);
imagStr     = num2str(p_imag(:),format);
nodesStr    = num2str(nodes(:));

fid = fopen(unvFilename,'at');
if fid ~= -1
    for i=1:numel(freq)
        fprintf(fid,'%s\n','    -1');               % delimiter
        fprintf(fid,'%s\n','  2414');               % dataset
        fprintf(fid,'%s\n',['         ' DataSetName(i,:)]);  % frequency bin
        fprintf(fid,'%s\n', ['P at ' DataSetName(i,:)  'Hz']); % analysis dataset name
        fprintf(fid,'%s\n',['         ' DataSetLoc]);             % dataset location, 1 = Data at nodes
        fprintf(fid,'%s\n',['MatlabSolve results: ' Type]);    % ID
        fprintf(fid,'%s\n','NONE'); % ID
        fprintf(fid,'%s\n','NONE'); % ID
        fprintf(fid,'%s\n','NONE'); % ID
        fprintf(fid,'%s\n','NONE'); % ID
        fprintf(fid,'%s\n', ['         ' ModelType space AnalysisType space DataCharact '       ' ResultType space DataType space DataValue]); 
        fprintf(fid,'%s\n','         0         0         0         0         0         0         0         1');
        fprintf(fid,'%s\n','         0         0');
        fprintf(fid,'%s\n',['  ' zeroString '  '  freqStr(i,:) '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
        fprintf(fid,'%s\n',['  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString '  ' zeroString]);
        for k=1:numel(nodes)
            fprintf(fid,'%s\n',['         ' nodesStr(k,:)]);
            fprintf(fid,'%s\n',['  ' realStr(k,:) '  ' imagStr(k,:)]);
        end
    end
    fprintf(fid,'%s\n','    -1');
    fclose(fid);
else
    error('writeuff2414::cannot create file');
end

%end function
end