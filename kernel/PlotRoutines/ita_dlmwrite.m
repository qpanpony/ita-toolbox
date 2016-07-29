function ita_dlmwrite(filename, m, varargin)
%DLMWRITE Write ASCII delimited file.
%
%   DLMWRITE('FILENAME',M) writes matrix M into FILENAME using ',' as the
%   delimiter to separate matrix elements.
%
%   DLMWRITE('FILENAME',M,'DLM') writes matrix M into FILENAME using the
%   character DLM as the delimiter.
%
%   DLMWRITE('FILENAME',M,'DLM',R,C) writes matrix M starting at
%   offset row R, and offset column C in the file.  R and C are zero-based,
%   so that R=C=0 specifies the first value in the file.
%
%   DLMWRITE('FILENAME',M,'ATTRIBUTE1','VALUE1','ATTRIBUTE2','VALUE2'...)
%   An alternative calling syntax that uses attribute value pairs for
%   specifying optional arguments to DLMWRITE. The order of the
%   attribute-value pairs does not matter, as long as an appropriate value
%   follows each attribute tag.
%
%	DLMWRITE('FILENAME',M,'-append')  appends the matrix to the file.
%	without the flag, DLMWRITE overwrites any existing file.
%
%	DLMWRITE('FILENAME',M,'-append','ATTRIBUTE1','VALUE1',...)
%	Is the same as the previous syntax, but accepts attribute value pairs,
%	as well as the '-append' flag.  The flag can be placed in the argument
%	list anywhere between attribute value pairs, but not between an
%	attribute and its value.
%
%   USER CONFIGURABLE OPTIONS
%
%   ATTRIBUTE : a quoted string defining an Attribute tag. The following
%               attribute tags are valid -
%       'delimiter' =>  Delimiter string to be used in separating matrix
%                       elements.
%       'newline'   =>  'pc' Use CR/LF as line terminator
%                       'unix' Use LF as line terminator
%       'roffset'   =>  Zero-based offset, in rows, from the top of the
%                       destination file to where the data it to be
%                       written.
%       'coffset'   =>  Zero-based offset, in columns, from the left side
%                       of the destination file to where the data is to be
%                       written.
%       'precision' =>  Numeric precision to use in writing data to the
%                       file, as significant digits or a C-style format
%                       string, starting with '%', such as '%10.5f'.  Note
%                       that this uses the operating system standard
%                       library to truncate the number.
%
%   NOTE:
%
%   DLMWRITE does not accept cell arrays for the input matrix M. To
%   export cell arrays to a text file, use low-level functions such as
%   FPRINTF.
%
%   EXAMPLES:
%
%   DLMWRITE('abc.dat',M,'delimiter',';','roffset',5,'coffset',6,...
%   'precision',4) writes matrix M to row offset 5, column offset 6, in
%   file abc.dat using ; as the delimiter between matrix elements.  The
%   numeric precision is of the data is set to 4 significant decimal
%   digits.
%
%   DLMWRITE('example.dat',M,'-append') appends matrix M to the end of
%   the file example.dat. By default append mode is off, i.e. DLMWRITE
%   overwrites the existing file.
%
%   DLMWRITE('data.dat',M,'delimiter','\t','precision',6) writes M to file
%   'data.dat' with elements delimited by the tab character, using a precision
%   of 6 significant digits.
%
%   DLMWRITE('file.txt',M,'delimiter','\t','precision','%.6f') writes M
%   to file file.txt with elements delimited by the tab character, using a
%   precision of 6 decimal places.
%
%   DLMWRITE('example2.dat',M,'newline','pc') writes M to file
%   example2.dat, using the conventional line terminator for the PC
%   platform.
%
%   See also DLMREAD, CSVWRITE, NUM2STR, SPRINTF.

%   Brian M. Bourgault 10/22/93
%   Modified: JP Barnard, 26 September 2002.
%             Michael Theriault, 6 November 2003
%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 5.20.4.19 $  $Date: 2011/02/15 00:53:48 $
%-------------------------------------------------------------------------------
if nargin < 2
    error(message('MATLAB:dlmwrite:Nargin'));
