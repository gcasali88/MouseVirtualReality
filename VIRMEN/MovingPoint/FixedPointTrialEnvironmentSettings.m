function [ vr ] = FixedPointTrialEnvironmentSettings( vr )
%% Sets props useful for environments...
vr.WorldNameWithReward = 'World1';
vr.NumberOfTimesRewardEnvironmentPresented = 1;
vr.WhichCueLocation=1;   
[ vr ] = SetTrialEnvironment( vr );
% Environments present...(atm not used, may turn out useful...)
% vr.EnvironmentSettings.Evironments = {'Track' };
% vr.EnvironmentSettings.LabelEnvironment = [1 ];

end