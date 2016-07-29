function ret = Int2Hex(var)        
% Prints integer array to hexadecimal string

	varType = class(var);

	% cast signness away:
	if ('u' ~= varType(1) )
		varType = ['u' varType];
		var = typecast(var,varType);
	end        

	nBits = str2double(varType(5:end));
	if (64 == nBits) 
	% split 64 bit case into two 32's
	% cuz dec2hex doesn't handle 64 bit...
		varType(5:end) = '32';
		var = typecast(var,varType);
	end

	ret = dec2hex(var);

	if (64 == nBits)
        littleEndian = all(typecast(uint32(1),'uint16')==[1 0]);
        first  = 1 + littleEndian;
        second = 2 - littleEndian;
        ret = [ret(first:2:end,:),ret(second:2:end,:)];
	end
end

