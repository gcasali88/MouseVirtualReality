
function vr = RunTeletransportationTrainingEnvironment(vr)
%% function controlling movements in Training environment...
%vr.NewTrialStarted= 0;




% if vr.DetectLicking & vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) >=  vr.MaxNumberOfLicks  &    vr.currentWorld == vr.WorldIndexWithReward;
% 
%     vr.WhiteWallTimeOnset = [ vr.WhiteWallTimeOnset;vr.timeElapsed];
%     vr.WhiteWallPosOnset = [ vr.WhiteWallPosOnset;vr.pos];
%     vr.currentWorld=2;
%     vr.position(2)=0;vr.dp=0;
%     vr.pos = vr.position(2);vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];
%     fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2) vr.AssignedEnvironment(end) vr.TrialSettings.iTrial]','double');
% 
% 
% elseif     vr.currentWorld==2 
%     if  abs(vr.WhiteWallTimeOnset(end) - vr.timeElapsed) < vr.WhiteWallPunishmentTimeLenght ; %
%     vr.position(2)=0;vr.dp=0;
%     vr.pos = vr.position(2);vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];
%     fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2) vr.AssignedEnvironment(end) vr.TrialSettings.iTrial]','double');
%     else %% punishment finished...
%         
%     vr.currentWorld=1;
%     vr.position(2)=0;vr.dp=0; vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;
%     end
% end        
    
if vr.NewTrialStarted ; 
    %% Send to start...
       vr.position(2)=0;vr.dp=0;   vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;  vr.currentWorld=vr.WorldIndexWithReward;; vr.NewTrialStarted = 0 ;
        vr.BlackScreen = 0 ;
        vr.WhiteScreen = 0 ;
       vr.worlds{vr.currentWorld}.surface.colors  =   vr.NewTrialStartingColors ; 
       vr.NewTrialTs = [vr.NewTrialTs;vr.timeElapsed];
elseif ~vr.BlackScreen && ~vr.NewTrialStarted  && vr.position(2)+vr.dp(2) > max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y);
    %% Send to start...
       %vr.position(2)=0;vr.dp=0; vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;
       %vr.NewTrialStarted= 1;
       vr.BlackScreen =1 ;
       vr.BlackScreenTs = [vr.timeElapsed];    

elseif ~vr.NewTrialStarted && vr.position(2)+vr.dp(2) < min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.BackWall}.y);
       % This is the timestamp where a new trial starts, use it for re-set
       % the DAQ sessions... may help avoid the stupd legacy-based bug.
       vr.NewTrialStarted= 1;  %%       vr.position(2)=0;vr.dp=0;   vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;;
end   
   
   
    if vr.BlackScreen || vr.WhiteScreen
       vr.dp(2) = 0;
       vr.speed(2) = 0;
    end
    
    vr.pos = vr.position(2);
    %vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];
    vr.AssignedEnvironment=[vr.currentWorld];



%fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2) vr.AssignedEnvironment(end) vr.TrialSettings.iTrial]','double');
    [ vr] = LogBehaviouralData(vr );


end
