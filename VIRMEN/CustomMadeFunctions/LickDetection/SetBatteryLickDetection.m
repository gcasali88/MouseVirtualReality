function vr = SetBatteryLickDetection(vr)

if isfield(vr,'BatteryLickDetection')
delete(vr.BatteryLickDetection.daqSessLickDetection);
end
vr.BatteryLickDetection.daqSessLickDetection = analoginput('nidaq', 'Dev2');
vr.BatteryLickDetection.Channel = 4; % the AI number
addchannel(vr.BatteryLickDetection.daqSessLickDetection, vr.BatteryLickDetection.Channel, 'Voltage'); %creates the session for daq licking
set(vr.BatteryLickDetection.daqSessLickDetection,'samplerate',10000);
set(vr.BatteryLickDetection.daqSessLickDetection,'SamplesPerTrigger',round(get(vr.BatteryLickDetection.daqSessLickDetection,'samplerate')/1000)+1) ;

end
