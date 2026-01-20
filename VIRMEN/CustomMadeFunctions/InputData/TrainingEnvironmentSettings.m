function [ vr ] =TrainingEnvironmentSettings( vr )
%% Sets props useful for environments...
% Environments present...(atm not used, may turn out useful...)
vr.WorldNameWithReward = 'TrainingWorld';
vr.NumberOfTimesRewardEnvironmentPresented = 1;
[ vr ] = SetTrialEnvironment( vr );
end