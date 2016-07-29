function ita_save_xml_material_for_raven_from_impcalc_struct(impcalc_struct, xml_filename, optional_filenamediffuse)
%ita_save_xml_material_for_raven_from_impcalc_struct(impcalc_struct, xml_filename, optional_filenamediffuse)
%
%   Writes an XML material file for Raven. The input struct can be
%   generated using the ITA-Toolbox function ita_impcalc_gui.
%
%   Parameters:
%       impcalc_struct: struct as stored by ita_impcalc_gui (usually called
%                       "saveIt").
%       xml_filename  : filename where the XML file should be stored. Put
%                       the materials into:
%                       %RavenPath%\RavenDatabase\MaterialDatabase
%       optional_filenamediffuse: use this optional parameter of you want
%                       to store the diffuse-average version of the
%                       angle-dependent reflection properties.
%
%   Example:
%       ita_impcalc_gui
%       matStruct = load('my_saved_layer_info.mat');
%       ita_save_xml_material_for_raven_from_impcalc_struct(...
%               matStruct.saveIt, 'my_xml_material.xml', ...
%                                 'my_xml_material_diffuse.xml');
%

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% angle-dependent
impcalc_struct.sea.senk = 1;
result = ita_utils_sim_layer_model(impcalc_struct, 'theta', 0:5:85, 'save', 'Audio', 'fftDegree', 16, 'samplingRate', 44100, 'f', [0 22050]);

third_octave_reflection = ita_spk2frequencybands(result.reflection_factor, 'bandsperoctave', 3, 'method', 'averaged');
third_octave_absorption = ita_spk2frequencybands(result.absorption_coeff, 'bandsperoctave', 3, 'method', 'averaged');

[~,name,~] = fileparts(xml_filename);

ita_save_xml_material_for_raven(xml_filename, ...
    'id', name, ...
    'name', name, ...
    'description', 'Calculated using ita_impcalc_gui', ...
    'reflection_factor', third_octave_reflection, ...
    'absorption_coeff', third_octave_absorption, ...
    ...'scatter_coeff', ?, ...
    ...'impedance', ?, ...
    'frequency_type', 'third-octave', ...
    'theta_in', toRadians('degrees', 0:5:85));


%% diffuse
if (nargin > 2)
    impcalc_struct.sea.winkel = 0;
    impcalc_struct.sea.senk = 0;
    result = ita_impcalc_wo_gui(impcalc_struct, 'modus', 'Impedanz', 'save', 'Audio', 'fftDegree', 16, 'sampleRate', 44100);

    reflection = result.ch(3);
    absorption = result.ch(4);

    mask = abs(reflection.freq) > 1;
    reflection.freq(mask) = 1 * exp(1i * angle(reflection.freq(mask)));
    mask = absorption.freq < 0;
    absorption.freq(mask) = 0;

    third_octave_reflection = ita_spk2frequencybands(reflection, 'bandsperoctave', 3, 'method', 'averaged');
    third_octave_absorption = ita_spk2frequencybands(absorption, 'bandsperoctave', 3, 'method', 'averaged');

    [~,name,~] = fileparts(optional_filenamediffuse);
    
    ita_save_xml_material_for_raven(optional_filenamediffuse, ...
        'id', name, ...
        'name', name, ...
        'description', 'Calculated using ita_impcalc_gui', ...
        'reflection_factor', third_octave_reflection, ...
        'absorption_coeff', third_octave_absorption, ...
        ...'scatter_coeff', ?, ...
        ...'impedance', ?, ...
        'frequency_type', 'third-octave');

end
    
end