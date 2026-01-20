function [ vr ] = MultiCompartmentEnvironmentSettings( vr )
%% Sets props useful for environments...
% Environments present...(atm not used, may turn out useful...)
vr.WorldNameWithReward = 'B';
vr.NumberOfTimesRewardEnvironmentPresented = 2;
[ vr ] = SetTrialEnvironment( vr );

vr.RewardedCuesIntoRepeatedCompartments = [1,2];

end