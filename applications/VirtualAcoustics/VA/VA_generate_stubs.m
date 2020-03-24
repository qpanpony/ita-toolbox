% Stub generator for the VA Matlab facade class
% Author: Frank Wefers (fwefers@akustik.rwth-aachen.de)

function [output] = VA_generate_stubs()
    % Get interface describtion
    d = VAMatlab('enumerate_functions');

    code = '';
    for i=1:length(d)
        % Concatenate the input and output argument lists
        inargs = '';
        ninargs = length(d(i).inargs);
        for j=1:ninargs
            if (j>1) inargs = strcat(inargs, ', '); end
            inargs = strcat(inargs, sprintf('%s', d(i).inargs(j).name));
        end    

        outargs = '';
        noutargs = length(d(i).outargs);
        for j=1:noutargs
            if (j>1) outargs = strcat(outargs, ', '); end
            outargs = strcat(outargs, sprintf('%s', d(i).outargs(j).name));
        end
        
        if ninargs > 0
            code = [code sprintf('\tfunction [%s] = %s(this, %s)\n', outargs, d(i).name, inargs)];
        else
            code = [code sprintf('\tfunction [%s] = %s(this)\n', outargs, d(i).name)];
        end
        code = [code sprintf('\t\t%% %s\n', d(i).desc)];

        % Argument and return value documentation
        code = [code sprintf('\t\t%%\n\t\t%% Parameters:\n\t\t%%\n')];
        if (ninargs == 0)
            code = [code sprintf('\t\t%% \tNone\n')];
        else
            for j=1:ninargs
                if (d(i).inargs(j).optional)
                    code = [code sprintf('\t\t%% \t%s [%s] %s (optional, default: %s)\n', ...
                            d(i).inargs(j).name, ...
                            d(i).inargs(j).type, ...
                            d(i).inargs(j).desc, ...
                            d(i).inargs(j).default)];
                else
                    code = [code sprintf('\t\t%% \t%s [%s] %s\n', ...
                            d(i).inargs(j).name, ...
                            d(i).inargs(j).type, ...
                            d(i).inargs(j).desc)];      
                end
            end
        end

        code = [code sprintf('\t\t%%\n\t\t%% Return values:\n\t\t%%\n')];
        if (noutargs == 0)
            code = [code sprintf('\t\t%% \tNone\n')];
        else
            for j=1:noutargs
                code = [code sprintf('\t\t%% \t%s [%s] %s\n', ...
                        d(i).outargs(j).name, ...
                        d(i).outargs(j).type, ...
                        d(i).outargs(j).desc)];      
            end
        end

        code = [code sprintf('\t\t%%\n\n')];

        % Matlab code that checks that a connection is established
        code = [code sprintf('\t\tif this.handle==0, error(''Not connected.''); end\n\n')];
        
        % Matlab code for default values in optional input parameters
        for j=1:ninargs
            if (d(i).inargs(j).optional)
                code = [code sprintf('\t\tif ~exist(''%s'',''var''), %s = %s; end\n', ...
                        d(i).inargs(j).name, d(i).inargs(j).name, d(i).inargs(j).default)];
            end
        end

        % Matlab code calling the MEX
        if (noutargs > 0)
            if (ninargs > 0)
                code = [code sprintf('\t\t[%s] = VAMatlab(''%s'', this.handle, %s);\n', outargs, d(i).name, inargs)];
            else
                code = [code sprintf('\t\t[%s] = VAMatlab(''%s'', this.handle);\n', outargs, d(i).name)];
            end
        else
            if (ninargs > 0)
                code = [code sprintf('\t\tVAMatlab(''%s'', this.handle, %s);\n', d(i).name, inargs)];
            else
                code = [code sprintf('\t\tVAMatlab(''%s'', this.handle);\n', d(i).name)];
            end
        end

        code = [code sprintf('\tend\n\n')];
    end
    
    output = code;
end