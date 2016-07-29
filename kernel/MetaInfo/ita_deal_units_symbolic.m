function varargout = ita_deal_units_symbolic(varargin)
%ITA_DEAL_UNITS - Deal with physical units
%  This function takes care of the physical units used in the header of
%  audioObjs. It can multiply or divide two units or just deal with one
%  unit. Everything is transformed to SI units, rationalized/simplified and
%  transformed back to units used in acoustics.
%
%  Call: unitString = ita_deal_units(unitString)
%
%  ita_deal_units(unitString1) - just check units and simplify
%  ita_deal_units(unitString1,unitString2,'*')
%  ita_deal_units(unitString1,unitString2,'/')
%
%   See also ita_power, ita_multiply_spk, ita_divide_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_deal_units">doc ita_deal_units</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  07-Nov-2008 *checked*

%% Get ITA Toolbox preferences
if nargin > 1
   unitString = ['(' varargin{1} ')' varargin{3} '(' varargin{2} ')'];
else
    unitString = [varargin{1}];
end

%% SI Einheiten

syms m kg s A K mol cd;

%% SI derivates
V = m^2 * kg * s^(-3)*A^(-1);
H = m^2 * kg * s^(-2)*A^(-2);
F = s^4 * A^2 * m^(-2) * kg;
C = s*A;
T = kg /(s^2*A);
N = kg*m/(s^2);
W = V*A;
Pa = N/m^2;
Hz = 1/s;

%% special Units
syms dB sone rad;

%eval(['syms ' unitString(isstrprop(unitString,'alpha') | isstrprop(unitString,'wspace'))]);

% Find multiple white spaces (a   +b)
unitString(circshift(isstrprop(unitString,'wspace'),[0 -1]) & isstrprop(unitString,'wspace')) = [];
% Find implict multiplications like (a b)
implicitMultiplication =  circshift(isstrprop(unitString,'alphanum'),[0 -1]) & isstrprop(unitString,'wspace') & circshift(isstrprop(unitString,'alphanum'),[0 1]);
unitString(implicitMultiplication) = '*';
units = eval(unitString);

unitString = char(units);

%unitString = ita_deal_units(unitString);

if nargout > 0
varargout{1} = unitString;
end

if nargout > 1
varargout{2} = units;
end
end
