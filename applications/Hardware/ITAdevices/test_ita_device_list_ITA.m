% check for invalid device names


allDeviceInfo = ita_device_list_ITA();

invalidChar = '()[]';
idxEntryInvalid = [];

for iChar  = 1 : numel(invalidChar)
    idxEntryInvalid = unique([idxEntryInvalid, find(~cellfun(@isempty, strfind(allDeviceInfo(:,1), invalidChar(iChar))))]);
end

if ~isempty(idxEntryInvalid)
    allDeviceInfo(idxEntryInvalid,:)
    error('Parenthesis not allowed in device names! Found %i invalid entries.', numel(idxEntryInvalid))
end