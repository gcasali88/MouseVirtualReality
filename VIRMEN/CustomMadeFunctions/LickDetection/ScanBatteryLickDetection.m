function [vr] = ScanBatteryLickDetection(vr);%,device,InputChannel)
%% Voltage sensitive Lick detector...
vr.BatteryLickDetection.tmpV = getsample(vr.BatteryLickDetection.daqSessLickDetection) ; 
vr.BatteryLickDetection.tmptimeStamp = [vr.timeElapsed]; %clock;
vr.BatteryLickDetection.Licking = vr.BatteryLickDetection.tmpV(end) < vr.BatteryLickDetection.VoltageThreshold  ;
%% store the voltage into the ad hoc file...
fwrite(vr.BatteryLickDetection.fidDetection, [vr.BatteryLickDetection.tmptimeStamp vr.BatteryLickDetection.tmpV ],'double');
if vr.BatteryLickDetection.Licking % if there is no minimum voltage skip the logging of the time stamps...
    if vr.BatteryLickDetection.LickEvents(vr.TrialSettings.iTrial) > 0;
       vr.BatteryLickDetection.Licking = abs(vr.BatteryLickDetection.tmptimeStamp(end) - vr.BatteryLickDetection.LickTimeStamps(end,:))> vr.BatteryLickDetection.MinimumTimeDistance; %
    end;
end
vr.BatteryLickDetection.LickEvents(vr.TrialSettings.iTrial) =vr.BatteryLickDetection.LickEvents(vr.TrialSettings.iTrial) +vr.BatteryLickDetection.Licking ;
if vr.BatteryLickDetection.Licking     ; 
vr.BatteryLickDetection.LickTimeStamps = [vr.BatteryLickDetection.LickTimeStamps; vr.BatteryLickDetection.tmptimeStamp(end)];
vr.BatteryLickDetection.LickPositions = [vr.BatteryLickDetection.LickPositions;vr.pos];
fwrite(vr.BatteryLickDetection.fidLicking, [vr.BatteryLickDetection.tmptimeStamp vr.BatteryLickDetection.LickPositions(end) ],'double');
if vr.BatteryLickDetection.ReleaseSoundWhileDetecting
    sound(vr.BatteryLickDetection.Sound);
end
% save the time stamps of the Licks...
end


%delete stuff...
vr.BatteryLickDetection = rmfield(vr.BatteryLickDetection,'tmpV');vr.BatteryLickDetection = rmfield(vr.BatteryLickDetection,'tmptimeStamp');



end