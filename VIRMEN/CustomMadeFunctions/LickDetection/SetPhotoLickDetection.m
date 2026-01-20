function [ vr ] = SetPhotoLickDetection(vr) ;
%Useful for the DAQ resetting....
if isfield(vr,'PhotoLickDetection')
delete(vr.PhotoLickDetection.daqSessLickDetection);
end
vr.PhotoLickDetection.daqSessLickDetection = analoginput('nidaq', ['Dev' num2str(vr.NIDev)]);
vr.PhotoLickDetection.Channel =3; % the AI number
addchannel(vr.PhotoLickDetection.daqSessLickDetection, vr.PhotoLickDetection.Channel, 'Voltage'); %creates the session for daq licking
set(vr.PhotoLickDetection.daqSessLickDetection,'samplerate',10000);
set(vr.PhotoLickDetection.daqSessLickDetection,'SamplesPerTrigger',round(get(vr.PhotoLickDetection.daqSessLickDetection,'samplerate')/1000)+1) ;






end

