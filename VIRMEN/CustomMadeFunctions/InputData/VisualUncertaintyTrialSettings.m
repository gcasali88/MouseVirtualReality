function [vr] = VisualUncertaintyTrialSettings(vr)
%Creates basic trial data to be used elsewhere

%World variables used for transformations
eval(['vr.trackLength = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height ;' ]);   %eval(vr.exper.variables.floorLength);
vr.TrialSettings.iTrial = 1;
vr.NewTrialStarted = 0;
vr.TeletransportStartAtWhichLocation = 'MiddleOfStartTunnel' ;
vr.TeletransportEndAtWhichLocation = 'StartOfEndTunnel' ;

%vr.worlds{vr.currentWorld}.surface.visible(vr.worlds{vr.currentWorld}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.GoalCue,1):vr.worlds{vr.currentWorld}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.GoalCue,2)) = false;
vr.RewardLocation = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y ;
%vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.elevation = -50;

if isfield(vr.worlds{vr.currentWorld}.objects.indices,'StartPipe')
        vr.StartOfStartTunnel = min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.StartPipe}.y);
        vr.MiddleOfStartTunnel = nanmean(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.StartPipe}.y);
        vr.EndOfStartTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.StartPipe}.y);
else
        eval(['vr.StartOfStartTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
        eval(['vr.MiddleOfStartTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
        eval(['vr.EndOfStartTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
end


if isfield(vr.worlds{vr.currentWorld}.objects.indices,'EndPipe')
    vr.StartOfEndTunnel = min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);     
    vr.MiddleOfEndTunnel = nanmean(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
    vr.EndOfEndTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
else
    
    eval(['vr.StartOfEndTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
    eval(['vr.MiddleOfEndTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
    eval(['vr.EndOfEndTunnel = max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.y) + vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height/2; ' ] );    %% it was ...
end

vr.BackGroundColor = vr.exper.worlds{vr.currentWorld}.backgroundColor ;

%When to stop the trial
vr.RewardMovementOnset = str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt,'Reward Speed onset:' ))}) ;    %Reward where the speed onset occurs...

vr.TrialSettings.MaxNumerTrials = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))})];
vr.TrialSettings.MaxLengthOfTrial = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))})];

vr.TrialSettings.NumberOfCues = 1;

%%vr.RewardLocation = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y ; %% IT WAS...

vr.RewardLocation = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y ;

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
