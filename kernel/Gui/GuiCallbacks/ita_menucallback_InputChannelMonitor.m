function ita_menucallback_InputChannelMonitor(hObject, eventData)


if ita_preferences('playDeviceID') == -1
    errordlg('No input device selected. Select you sound card in ITA > Preferences > IO Settings')
end
ita_ioMonitor()