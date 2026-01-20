function vr = BatteryLickDetectionSettings(vr)

vr = SetBatteryLickDetection(vr);

vr.BatteryLickDetection.MinimumTimeDistance = 1; % Seconds (if the voltage is higher than threshold within minimum temporal lag is not stored as additional licking event...
vr.BatteryLickDetection.Licking = 0; % that will increase during recordings
vr.BatteryLickDetection.LickEvents = zeros(vr.TrialSettings.MaxNumerTrials,1) ; % that will increase during recordings for each trial...

vr.BatteryLickDetection.LickTimeStamps = []; % that will increase during recordings
vr.BatteryLickDetection.LickPositions = []; % that will increase during recordings
vr.BatteryLickDetection.VoltageThreshold =  1; % the voltage threshold for detection
vr.BatteryLickDetection.fidLicking = fopen('BatteryLicking.data','w');%creates the file where the behavioural data is stored (better than updating this into the vr structure)...
vr.BatteryLickDetection.fidDetection = fopen('BatteryLickingDetection.data','w');%creates the file where the Battery sensor is constantly sampled...may be worth using it later on...
%vr.BatteryLickDetection.tmpV=[];
%vr.BatteryLickDetection.tmptimeStamp=[];


vr.BatteryLickDetection.ReleaseSoundWhileDetecting = 1;
load gong.mat;
vr.BatteryLickDetection.Sound = y(1:1000);
clear y Fs;

end