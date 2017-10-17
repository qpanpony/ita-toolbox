function [SystemMatrices]=sys_mat(coord, elements, groupMaterial)
% sys_mat() creates systemmatrices M, S, A and vector f. Coordinates
% (coord), elements (elements) and groups with boundary conditions
% (groupMaterial) are needed. systemmatrices are stored in struct
% SystemMatrices.
% Currently systemmatrices can only created for
% - surface parabolic triangle elements
% - surface parabolic quadrilateral elements
% - volume parabolic triangle elements
% - volume parabolic quadrilateral elements

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Initialization
% -------------------------------------------------------------------------
l_N=length(coord.ID);

S=sparse(l_N,l_N);       % compressibilitymatrix
M=sparse(l_N,l_N);       % massmatrix
A=cell(length(groupMaterial),1);% admittancematrix
f=cell(length(groupMaterial),1);% weightvector

SurfElem = elements{2};
VolumeElem = elements{1};

n_nodes = size(VolumeElem.nodes,2);
l_elem = size(VolumeElem.nodes,1);

h = itaWaitbar(l_elem,'I am integrating over all elements ...','System Matrices');

%% tri
% - basisfunctions are adjusted for I*DEAS
if n_nodes==10 || n_nodes==4
    % Surface elements
    %--------------------------------------------------------------------------
    for i1=1:length(groupMaterial)
        if length(groupMaterial{i1})==2 && ~isempty(groupMaterial{i1}{2})
            switch groupMaterial{i1}{2}.Type
                case 'Admittance',  rb =1; case 'Impedance',   rb =1;
                case 'Reflection',  rb =1; case 'Absorption',  rb =1;
                case 'Displacement',rb =2; case 'Velocity',    rb =2;
                case 'Acceleration',rb =2; case 'Point Source',rb =3;
                otherwise, rb=0;
            end
            
            % create admittancematrix
            if rb==1 && (length(groupMaterial{i1}{2}.Value)>1 || groupMaterial{i1}{2}.Value(end) ~=0)
                try
                    A{i1}=sparse(l_N,l_N);
                    if n_nodes==10
                        func_handle = @sur_tri_gauss_A;
                    else    %linear elements
                        func_handle = @sur_tri_gauss_A_lin;
                    end
                    for i2=1:length(groupMaterial{i1}{1}.ID)
                        elem  = groupMaterial{i1}{1}.ID(i2);
                        nodes = SurfElem.nodes(elem,:);
                        coordT= coord.cart(nodes,:);
                        A{i1} = func_handle(A{i1},coordT,nodes);
                    end
                catch
                    close(h);
                    error(['Try it again with a Point Source for group ' groupMaterial{i1}{2}.Name])
                end
            elseif rb==2 % create weightvector of surface elements
                f{i1}=sparse(l_N,1);
                if n_nodes==10
                    func_handle = @sur_tri_gauss_f;
                else    %linear elements
                    func_handle = @sur_tri_gauss_f_lin;
                end
                for i2=1:length(groupMaterial{i1}{1}.ID)
                    elem  = groupMaterial{i1}{1}.ID(i2);
                    nodes = SurfElem.nodes(elem,:);
                    coordT= coord.cart(nodes,:);
                    f{i1} = func_handle(f{i1},coordT,nodes);
                end
            elseif rb==3 % create weightvector of a point source
                f{i1}=sparse(l_N,1);
                f{i1}(groupMaterial{i1}{1}.ID) = 1;
            end
        else
            f{i1}=sparse(l_N,1);
        end
    end
    
    % Volume elements: creates mass- and stiffnessmatrices
    %--------------------------------------------------------------------------
    if n_nodes==10
        func_handle = @vol_tri_gauss;
    else    %linear elements
        func_handle = @vol_tri_gauss_lin;
    end
    for i1=1:l_elem
        nodes = VolumeElem.nodes(i1,:);
        coordT = coord.cart(nodes,:);
        [M, S] = func_handle(M,S,coordT,nodes);
        h.inc();
    end
    
    %% hex
    % - basisfunctions are adjusted for I*DEAS
elseif n_nodes==20 || n_nodes==8
    % Surface elements
    %--------------------------------------------------------------------------
    for i1=1:length(groupMaterial)
        if length(groupMaterial{i1})==2 && ~isempty(groupMaterial{i1}{2})
            switch groupMaterial{i1}{2}.Type
                case 'Admittance',  rb =1; case 'Impedance',   rb =1;
                case 'Reflection',  rb =1; case 'Absorption',  rb =1;
                case 'Displacement',rb =2; case 'Velocity',    rb =2;
                case 'Acceleration',rb =2; case 'Point Source',rb =3;
                otherwise, rb=0;
            end
            
            if rb==1 && (length(groupMaterial{i1}{2}.Value)>1 || groupMaterial{i1}{2}.Value(end) ~=0)
                % create admittancematrix
                try
                    A{i1}=sparse(l_N,l_N);
                    if n_nodes==20
                        func_handle = @sur_hex_gauss_A;
                    else    %linear elements
                        func_handle = @sur_hex_gauss_A_lin;
                    end
                    for i2=1:length(groupMaterial{i1}{1}.ID)
                        elem  = groupMaterial{i1}{1}.ID(i2);
                        nodes = SurfElem.nodes(elem,:);
                        coordT= coord.cart(nodes,:);
                        A{i1} = func_handle(A{i1},coordT,nodes);
                    end
                catch
                    close(h);
                    error(['Try it again with a Point Source for group ' groupMaterial{i1}{2}.Name])
                end
            elseif rb==2
                % create weightvector of surface elements
                f{i1}=sparse(l_N,1);
                if n_nodes==20
                    func_handle = @sur_hex_gauss_f;
                else    %linear elements
                    func_handle = @sur_hex_gauss_f_lin;
                end
                for i2=1:length(groupMaterial{i1}{1}.ID)
                    elem  = groupMaterial{i1}{1}.ID(i2);
                    nodes = SurfElem.nodes(elem,:);
                    coordT= coord.cart(nodes,:);
                    f{i1} = func_handle(f{i1},coordT,nodes);
                end
            elseif rb==3
                % create weightvector of point source
                f{i1}=sparse(l_N,1);
                f{i1}(groupMaterial{i1}{1}.ID) = 1;
            end
        else
            f{i1}=sparse(l_N,1);
        end
    end
    
    % Volume elements: creates mass- and stiffnessmatrices
    %--------------------------------------------------------------------------
    if n_nodes == 20
        func_handle = @vol_hex_gauss;
    else
        func_handle = @vol_hex_gauss_lin;
    end
    for i1=1:l_elem
        nodes = VolumeElem.nodes(i1,:);
        coordT= coord.cart(nodes,:);
        [M, S] = func_handle(M,S,coordT,nodes);
        h.inc();
    end
end

close(h);

%% Output
SystemMatrices.A = A;
SystemMatrices.f = f;
SystemMatrices.M = M;
SystemMatrices.S = S;
