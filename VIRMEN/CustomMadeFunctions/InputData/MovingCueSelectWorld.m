function [vr] = MovingCueSelectWorld(vr)
%Choses which world within the experiment to run
    %based on info provided in 'InsertTestData' 
    
%because all worlds are reward worlds:
vr.WorldNameWithReward = vr.NameOfTheWorld;

[ vr ] = SetTrialEnvironment( vr ); 
%SetTrialEnvironments labels worlds as indexes


%Worlds  = {'A','B','C' 'HoldingRoom'}  

vr.WorldIndex = find(strcmp(vr.EnvironmentSettings.Evironments,vr.NameOfTheWorld));
vr.WorldIndexWithReward = vr.WorldIndex;
vr.currentWorld = vr.WorldIndex ; 
end



