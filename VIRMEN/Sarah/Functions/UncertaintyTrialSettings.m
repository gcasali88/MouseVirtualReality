function [vr] = UncertaintyTrialSettings(vr)
%Creates basic trial data to be used elsewhere

%World variables used for transformations
vr.trackLength = eval(vr.exper.variables.floorLength);
vr.TrialSettings.iTrial = 0


%When to stop the trial

vr.TrialSettings.MaxNumberOfTrials = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Number of Trials:'))})];
vr.TrialSettings.MaxLengthOfTrial = [str2double(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Max Trial Length (min):'))})];

%Levels of Uncertainty created through a random number generator centred
%around mean 0
vr.TrialSettings.LowUncertainty = [2.5.*randn(1,100)+0]; %SD 2.5 range~7
vr.TrialSettings.HighUncertainty = [5.*randn(1,100)+0]; %SD 5 range ~22

end

