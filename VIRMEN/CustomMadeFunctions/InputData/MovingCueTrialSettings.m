function [vr] = VisualUncertaintyTrialSettings(vr)
%Creates basic trial data to be used elsewhereb

%World variables used for transformations
eval(['vr.trackLength = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Floor_' num2str(vr.currentWorld) '}.height ;' ]);   %eval(vr.exper.variables.floorLength);
vr.TrialSettings.iTrial = 1;
vr.RewardLocation = 400;

%When to stop the trial
vr.RewardMovementOnset = str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt,'Reward Speed onset:' ))}) ;    %Reward where the speed onset occurs...

vr.TrialSettings.MaxNumerTrials = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))})];
vr.TrialSettings.MaxLengthOfTrial = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))})];

vr.TrialSettings.NumberOfCues = 1;
vr.HoldingRoom.ts = [];

    

vr.TrialSettings.CueSize = 60;
vr.TrialSettings.HalfCueSize = vr.TrialSettings.CueSize/2;
end
