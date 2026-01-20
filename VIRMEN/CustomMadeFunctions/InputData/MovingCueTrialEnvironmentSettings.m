function [ vr ] = MovingCueTrialEnvironmentSettings( vr )
%% Sets props useful for environments...
vr.NumberOfTimesRewardEnvironmentPresented = 1;

[ vr ] = SetTrialEnvironment( vr );
% Environments present...(atm not used, may turn out useful...)
% vr.EnvironmentSettings.Evironments = {'Track' };
% vr.EnvironmentSettings.LabelEnvironment = [1 ];

vr.GoalCueIndices = vr.worlds{vr.WorldIndexWithReward}.objects.vertices(vr.worlds{vr.WorldIndexWithReward}.objects.indices.GoalCue,:);
vr.worlds{vr.WorldIndexWithReward}.surface.visible(vr.GoalCueIndices(1):vr.GoalCueIndices(2)) = false;
vr = rmfield(vr,'GoalCueIndices');
end