end

% validate filename
if ~ischar(filename)
    error(message('MATLAB:dlmwrite:InputClass'));
end;

% parse input and initialise parameters
try
    %We support having cell arrays be printed out.  Thus, if we get a cell
    %array, with the same type in it, we will convert to a matrix.
    if (iscell(m))
        try
            m = cell2mat(m);
        catch %#ok<CTCH>
            error(message('MATLAB:dlmwrite:CellArrayMismatch'));
        end
    end
    
    [dlm,r,c,NEWLINE,precn,append] = ...
        parseinput(length(varargin),varargin);
    % construct complex precision string from specified format string
    precnIsNumeric = isnumeric(precn);
    if ischar(precn)
        cpxprec = [precn strrep(precn,'%','%+') 'i']; %#ok<NASGU>
    end
    % set flag for char array to export
    isCharArray = ischar(m);
catch exception
    throw(exception);
end

% open the file
if append
    fid = fopen(filename ,'Ab');
else
    fid = fopen(filename ,'Wb');
end

% validate successful opening of file
if fid == (-1)
    error(message('MATLAB:dlmwrite:FileOpenFailure', filename));
end

% find size of matrix
[br,bc] = size(m);

% start with offsetting row of matrix
for i = 1:r
    for j = 1:bc+c-1
        fwrite(fid, dlm, 'uchar'); % write empty field
    end
    fwrite(fid, NEWLINE, 'char'); % terminate this line
end

% start dumping the array, for now number format float

