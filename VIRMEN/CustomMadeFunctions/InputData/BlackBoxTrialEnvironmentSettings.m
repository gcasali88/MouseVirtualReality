function [ vr ] = BlackBoxTrialEnvironmentSettings( vr )
%% Sets props useful for environments...
vr.WorldNameWithReward = 'BlackBox';
vr.NumberOfTimesRewardEnvironmentPresented = 1;

[ vr ] = SetTrialEnvironment( vr );


%% If the active condition for licking is greater than 0, turns the black ground color to red.
%Otherwise keep it black to habitutate animals in the dark.

if vr.LickingActiveConditionProbability > 0 | vr.RewardMovementOnset ;
    vr.worlds{vr.currentWorld}.backgroundColor = [ 0 0 1] ;
    vr.worlds{vr.currentWorld}.surface.visible(:) = false;
else
    vr.worlds{vr.currentWorld}.backgroundColor = [ 0 0 0] ;
        vr.worlds{vr.currentWorld}.surface.visible(:) = false;

end

end