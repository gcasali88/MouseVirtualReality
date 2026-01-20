function [ vr ] = UncertaintylTrialEnvironmentSettings( vr )
%% Sets props useful for environments...
vr.NumberOfTimesRewardEnvironmentPresented = 1;

[ vr ] = SetTrialEnvironment( vr );
% Environments present...(atm not used, may turn out useful...)
% vr.EnvironmentSettings.Evironments = {'Track' };
% vr.EnvironmentSettings.LabelEnvironment = [1 ];
end