realdata = isreal(m);
useVectorized = realdata && precnIsNumeric && isempty(strfind('%\',dlm)) ...
    && numel(dlm) == 1;
if useVectorized
    format = sprintf('%%.%dg%s',precn,dlm); %#ok<NASGU>
end
if isCharArray
    vectorizedChar = isempty(strfind('%\',dlm)) && numel(dlm) == 1; %#ok<NASGU>
    format = sprintf('%%c%c',dlm); %#ok<NASGU>
end
% allcomplete = '';

%% pre-init - ccx
linecomplete = '';
precn = '%+2.5e';
precnn = repmat([precn ','],1,bc);
precnn = precnn(1:end-1);

for i = 1:1
    % start with offsetting col of matrix
    for j = 1:bc
        % use specified format string
        str = sprintf(precn,-0.1);
        
        
        linecomplete = [linecomplete, str]; %#ok<AGROW>
%         element_length = length(linecomplete);
        
        if(j < bc)
            linecomplete = [linecomplete, dlm]; %#ok<AGROW>
        end
        %             fwrite(fid, str, 'uchar');
    end
    linecomplete = [linecomplete NEWLINE]; %#ok<AGROW>
    %     fwrite(fid, [linecomplete NEWLINE], 'uchar');
    
    %     fwrite(fid, NEWLINE, 'char'); % terminate this line
end
%%
line_length  = length(linecomplete); % maximum length including sign '-' two times
linecomplete = repmat(repmat(' ',1,line_length),1,br); % char(line_length*br,1);

idxx = 0:line_length-1;

%% write
for i = 1:br
    index = (i-1)*line_length+1;
    % start with offsetting col of matrix
    
    %% ab hier gehts los
    %     rowIsReal = isreal(m(i,:));
    %     dataline = '';
    %     for j = 1:bc
    %         %         if rowIsReal || isreal(m(i,j))
    %         % print real numbers
    %         % use specified format string
    %         str = sprintf(precn,m(i,j));
    %         %         else
    %         %             % print complex numbers
    %         %             if precnIsNumeric
    %         %                 % use default precision or precision specified. Print as float
    %         %                 str = sprintf('%.*g%+.*gi',precn,real(m(i,j)),precn,imag(m(i,j)));
    %         %             else
    %         %                 % use complex precision string
    %         %                 str = sprintf(cpxprec,real(m(i,j)),imag(m(i,j)));
    %         %             end
    %         %         end
    %
    %         dataline = [dataline, str, dlm];
    %
    %     end
    
    %     dataline2 = sprintf(precnn,m(i,:));
    
    %     linecomplete(index:(index+line_length-1)) = [dataline repmat(' ',1,line_length-length(dataline)-1) NEWLINE];
    linecomplete(index+idxx) = [sprintf(precnn,m(i,:)) NEWLINE]; % skip last delimiter
    %     linecomplete(index+line_length-1) = NEWLINE;
    
    
end
%     fwrite(fid, [linecomplete NEWLINE], 'uchar');
%     fwrite(fid, NEWLINE, 'char'); % terminate this line

fwrite(fid, linecomplete, 'uchar');

% close file
fclose(fid);

%------------------------------------------------------------------------------
function [dlm,r,c,newline,precn,appendmode] = parseinput(options,varargin)

% initialise parameters
dlm = ',';
r = 0;
c = 0;
precn = 5;
appendmode = false;
newline = sprintf('\n');

if options > 0
    
    % define input attribute strings
    delimiter = 'delimiter';
    lineterminator = 'newline';
    rowoffset = 'roffset';
    coloffset = 'coffset';
    precision = 'precision';
    append = '-append';
    attributes = {delimiter,lineterminator,rowoffset,coloffset,precision,append};
    
    varargin = varargin{:}; % extract cell array input from varargin
    
    % test whether attribute-value pairs are specified, or fixed parameter order
    stringoptions = lower(varargin(cellfun('isclass',varargin,'char')));
    attributeindexesinoptionlist = ismember(stringoptions,attributes);
    newinputform = any(attributeindexesinoptionlist);
    if newinputform
        % parse values to functions parameters
        i = 1;
        while (i <= length(varargin))
            if strcmpi(varargin{i},append)
                appendmode = true;
                i = i+1;
            else
                %Check to make sure that there is a pair to go with
                %this argument.
                if length(varargin) < i + 1
                    error(message('MATLAB:dlmwrite:AttributeList', varargin{ i }))
                end
                if strcmpi(varargin{i},delimiter)
                    dlm = setdlm(varargin{i+1});
                elseif strcmpi(varargin{i},lineterminator)
                    newline = setnewline(varargin{i+1});
                elseif strcmpi(varargin{i},rowoffset)
                    r = setroffset(varargin{i+1});
                elseif strcmpi(varargin{i},coloffset)
                    c = setcoffset(varargin{i+1});
                elseif strcmpi(varargin{i},precision)
                    precn = varargin{i+1};
                else
                    error(message('MATLAB:dlmwrite:Attribute', varargin{ i }))
                end
                i = i+2;
            end
        end
    else % arguments are in fixed parameter order
        % delimiter defaults to Comma for CSV
        if options > 0
            dlm = setdlm(varargin{1});
        end
        
        % row and column offsets defaults to zero
        if options > 1 && ~isempty(varargin{2})
            r = setroffset(varargin{2});
        end
        if options > 2 && ~isempty(varargin{3})
            c = setcoffset(varargin{3});
        end
    end
end
%------------------------------------------------------------------------------
function out = setdlm(in)
tmp = sprintf(in);
if ischar(in) && length(tmp) <= 1
    out = tmp;
else
    error(message('MATLAB:dlmwrite:delimiter',in));
end
%------------------------------------------------------------------------------
function out = setnewline(in)
if ischar(in)
    if strcmpi(in,'pc')
        out = sprintf('\r\n');
    elseif strcmpi(in,'unix')
        out = sprintf('\n');
    else
        error(message('MATLAB:dlmwrite:newline'));
    end
else
    error(message('MATLAB:dlmwrite:newline'));
end
%------------------------------------------------------------------------------
function out = setroffset(in)
if isnumeric(in)
    out = in;
else
    error(message('MATLAB:dlmwrite:rowOffset', in));
end
%------------------------------------------------------------------------------
function out = setcoffset(in)
if isnumeric(in)
    out = in;
else
    error(message('MATLAB:dlmwrite:columnOffset', in));
end
%-----------------------------------------------------------------------
