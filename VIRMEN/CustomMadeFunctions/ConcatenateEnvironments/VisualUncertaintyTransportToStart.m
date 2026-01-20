function [ vr ] = VisualUncertaintyTransportToStart( vr )
%Detects when mouse is at end of track and then transports back to start
if isempty(vr.pos);
    vr.pos = vr.position(2);
end;

       
    
if vr.NewTrialStarted ; 
    %% Send to start...
        eval(['vr.position(2) = vr.' vr.TeletransportStartAtWhichLocation '; ; ' ]);
        vr.dp=0;   
        vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;  
        vr.currentWorld = vr.WorldIndexWithReward;; 
        vr.NewTrialStarted = 0 ;
        vr.BlackScreen =  vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials ; % Added to prevent freezing of the scene at the end of max number of trials.
        % it was vr.BlackScreen = 0 ;
        vr.WhiteScreen = 0 ;
        vr.worlds{vr.currentWorld}.surface.colors  =   vr.NewTrialStartingColors ;
        vr.NewTrialTs = vr.timeElapsed;
        
elseif eval(['~vr.BlackScreen && ~vr.NewTrialStarted  && vr.position(2) > vr.' vr.TeletransportEndAtWhichLocation ' ; ' ] )
    %% Send to start...
       
       eval(['vr.pos = vr.' vr.TeletransportStartAtWhichLocation '; ' ] );
       eval(['vr.position(2) = vr.' vr.TeletransportStartAtWhichLocation '; ' ] ); 
       vr.BlackScreen =1 ;
       vr.BlackScreenTs = [vr.timeElapsed];    

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














% 
% 
% 
% 
% 
% 
% if vr.position(2) <=  max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y) && ~isnan(vr.pos)
%     vr.pos = vr.position(2);
% else
%     vr.pos = NaN;
%     %vr.position(2) = 0;
% end
% 
% 
% 
% if isnan(vr.pos);%-1 & vr.currentWorld ~= find(strcmp(vr.EnvironmentSettings.Evironments, 'HoldingRoom' ));
%     if  unique(vr.worlds{vr.currentWorld}.surface.visible(FindExtremesOfArray( reshape(  vr.worlds{vr.currentWorld}.objects.vertices(1: vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall,:),[],1)))) ==1;
%         vr.HoldingRoom.ts = vr.timeElapsed;
%         vr.worlds{vr.currentWorld}.surface.visible(FindExtremesOfArray( reshape( vr.worlds{vr.currentWorld}.objects.vertices(1: vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall,:),[],1))) = 0 ;
%         vr.HoldingRoom.RandomDelay= ((6-2).*rand(1,1)+2);
%     end 
%         vr.dp(1,:) = 0;
%         vr.velocity(1,:) = 0;
%         vr.movement(1,:) = 0;
%       
%     if  vr.timeElapsed-vr.HoldingRoom.ts > vr.HoldingRoom.RandomDelay   
%         vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
%         vr.TrialSettings.iTrial = vr.TrialSettings.iTrial + 1;
%         vr.pos =0 ;
%         vr.position(2)= 0;
%     end
% 
% end

end


