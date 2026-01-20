function [vr] =  PhotoLickDetectionSettings(vr);
% d = daqhwinfo;
% ai = analoginput('nidaqmx', 'Dev3');
vr = SetPhotoLickDetection(vr);
% vr.PhotoLickDetection.daqSessLickDetection = analoginput('nidaq', 'Dev3');
% vr.PhotoLickDetection.Channel =2; % the AI number
% addchannel(vr.PhotoLickDetection.daqSessLickDetection, vr.PhotoLickDetection.Channel, 'Voltage'); %creates the session for daq licking
% set(vr.PhotoLickDetection.daqSessLickDetection,'samplerate',1000);
% set(vr.PhotoLickDetection.daqSessLickDetection,'SamplesPerTrigger',round(get(vr.PhotoLickDetection.daqSessLickDetection,'samplerate')/1000)+1) ;


vr.PhotoLickDetection.Model = '5V'; %% '5V' or '12V'
vr.PhotoLickDetection.MinimumTimeDistance = 0; % Seconds (if the voltage is higher than threshold within minimum temporal lag is not stored as additional licking event...
vr.PhotoLickDetection.LickingLastLogNumberOfEvents = [1]; %Prior to the refresh window...
vr.PhotoLickDetection.Licking = [0];
vr.PhotoLickDetection.LickingLastLog = [zeros(1,vr.PhotoLickDetection.LickingLastLogNumberOfEvents) vr.PhotoLickDetection.Licking];
%% that will increase during recordings - these represent the overall number of licks also outside of the cued environment...
vr.PhotoLickDetection.LickEvents = zeros(vr.TrialSettings.MaxNumerTrials,1) ; % that will increase during recordings for each trial...
%% they only care about the number of licks ONLY in the cued world...
vr.PhotoLickDetection.LickEventsOutSideRewardArea = zeros(vr.TrialSettings.MaxNumerTrials,1,vr.NumberOfTimesRewardEnvironmentPresented) ; % that will increase during recordings for each trial...
vr.PhotoLickDetection.LickEventsInsideRewardArea = zeros(vr.TrialSettings.MaxNumerTrials,vr.NumberOfCues,vr.NumberOfTimesRewardEnvironmentPresented) ;; % that will increase during recordings for each trial...

%%
vr.PhotoLickDetection.LickTimeStamps = []; % that will increase during recordings
vr.PhotoLickDetection.LickPositions = []; % that will increase during recordings

if isfield(vr.worlds{vr.WorldIndexWithReward}.objects.indices,'GoalCue'); 

vr.PhotoLickDetection.LickTimeStampsInsideRewardArea = [];
vr.PhotoLickDetection.LickPositionsInsideRewardArea = [];

vr.PhotoLickDetection.LickTimeStampsOutSideRewardArea = [];
vr.PhotoLickDetection.LickPositionsOutSideRewardArea = [];
end


vr.PhotoLickDetection.VoltageThreshold =  4; % the voltage threshold for detection
vr.PhotoLickDetection.fidLicking = fopen('PhotoLicking.data','w');%creates the file where the behavioural data is stored (better than updating this into the vr structure)...
vr.PhotoLickDetection.fidDetection = fopen('PhotoLickingDetection.data','w');%creates the file where the photo sensor is constantly sampled...may be worth using it later on...

if vr.Setup==2;
   vr.RewardDelivery.TTLDuration = 100;
end

vr.PhotoLickDetection.ReleaseSoundWhileDetecting = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Sound when licking:' ))}) ];;
load gong.mat;
vr.PhotoLickDetection.Sound = y(1:1000);
clear y Fs;

end