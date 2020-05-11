classdef itaImageSources
   properties (Access = private)
      mName = '';
      mID = 0;
   end
   
   properties (Dependent)
      name = '';
      ID = 0;
   end
   
   methods % Special functions that implement operations that are usually performed only on instances of the class
       function this = itaImageSources(varargin)
           if nargin >=2
               if sum(strcmp(varargin,'ID'))==1

                   if sum(strcmp(varargin,'name'))==1
                       pos = find(strcmp(varargin,'ID')==1);
                       this.mID = varargin{pos+1};
                       pos = find(strcmp(varargin,'name')==1);
                       this.mName = varargin{pos+1};
                   else
                       error('itaImageSources:Def', ' Wrong type of input.')
                   end
               elseif isstruct(varargin{1}) % Struct input/convert %temporär kopiert!!!
                    fieldName = fieldnames(varargin{1});
                    for ind = 1:numel(fieldName);
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            disp(errmsg);
                        end
                    end
               else
                    this.mID = 1;
                    this.mName = 'noName';
               end
           elseif nargin ==1 && isa(varargin{1},'itaImageSources')
               this = varargin{1};
           elseif isempty(nargin)
               this.mID = 1;
               this.mName = 'noName';
           else
               error('itaImageSources:Def', ' too many input arguments.')
           end
       end
       
        function name = get.name(this), name = this.mName; end
        function ID = get.ID(this), ID = this.mID; end

        function this = set.name(this,name), this.mName = name;end
        function this = set.ID(this,ID), this.mID = ID;end
        
        function display(this)
            disp(['(ID: ' num2str(this.ID) ')  ' this.name]);
            disp( '==================================================');            
        end
   end
   
%    events
%       EventName
%    end
%    enumeration
%       EnumName (arg)
%    end
end
