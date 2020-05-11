function test_itaMaterial()

%% Default constructor
material = itaMaterial;

%% Freq data object must be itaSuper
errorThrown = false;
try
    material.impedance = 1;
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted not supported data for impedance')
end

errorThrown = false;
try
    material.absorption = 'fdsfsa';
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted not supported data for absorption')
end

errorThrown = false;
try
    material.scattering = true;
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted not supported data for scattering')
end

%% Freq data object must be scalar
errorThrown = false;
try
    material.impedance = itaSuper(2);
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted non-scalar object for impedance')
end

errorThrown = false;
try
    material.absorption = itaSuper(2);
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted non-scalar object for absorption')
end

errorThrown = false;
try
    material.scattering = itaSuper(2);
catch err
    errorThrown = true;
end
if errorThrown == false
    error('itaMaterial excepted non-scalar object for scattering')
end


%% Valid Operations
material.impedance = [];
material.absorption = [];
material.scattering = [];
material.rho0Air = [];
material.cAir = [];

material.impedance = itaResult((1:5)'*(1+1j), [20 40 80 160 320]', 'freq');
material.absorption = itaResult((1:5)', [20 40 80 160 320]', 'freq');
material.scattering = itaResult((1:5)', [20 40 80 160 320]', 'freq');
material.rho0Air = 1.24;
material.cAir = 344;

%% Copy constructor
copyMaterial = itaMaterial(material);

