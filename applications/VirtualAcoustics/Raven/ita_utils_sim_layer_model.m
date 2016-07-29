function result = ita_utils_sim_layer_model(varargin)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

args = struct('pos1_model', '', ...
    'theta', 0, ...
    'modus', 'Impedanz', ...
    'save', 'Result', ...
    'fftDegree', 16, ...
    'samplingRate', 44100, ...
    'f', [] ...
    );

[model, args] = ita_parse_arguments(args,varargin);

result.reflection_factor = itaResult;
result.absorption_coeff = itaResult;
result.impedance = itaResult;

if ~isempty(args.f)
    model.fb.unten = args.f(1);
    model.fb.oben = args.f(2);
    model.fb.step = args.samplingRate/2^args.fftDegree;
    model.fb.lin = 1;
end

for index = 1:numel(args.theta)
    model.sea.winkel = args.theta(index);
%     [cli_output, result_theta] = evalc('ita_impcalc_wo_gui(model)');
    [cli_output, result_theta] = evalc('ita_impcalc_wo_gui(model, ''modus'', args.modus, ''save'', args.save, ''fftDegree'', args.fftDegree, ''sampleRate'', args.samplingRate)');
    result.reflection_factor = merge(result.reflection_factor, result_theta.ch(strcmp('Reflection Factor', result_theta.channelNames)));
    result.absorption_coeff = merge(result.absorption_coeff, result_theta.ch(strcmp('Absorption', result_theta.channelNames)));
    result.impedance = merge(result.impedance, result_theta.ch(strcmp('Impedance', result_theta.channelNames)));
end

end