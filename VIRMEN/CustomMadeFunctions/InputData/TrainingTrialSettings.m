function [vr ] = TrainingTrialSettings(vr)
%% Specify a bunch of props such number of trials ecc...
vr.TrialSettings.movementFunctionAfterPause = vr.exper.movementFunction;
vr.exper.movementFunction = vr.TrialSettings.movementFunctionAfterPause;
%vr.experimentEnded= ~strcmp(vr.exper.worlds{vr.currentWorld}.name,'FirstIntermediatePipe');
vr.TrialSettings.MaxNumerTrials = str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))}) ;;           %sets the number of trials...
vr.TrialSettings.iTrial =0 ;                  %is updated everytime is teletransported back at the pos = 0;
%vr.TrialSettings.InterTrialStopMean = 5;      %pause lenght in time...
%vr.TrialSettings.InterTrialStopSigma = .1;    %pause lenght in time...
%vr.TrialSettings.InterTrialStop = normrnd(vr.TrialSettings.InterTrialStopMean,vr.TrialSettings.InterTrialStopSigma,vr.TrialSettings.MaxNumerTrials ,1); % in seconds...



vr.RewardAreaLimits = [vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height,...
vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y+vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height];

vr.TimeStampsAcrossTrials =[];  %every time a new trial is begun the time stamp of it is stored
vr.RewardMovementOnset = str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt,'Reward Speed onset:' ))}) ;    %Reward where the speed onset occurs...
vr.RewardMovementSpeedThreshold = 4;    %Minimum speed to elicit reward...
vr.MaxNumberRewardsPerTrial = 50;
vr.MaxTrialLength = str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))}) ;
vr.MaxLapLength = [ vr.MaxTrialLength * 60 ] ; % (seconds) Time to complete the lap, otherwise white wall.
vr.NewTrialTs = [0];

vr.WhiteWallTimeOnset = [];
vr.WhiteWallPosOnset = [];
vr.WhiteWallPunishmentTimeLenght = [5];

vr.BlackScreen = 0;
vr.BlackScreenTs = [];
vr.BlackScreenTimeOut = 5;

vr.WhiteScreen = 0;
vr.WhiteScreenTs = [];
vr.WhiteScreenTimeOut = 5;

vr.TaskSolved = zeros(vr.TrialSettings.MaxNumerTrials,1);
end