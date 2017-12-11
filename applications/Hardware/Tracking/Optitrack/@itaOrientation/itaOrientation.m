classdef itaOrientation
    
    % class itaOrientation (value class)
    %
    % Stores the orientation of a rigid body and allows transformations
    % between the following domains:
    % - Quaternion
    % - View/Up vector
    % - Roll/Pitch/Yaw angles
    %
    % Convention:
    % Roll means a rotation around -Z, pitch means a rotation around +X, and
    % yaw means a rotation around +Y (right-handed OpenGL coordinate system,
    % used by Optitrack). All rotations are defined clockwise. This defines
    % the default view vector in negative Z direction and the default up vector
    % in positive Y direction.
    %
    %                             (+Y)
    %                               |
    %                               |
    %                               . - - (+X)
    %                              /
    %                             /
    %                           (+Z)
    %
    % Class is working similar as itaCoordinates. Type doc itaOrientation
    % for a description of properties.
    %
    % Constructor: obj = itaOptitrack(varargin)
    %              varargin{1} ... either nPoints x 4 [double] to create a
    %                              class object with nPoints orientations 
    %                              given as quaternions; or nPoints
    %                              [double] to create an object with nPoints
    %                              orientations (NaN quaternions)
    %              varargin{2} ... (optional) coordinate system [char],
    %                              'openGLrh' (default), currently no
    %                              other coordinate systems implemented
    %
    % See also: quaternion, ita_quat2rpy, ita_quat2vu, ita_rpy2quat, ita_rpy2vu,
    %           ita_vu2quat, ita_vu2rpy, itaOptitrack
    %
    % Author:  Florian Pausch, fpa@akustik.rwth-aachen.de
    % Version: 2016-05-09
    %
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt 
    % file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access=private)
        mOrient = []; % [1 nPoints]
        mCoordSystem = 'openGLrh'; % 'openGLrh'
    end
    
    properties(Dependent)        
        quat;       % quaternions based on class quaternions.m, order [qw (real), qx, qy, qz], 1 x nPoints [quaternion]
        qw;         % real part w of quat, nPoints x 1 [double]
        qx;         % first entry x of imaginary part of quat, nPoints x 1 [double]
        qy;         % second entry y of imaginary part of quat, nPoints x 1 [double]
        qz;         % third entry z of imaginary part of quat, nPoints x 1 [double]
        
        vu;         % view/up vectors, nPoints x 6, mtx(vx vy vz ux uy uz) [double]
        view;       % get view vector/look direction, nPoints x 3, mtx(vx vy vz) [double]
        up;         % up: up direction (orthogonal to view vector), nPoints x 3, mtx(ux uy uz) [double]
        
        rpy;        % roll/pitch/yaw (rad), nPoints x 3 [double]
        roll;       % roll (rad), clockwise rotation angle around -Z axis, nPoints x 1 [double]
        pitch;      % pitch (rad), clockwise rotation angle around +X axis, nPoints x 1 [double]
        yaw;        % yaw (rad), clockwise rotation angle around +Y axis, nPoints x 1 [double]
        
        rpy_deg;    % roll_deg/pitch_deg/yaw_deg (deg), nPoints x 3 [double]
        roll_deg;   % roll_deg (deg), clockwise rotation angle around -Z axis, nPoints x 1 [double]
        pitch_deg;  % pitch_deg (deg), clockwise rotation angle around +X axis, nPoints x 1 [double]
        yaw_deg;    % yaw_deg (deg), clockwise rotation angle around +Y axis, nPoints x 1 [double]
        
        nPoints     % number of stored orientations
    end
    
    methods
        function this = itaOrientation(varargin)
            if nargin == 0
                %% itaOrientation() -> scalar NaN quaternion [NaN,NaN,NaN,NaN]
                this.mOrient = quaternion.NaN(0,4);
            elseif nargin == 1
                if isa(varargin{1},'itaOrientation')
                    %% copy constructor
                    this.mOrient = varargin{1}.mOrient;
                    this.mCoordSystem = varargin{1}.mCoordSystem;
                elseif isa(varargin{1},'quaternion')
                    this.mOrient = varargin{1};
                elseif isscalar(varargin{1}) && isnumeric(varargin{1})
                    %% itaOrientation(n) --> n scalar NaN quaternions
                    nPoints = varargin{1};
                    this.mOrient = quaternion.NaN(1,nPoints);
                elseif all(isnumeric(varargin{1})) && size(varargin{1},2) == 4
                    %% itaOrientation(quaternion[w x y z])
                    this.mOrient = quaternion(varargin{1});
                end
            elseif nargin == 2
                if isscalar(varargin{1}) && isnumeric(varargin{1})
                    this.mOrient = quaternion.NaN(1,varargin{1});
                elseif isa(varargin{1},'quaternion')
                    this.mOrient = varargin{1};
                elseif all(isnumeric(varargin{1})) && size(varargin{1},2) == 4
                    this.mOrient = quaternion(varargin{1});
                end
                this.mCoordSystem = varargin{2};
            end
        end
        
        
        %% get methods
        function value = get.quat(this)
            % get quat, 1 x nPoints [quaternion]
            value = this.mOrient;
        end
        
        function value = get.qw(this)
            % get real part w of quat, nPoints x 1 [double]
            value = this.quat.real';
        end
        
        function value = get.qx(this)
            % get first entry x of imaginary part of quat, nPoints x 1 [double]
            value = this.quat.imag';
        end
        
        function value = get.qy(this)
            % get second entry y of imaginary part of quat, nPoints x 1 [double]
            value = this.quat.jmag';
        end
        
        function value = get.qz(this)
            % get third entry z of imaginary part of quat, nPoints x 1 [double]
            value = this.quat.kmag';
        end
        
        function value = get.vu(this)
            % get view/up vectors, nPoints x 6, mtx(vx vy vz ux uy uz) [double]
            [v, u] = ita_quat2vu(this.mOrient);
            value = [v, u];
        end
        
        function value = get.view(this)
            % get view vector, nPoints x 3, mtx(vx vy vz) [double]
            value = this.vu(:,1:3);
        end
        
        function value = get.up(this)
            % get up vector, nPoints x 3, mtx(ux uy uz) [double]
            value = this.vu(:,4:6);
        end
        
        function value = get.rpy(this)
            % get roll/pitch/yaw (rad), nPoints x 3 [double]
            [r, p, y] = ita_quat2rpy(this.mOrient);
            value = [r, p, y];
        end
        
        function value = get.roll(this)
            % get roll (rad), nPoints x 1 [double]
            value = this.rpy(:,1);
        end
        
        function value = get.pitch(this)
            % get pitch (rad), nPoints x 1 [double]
            value = this.rpy(:,2);
        end
        
        function value = get.yaw(this)
            % get yaw (rad), nPoints x 1 [double]
            value = this.rpy(:,3);
        end
        
        function value = get.rpy_deg(this)
            % get roll/pitch/yaw (deg), nPoints x 3 [double]
            [r,p,y] = ita_quat2rpy(this.mOrient);
            value = radtodeg([r, p, y]);
        end
        
        function value = get.roll_deg(this)
            % get roll_deg (deg), nPoints x 1 [double]
            value = this.rpy_deg(:,1);
        end
        
        function value = get.pitch_deg(this)
            % get pitch_deg (deg), nPoints x 1 [double]
            value = this.rpy_deg(:,2);
        end
        
        function value = get.yaw_deg(this)
            % get yaw_deg (deg), nPoints x 1 [double]
            value = this.rpy_deg(:,3);
        end
        
        function value = get.nPoints(this)
            % get number of stored orientations [double]
            value = size(this.mOrient,2);
        end
        
        
        %% set methods
        function this = set.quat(this,value)
            % set quat, nPoints x 4 [double]
            if ~isa(value,'quaternion')
                assert( isequal(size(value,2),4),['Size of input must be ',num2str(this.nPoints),' x 4 [double].'])
                if size(value,1)~=this.nPoints;
                    fprintf('[\b[itaOrientation]\tSize of input does not match %d x 4.]\b\n',this.nPoints)
                    fprintf('[\b\t\t\t\t\tSize of class object is changed.]\b\n')
                end
                this.mOrient = quaternion(value);
            else
                this.mOrient = value;
            end
            
        end
        
        function this = set.qw(this,value)
            % set real part qw of quat, nPoints x 1 [double]
            assert( isequal(size(value),size(this.qw)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = quaternion([value, this.qx, this.qy, this.qz]);
        end
        
        function this = set.qx(this,value)
            % set second entry qy of imaginary part of quat, nPoints x 1 [double]
            assert( isequal(size(value),size(this.qx)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = quaternion([this.qw, value, this.qy, this.qz]);
        end
        
        function this = set.qy(this,value)
            % set second entry qy of imaginary part of quat, nPoints x 1 [double]
            assert( isequal(size(value),size(this.qy)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = quaternion([this.qw, this.qx, value, this.qz]);
        end
        
        function this = set.qz(this,value)
            % set third entry qz of imaginary part of quat, nPoints x 1 [double]
            assert( isequal(size(value),size(this.qz)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = quaternion([this.qw, this.qx, this.qy, value]);            
        end
        
        function this = set.vu(this,value)
            % set view/up vector, nPoints x 6, mtx(vx vy vz ux uy uz) [double]
            assert( isequal(size(value),size(this.vu)),['Size of input must be ',num2str(this.nPoints),' x 6, mtx(vx vy vz ux uy uz) [double].'])
            
            if abs(dot(value(:,1:3),value(:,4:6),2)) > 1e-5
                fprintf('[\b[itaOrientation] Vectors view/up are not orthogonal to each other. Old values are kept.]\b\n')
            else
                this.mOrient = ita_vu2quat(value(:,1:3),value(:,4:6));
            end
        end
        
        function this = set.view(this,value)
            % set view vector, nPoints x 3, mtx(vx vy vz) [double]
            assert( isequal(size(value),size(this.view)),['Size of input must be ',num2str(this.nPoints),' x 3, mtx(vx vy vz) [double].'])
            
            % calculate side vector and new up vector
            if isequal(value,this.up) % case new view vector is old up vector
                s = cross(this.view,this.up);
                u = normr(cross(s,this.up));
            elseif isequal(value,-this.up) % case new view vector is negative old up vector
                s = cross(this.view,-this.up);
                u = normr(cross(s,this.up));
            else
                s = cross(value,this.up);
                u = normr(cross(s,value));
            end
            this.mOrient = ita_vu2quat(value,u);
        end
        
        function this = set.up(this,value)
            % set up vector, nPoints x 3, mtx(ux uy uz) [double]
            assert( isequal(size(value),size(this.up)),['Size of input must be ',num2str(this.nPoints),' x 3, mtx(ux uy uz) [double].'])
            
            % calculate side vector and new view vector
            if isequal(value,this.view) % case new up vector is old view vector
                s = cross(this.view,this.up);
                v = normr(cross(this.view,s));
            elseif isequal(value,-this.view) % case new up vector is negative old view vector
                s = cross(this.view,-this.up);
                v = normr(cross(this.view,s));
            else
                s = cross(this.view,value);
                v = normr(cross(value,s));
            end
            this.mOrient = ita_vu2quat(v,value);
        end
        
        function this = set.rpy(this,value)
            % set roll/pitch/yaw (rad), nPoints x 3 [double]
            assert( isequal(size(value),size(this.rpy)),['Size of input must be ',num2str(this.nPoints),' x 3 [double].'])
            this.mOrient = ita_rpy2quat(value(:,1), value(:,2), value(:,3));
        end
        
        function this = set.roll(this,value)
            % set roll (rad), nPoints x 1 [double]
            assert( isequal(size(value),size(this.roll)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(value, this.pitch, this.yaw);
        end
        
        function this = set.pitch(this,value)
            % set pitch (rad), nPoints x 1 [double]
            assert( isequal(size(value),size(this.pitch)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(this.roll, value, this.yaw);
        end
        
        function this = set.yaw(this,value)
            % set yaw (rad), nPoints x 1 [double]
            assert( isequal(size(value),size(this.yaw)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(this.roll, this.pitch, value);
        end
        
        function this = set.rpy_deg(this,value)
            % set roll_deg/pitch_deg/yaw_deg (deg), nPoints x 3 [double]
            assert( isequal(size(value),size(this.rpy_deg)),['Size of input must be ',num2str(this.nPoints),' x 3 [double].'])
            this.mOrient = ita_rpy2quat(deg2rad(value(:,1)), deg2rad(value(:,2)), deg2rad(value(:,3)));
        end
        
        function this = set.roll_deg(this,value)
            % set roll_deg (deg), nPoints x 1 [double]
            assert( isequal(size(value),size(this.roll_deg)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(degtorad(value), this.pitch, this.yaw);
        end
        
        function this = set.pitch_deg(this,value)
            % set pitch_deg (rad), nPoints x 1 [double]
            assert( isequal(size(value),size(this.pitch_deg)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(this.roll, degtorad(value), this.yaw);
        end
        
        function this = set.yaw_deg(this,value)
            % set yaw_deg (rad), nPoints x 1 [double]
            assert( isequal(size(value),size(this.yaw_deg)),['Size of input must be ',num2str(this.nPoints),' x 1 [double].'])
            this.mOrient = ita_rpy2quat(this.roll, this.pitch, degtorad(value));
        end
        
        function this = set.mOrient(this, value)
            % if the value is twisted, twist back
            if size(value,1) ~= 1 && ~isempty(value)
                error([mfilename('class') '  invalid size of input data']);
            end
            this.mOrient = value;
        end
        
        function this = set.mCoordSystem(this, value)
            % set coordinate system
            isSingleString = ischar(value);
            if isSingleString && ismember(value, {'openGLrh'}) % TODO: add further coordinate systems
                this.mCoordSystem = value;
            else
                error([mfilename('class') '  invalid string for coordinate system']);
            end
        end
        
        %% other methods
        function result = coordSystem(this)
            % Return used coordinate system
            result = this.mCoordSystem;
        end
        
        function this = n(this,index)
            % Replace by content of chosen index n
            
            % error check: do nothing, if out of bound or nothing given
            if nargin < 2 || isempty(this.mOrient), return; end;
            this.mOrient = this.mOrient(1,index);
        end
        
        function result = split(this,index)
            % for itaOrientation
            result = this.n(index);
        end
        
%         function this = merge(varargin)
%             if numel(varargin) == 1 && numel(varargin{1}) == 1 %Only one element
%                 this = varargin{1};
%             else
%                 this = merge(varargin{1});
%                 varargin(1) = [];
%                 for idx = 1:numel(varargin)
%                     input = merge(varargin{idx});
%                     this.(this.coordSystem) = [this.(this.coordSystem); input.(this.coordSystem)];
%                 end
%             end
%         end
        
        function this = resize(this,n)
            % Resize for itaOrientation
            if n > size(this.mOrient,2)
                this.mOrient = [this.mOrient, quaternion.NaN(1,n-this.nPoints)];
            end
            if n < size(this.mOrient,2)
                this.mOrient(:,(n+1):end) = [];
            end
        end
        
    end
    
end
