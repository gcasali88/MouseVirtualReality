function [vr] = ScanPhotoLickDetection(vr);%,device,InputChannel)
%% Voltage sensitive Lick detector...
vr.PhotoLickDetection.tmpV = getsample(vr.PhotoLickDetection.daqSessLickDetection) ; 
vr.PhotoLickDetection.tmptimeStamp = [vr.timeElapsed]; %clock;


if strcmp(vr.PhotoLickDetection.Model,'5V')
                    vr.PhotoLickDetection.LickTriggered = vr.PhotoLickDetection.tmpV(end) > vr.PhotoLickDetection.VoltageThreshold ;
elseif      strcmp(vr.PhotoLickDetection.Model,'12V')
                    vr.PhotoLickDetection.LickTriggered = vr.PhotoLickDetection.tmpV(end) < vr.PhotoLickDetection.VoltageThreshold ;
end

%disp([num2str(vr.PhotoLickDetection.tmpV(end))])
vr.PhotoLickDetection.Licking = vr.PhotoLickDetection.LickTriggered   ;
vr.PhotoLickDetection.LickingLastLog = [vr.PhotoLickDetection.LickingLastLog(end -((vr.PhotoLickDetection.LickingLastLogNumberOfEvents)-1)) vr.PhotoLickDetection.Licking ] ;
vr.PhotoLickDetection.Licking  = diff(vr.PhotoLickDetection.LickingLastLog)>0;
%% store the voltage into the ad hoc file...
fwrite(vr.PhotoLickDetection.fidDetection, [vr.PhotoLickDetection.tmptimeStamp vr.PhotoLickDetection.tmpV ],'double');
if vr.PhotoLickDetection.Licking % if there is no minimum voltage skip the logging of the time stamps...
    if vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial) > 0;
       vr.PhotoLickDetection.Licking = abs(vr.PhotoLickDetection.tmptimeStamp(end) - vr.PhotoLickDetection.LickTimeStamps(end,:))> vr.PhotoLickDetection.MinimumTimeDistance; %
    end;
end
%% Store the logs all together...
if vr.TrialSettings.iTrial <= numel(vr.PhotoLickDetection.LickEvents)
    vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial) =vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial) +vr.PhotoLickDetection.Licking ;
end
%LickEventsOutSideRewardArea
%LickEventsInsideRewardArea


if vr.PhotoLickDetection.Licking     ; 
vr.PhotoLickDetection.LickTimeStamps = [vr.PhotoLickDetection.LickTimeStamps; vr.PhotoLickDetection.tmptimeStamp(end)];
vr.PhotoLickDetection.LickPositions = [vr.PhotoLickDetection.LickPositions;vr.pos];
%fwrite(vr.PhotoLickDetection.fidLicking, [vr.PhotoLickDetection.tmptimeStamp vr.PhotoLickDetection.LickPositions(1:end) ],'double');
fwrite(vr.PhotoLickDetection.fidLicking, [vr.PhotoLickDetection.tmptimeStamp vr.pos(1:end) ],'double');

if vr.PhotoLickDetection.ReleaseSoundWhileDetecting
    sound(vr.PhotoLickDetection.Sound);
end
% save the time stamps of the Licks...
end



if isfield(vr,'InGoalLocation')
    if  vr.InRewardArea
                      if  vr.TrialSettings.iTrial <= numel(vr.PhotoLickDetection.LickEvents)
                            eval(['vr.PhotoLickDetection.LickEventsInsideRewardArea(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.' vr.EnvironmentSettings.Evironments{vr.WorldIndexWithReward} ') = vr.PhotoLickDetection.LickEventsInsideRewardArea(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.' vr.EnvironmentSettings.Evironments{vr.WorldIndexWithReward} ') + vr.PhotoLickDetection.Licking ;' ]);
                      end            
           if vr.PhotoLickDetection.Licking
           vr.PhotoLickDetection.LickTimeStampsInsideRewardArea = [vr.PhotoLickDetection.LickTimeStampsInsideRewardArea ; vr.timeElapsed];
           vr.PhotoLickDetection.LickPositionsInsideRewardArea = [vr.PhotoLickDetection.LickPositionsInsideRewardArea ; vr.pos];

           end
    elseif  vr.InRewardArea==0 & vr.currentWorld == vr.WorldIndexWithReward;    
                       if  vr.TrialSettings.iTrial <= numel(vr.PhotoLickDetection.LickEvents)
                            eval(['vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial,1,vr.EnvironmentsVisited.' vr.EnvironmentSettings.Evironments{vr.WorldIndexWithReward} ') = vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial,1,vr.EnvironmentsVisited.' vr.EnvironmentSettings.Evironments{vr.WorldIndexWithReward} ') + vr.PhotoLickDetection.Licking ;' ]);
                       end
            if vr.PhotoLickDetection.Licking
           vr.PhotoLickDetection.LickTimeStampsOutSideRewardArea = [vr.PhotoLickDetection.LickTimeStampsOutSideRewardArea ; vr.timeElapsed];
           vr.PhotoLickDetection.LickPositionsOutSideRewardArea = [vr.PhotoLickDetection.LickPositionsOutSideRewardArea ; vr.pos];
           end
    
    end
end    
%delete stuff...
%vr.PhotoLickDetection = rmfield(vr.PhotoLickDetection,'tmpV');
vr.PhotoLickDetection = rmfield(vr.PhotoLickDetection,'tmptimeStamp');



end