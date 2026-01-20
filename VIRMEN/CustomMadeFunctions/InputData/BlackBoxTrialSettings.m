function [vr ] = BlackBoxTrialSettings(vr)
%% Behaviour information...
if strcmp(getenv('COMPUTERNAME'),'DESKTOP-EGHM5PR');
    vr.Setup = 2;
    vr.Path = ['C:\Users\Giulio\Documents\'];

elseif strcmp(getenv('COMPUTERNAME'),'DESKTOP-MLE6SKL');
    vr.Setup = 1;
    vr.Path = ['C:\Users\VR1\Documents\'];
elseif strcmp(getenv('COMPUTERNAME'),'8V25CD2');
    vr.Setup = 3;
else
    vr.Setup = 4;
end
vr.Path = ['C:\Users\Giulio\Documents\'];
vr.DirectoryName = [vr.Path vr.Experiment '\'] ; 
mkdir(vr.DirectoryName);
cd(vr.DirectoryName) ;
vr=InsertBehaviourRequired(vr);
vr.DetectLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Detect licking:'))}) ];
vr.LickingActiveConditionProbability = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Licking active condition trial (Prob):'))}) ];
vr.MaxNumberOfLicks = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Max number of licks:' ))}) ];
vr.RewardWindowWidth = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Reward Window Width:' ))}) ];
if strcmp(vr.Experiment,'Multicompartment');
vr.DiscriminateRewardedAreas = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Discriminate the rewarded areas:' ))}) ];
end;

 
vr.RewardIfLicking = rand(1,1)< vr.LickingActiveConditionProbability ;%% Specify a bunch of props such number of trials ecc...
vr.TrialSettings.movementFunctionAfterPause = vr.exper.movementFunction;
vr.exper.movementFunction = vr.exper.movementFunction;%vr.TrialSettings.movementFunctionAfterPause;
%vr.experimentEnded= ~strcmp(vr.exper.worlds{vr.currentWorld}.name,'FirstIntermediatePipe');
vr.TrialSettings.MaxNumerTrials = 1;% str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))}) ;;           %sets the number of trials...
vr.TrialSettings.iTrial =0 ;                  %is updated everytime is teletransported back at the pos = 0;
%vr.TrialSettings.InterTrialStopMean = 5;      %pause lenght in time...
%vr.TrialSettings.InterTrialStopSigma = .1;    %pause lenght in time...
%vr.TrialSettings.InterTrialStop = normrnd(vr.TrialSettings.InterTrialStopMean,vr.TrialSettings.InterTrialStopSigma,vr.TrialSettings.MaxNumerTrials ,1); % in seconds...
vr.TimeStampsAcrossTrials =[];  %every time a new trial is begun the time stamp of it is stored
vr.RewardMovementOnset = str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt,'Reward Speed onset:' ))}) ;    %Reward where the speed onset occurs...
vr.RewardMovementSpeedThreshold = 4;    %Minimum speed to elicit reward...
vr.MaxNumberRewardsPerTrial = 50;
vr.MaxTrialLength = 60;%str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))}) ;
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

end