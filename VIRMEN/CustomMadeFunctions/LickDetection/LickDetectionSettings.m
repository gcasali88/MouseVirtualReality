function [vr] =  LickDetectionSettings(vr);
% %% LEGACY settings...
 vr.LickDetection.daqSessLickDetection = analoginput('nidaq', 'Dev2');
 vr.LickDetection.Channel = [3 4] ; % the AI number
 addchannel(vr.LickDetection.daqSessLickDetection, vr.LickDetection.Channel, 'Voltage'); %creates the session for daq licking
 vr.LickDetection.Duration = 1;
 vr.LickDetection.SampleRate = 1000;%in s...
 set(vr.LickDetection.daqSessLickDetection,'samplerate',vr.LickDetection.daqSessLickDetection.SampleRate);
 set(vr.LickDetection.daqSessLickDetection,'SamplesPerTrigger',vr.LickDetection.Duration*vr.LickDetection.SampleRate ) ;
 vr.LickDetection.daqSessLickDetection.LoggingMode = 'Memory';
%vr.LickDetection.daqSessLickDetection.LogFileName = 'tmp.daq';

%%
vr.LickDetection.MinimumTimeDistance = 2; % Seconds (if the voltage is higher than threshold within minimum temporal lag is not stored as additional licking event...
 vr.LickDetection.LickEvents = 0; % that will increase during recordings
 vr.LickDetection.LickTimeStamps = []; % that will increase during recordings
 vr.LickDetection.LickPositions = []; % that will increase during recordings
 vr.LickDetection.VoltageThreshold =  2; % the voltage threshold for detection
%% SESSION Settings, running in the background...

% vr.LickDetection.daqSessLickDetection = analoginput('nidaq','Dev2') ; % daq.createSession('ni');
% vr.LickDetection.Channel = [3 4];
% vr.LickDetection.SampleRate=100000;
% vr.LickDetection.Duration = 1  ; 
% set(vr.LickDetection.daqSessLickDetection,'SampleRate' , vr.LickDetection.SampleRate) ;
% addchannel(vr.LickDetection.daqSessLickDetection,vr.LickDetection.Channel);
% vr.LickDetection.SamplesPerTrigger = vr.LickDetection.Duration *vr.LickDetection.SampleRate;
% vr.LickDetection.daqSessLickDetection.IsContinuous = true;



vr.LickDetection.VoltageThreshold = 5;%addAnalogInputChannel(vr.LickDetection.daqSessLickDetection,'dev2',[vr.LickDetection.Channel],'Voltage');
vr.LickDetection.fidLicking = fopen('VoltageLicking.data','w');%creates the file where the behavioural data is stored (better than updating this into the vr structure)...
vr.LickDetection.fidDetection = fopen('VoltageLickingDetection.data','w');%creates the file where the photo sensor is constantly sampled...may be worth using it later on...
vr.LickDetection.MinimumTimeDistance = 2; % Seconds (if the voltage is higher than threshold within minimum temporal lag is not stored as additional licking event...
vr.LickDetection.Licking = 0; % that will increase during recordings
vr.LickDetection.LickEvents = 0; % that will increase during recordings
vr.LickDetection.LickTimeStamps = []; % that will increase during recordings
vr.LickDetection.LickPositions = []; % that will increase during recordings


%vr.lh = vr.LickDetection.daqSessLickDetection.addlistener('DataAvailable', @(src,event) SignalEventGreaterThanThreshold(src, event,vr)) ;
%vr.LickDetection.NotifyWhenDataAvailableExceedsMilliseconds= 1 /vr.LickDetection.SampleRate; % in milliseconds....
%vr.LickDetection.daqSessLickDetection.NotifyWhenDataAvailableExceeds = round(vr.LickDetection.NotifyWhenDataAvailableExceedsMilliseconds* vr.LickDetection.daqSessLickDetection.Rate);
%vr.LickDetection.lh = vr.LickDetection.daqSessLickDetection.addlistener('DataAvailable', @(src, event)collectDataWithinVR(src, event, vr.LickDetection.fidDetection))  ;
%%



end