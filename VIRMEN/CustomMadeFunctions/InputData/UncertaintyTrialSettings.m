function [vr] = UncertaintyTrialSettings(vr)
%Creates basic trial data to be used elsewhere

%World variables used for transformations
vr.trackLength = eval(vr.exper.variables.floorLength);
vr.TrialSettings.iTrial = 1;
vr.NewTrialStarted = 0;

vr.TeletransportStartAtWhichLocation = 'StartOfStartTunnel' ;
vr.TeletransportEndAtWhichLocation = 'MiddleOfEndTunnel' ;

vr.StartOfStartTunnel = 0 ;
vr.MiddleOfEndTunnel = 1000;


vr.RewardLocation = eval(vr.exper.variables.Cuey);

%When to stop the trial
vr.RewardMovementOnset = str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt,'Reward Speed onset:' ))}) ;    %Reward where the speed onset occurs...

vr.TrialSettings.MaxNumerTrials = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))})];
vr.TrialSettings.MaxLengthOfTrial = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))})];
vr.BackGroundColor = vr.worlds{vr.currentWorld}.backgroundColor;
vr.TrialSettings.NumberOfCues = 1;
%Levels of Uncertainty created through a random number generator centred
%around mean 0
% vr.TrialSettings.LowUncertainty = [2.5.*randn(1,100)+0]; %SD 2.5 range~7
% vr.TrialSettings.HighUncertainty = [5.*randn(1,100)+0]; %SD 5 range ~22

%Timestamp for when they enter the black room
vr.HoldingRoom.ts = [];
vr.MaxDurationOfEachTrial = 3 * 60; % seconds
vr.NewTrialTs = [0];

vr.HoldingRoom.ts = [];
vr.BlackScreen = 0;
vr.BlackScreenTs = [];
vr.BlackScreenTimeOut = 5;

vr.WhiteScreen = 0;
vr.WhiteScreenTs = [];
vr.WhiteScreenTimeOut = 10;

vr.TaskSolved = zeros(vr.TrialSettings.MaxNumerTrials,1);


vr.LickingActiveConditionProbabilityTimeWindows = [0 : (vr.TrialSettings.MaxLengthOfTrial/ vr.LickingActiveConditionProbabilityPartitions) : vr.TrialSettings.MaxLengthOfTrial ] ;


end

