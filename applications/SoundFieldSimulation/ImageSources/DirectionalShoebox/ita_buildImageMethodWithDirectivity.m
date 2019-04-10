function state = ita_buildImageMethodWithDirectivity(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

state = ita_reflectionCoefficientPowerVector(params,state,dirs);
state = ita_reflectionCoefficientsAndRoomDisplacements(params,state,dirs);
state = ita_imageReceiverDisplacements(params,state,dirs);
state = ita_imageReceiverDistances(params,state,dirs);
state = ita_radiationAngles(params,state,dirs);
state = ita_radiationSphericalHarmonics(params,state,dirs);
state = ita_directivityAngles(params,state,dirs);
state = ita_directivitySphericalHarmonics(params,state,dirs);
state = ita_reflectionGains(params,state,dirs);
state = ita_reflectionTimes(params,state,dirs);
state = ita_orderReflectionsIntoRir(params,state,dirs);
