function [vr] = SaveLickDetection(vr);%,device,InputChannel)
%% Voltage sensitive Lick detector...
fwrite(vr.LickDetection.fidDetection, [vr.timeElapsed vr.LickDetection.t(1)]','double');

% set(vr.LickDetection.daqSessLickDetection,'SamplesPerTrigger',vr.LickDetection.Duration, vr.LickDetection.SampleRate
% .sampleRate+1) ;

% start(vr.LickDetection.daqSessLickDetection);
% peekdata(vr.LickDetection.daqSessLickDetection,50)


%start(vr.LickDetection.daqSessLickDetection);data = peekdata(vr.LickDetection.daqSessLickDetection,1);

%[data] = getdata(vr.LickDetection.daqSessLickDetection);
%vr.LickDetection.tmpV = diff(nanmean(data)) ;
  %%diff(getsample(vr.LickDetection.daqSessLickDetection) ); 
%fwrite(vr.LickDetection.fidDetection, [vr.timeElapsed t]','double');

vr.LickDetection.tmptimeStamp = vr.timeElapsed; %clock;
vr.LickDetection.Licking = vr.LickDetection.t(1) > vr.LickDetection.Threshold;
if vr.LickDetection.Licking % if there is no minimum voltage skip the logging of the time stamps...
    if vr.LickDetection.LickEvents > 0;
    %vr.LickDetection.LickTimeStamps=[vr.LickDetection.LickTimeStamps;vr.LickDetection.tmptimeStamp];
     
    %vr.LickDetection.Licking = abs(etime(vr.LickDetection.tmptimeStamp,vr.LickDetection.LickTimeStamps(end,:)))> vr.LickDetection.MinimumTimeDistance; %
    vr.LickDetection.Licking = abs(vr.LickDetection.tmptimeStamp - vr.LickDetection.LickTimeStamps(end,:))> vr.LickDetection.MinimumTimeDistance; %
    end;
end
vr.LickDetection.LickEvents =vr.LickDetection.LickEvents +vr.LickDetection.Licking ;
if vr.LickDetection.Licking     ; 
vr.LickDetection.LickTimeStamps = [vr.LickDetection.LickTimeStamps; vr.LickDetection.tmptimeStamp];
vr.LickDetection.LickPositions  = [vr.LickDetection.LickPositions;vr.pos];
fwrite(vr.LickDetection.fidLicking, [vr.LickDetection.LickTimeStamps(end) vr.LickDetection.LickPositions(end) vr.LickDetection.LickEvents]','double');
end

%delete stuff...
%vr.LickDetection = rmfield(vr.LickDetection,'tmpV');
vr.LickDetection = rmfield(vr.LickDetection,'tmptimeStamp');



end