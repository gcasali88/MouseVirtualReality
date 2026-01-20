function [ vr ] = UncertaintyTransportToStart( vr )
%Detects when mouse is at end of track and then transports back to start

if isempty(vr.pos);
    vr.pos = vr.position(2);
    vr.PreviousDp = vr.dp;
else
    vr.pos = vr.position(2);
end;

if vr.NewTrialStarted ; 
    %
        eval(['vr.position(2) = vr.' vr.TeletransportStartAtWhichLocation '; ; ' ]);
        eval(['vr.PositionPI.pos  = vr.' vr.TeletransportStartAtWhichLocation '; ; ' ]);
        vr.dp(2)=0;   
        vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;  
        vr.currentWorld = vr.WorldIndexWithReward;; 
        vr.NewTrialStarted = 0 ;
        vr.BlackScreen = 0 ;
        vr.WhiteScreen = 0 ;
        vr.worlds{vr.currentWorld}.surface.colors  =   vr.NewTrialStartingColors ;
        vr.NewTrialTs = vr.timeElapsed;
elseif eval(['~vr.BlackScreen && ~vr.NewTrialStarted  && vr.position(2) > vr.' vr.TeletransportEndAtWhichLocation ' ; ' ] )
    %% Send to black...
       
       eval(['vr.pos = vr.' vr.TeletransportStartAtWhichLocation '; ' ] );
       eval(['vr.position(2) = vr.' vr.TeletransportStartAtWhichLocation '; ' ] ); 
       eval(['vr.PositionPI.pos  = vr.' vr.TeletransportStartAtWhichLocation '; ; ' ]);
       vr.dp(2) = 0;
       vr.PreviousDp(2) = 0;
       vr.velocity(:) = 0;
       vr.BlackScreen =1 ;
       vr.BlackScreenTs = [vr.timeElapsed];    
       
elseif vr.BlackScreen & ~vr.NewTrialStarted
       %% Keep to start
       vr.dp(:) = 0;
       vr.PreviousDp(2) = 0;
       vr.velocity(:) = 0;
       
elseif vr.WhiteScreen
       vr.dp(:) = 0;
       vr.PreviousDp(2) = 0;
       vr.velocity(:) = 0;
end    
        
        
        
        
    
    
    

% if vr.position(2) >= vr.trackLength-1 & vr.currentWorld ~= find(strcmp(vr.EnvironmentSettings.Evironments, 'HoldingRoom' ));
%     vr.currentWorld = find(strcmp(vr.EnvironmentSettings.Evironments, 'HoldingRoom'));
%     vr.HoldingRoom.ts = vr.timeElapsed;
%     vr.HoldingRoom.RandomDelay= ((6-2).*rand(1,1)+2);
%     vr.position(2) = 0; %move animal to start
%     vr.pos = 0;
%     vr.PositionPI.pos = 0; %set PI value to start
% end
% if vr.currentWorld == find(strcmp(vr.EnvironmentSettings.Evironments, 'HoldingRoom' ));
%    vr.position(2) = 0; %move animal to start
%    vr.PositionPI.pos = 0; %set PI value to start
%    vr.pos = 0; %set PI value to start
% 
%     if   vr.timeElapsed-vr.HoldingRoom.ts > vr.HoldingRoom.RandomDelay;
%         vr.currentWorld = find(strcmp(vr.EnvironmentSettings.Evironments,vr.NameOfTheWorld));
%         % vr.position(2) = 0; %move animal to start
%         % vr.PositionPI.pos = 0; %set PI value to start
%         vr.TrialSettings.iTrial = vr.TrialSettings.iTrial + 1;
%   end
% end


[ vr] = LogBehaviouralData(vr );



end


