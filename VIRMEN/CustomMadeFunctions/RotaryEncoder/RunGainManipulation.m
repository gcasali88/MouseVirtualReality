
function vr = RunGainManipulation(vr)
%% Code which carries gain manipulation and stores the data...
vr.GainManipulation.PreviousValue = vr.GainManipulation.Value ;

if vr.timeElapsed - vr.GainManipulation.ts(end) > vr.GainManipulation.ChangeInGainOffset 
% generates one more sample a second ahead...
if strcmp(vr.GainManipulation.Method , 'FromLognormal') ;
vr.GainManipulation.NextValue = random(vr.GainManipulation.RandomGenerator,vr.GainManipulation.NumberToGenerate ,1  ); %lognrnd(log(vr.GainManipulation.Mean),vr.GainManipulation.Gain, numel(vr.GainManipulation.RandomTimes), 1)
vr.GainManipulation.NextTimes = [ vr.GainManipulation.times(end)+vr.GainManipulation.Resolution^-1] + [0 : vr.GainManipulation.ChangeInGainOffset : vr.GainManipulation.ChangeInGainOffset *vr.GainManipulation.NumberToGenerate] ; 
vr.GainManipulation.NextValue = [vr.GainManipulation.Value ; vr.GainManipulation.NextValue] ;
%% On 15/08/2018 GC corrected this...
F = griddedInterpolant([vr.GainManipulation.times vr.GainManipulation.NextTimes], log([vr.GainManipulation.Gains vr.GainManipulation.NextValue']) ,vr.GainManipulation.InterpolationMethod) ; 
vr.GainManipulation.times = [vr.GainManipulation.times vr.GainManipulation.NextTimes(1) :1/vr.GainManipulation.Resolution : vr.GainManipulation.NextTimes(end)]; 
vr.GainManipulation.Gains = exp(F(vr.GainManipulation.times));clear F;

elseif  strcmp(vr.GainManipulation.Method , 'FromNormal') ;
vr.GainManipulation.NextValue = exp(random(vr.GainManipulation.RandomGenerator,vr.GainManipulation.NumberToGenerate ,1  )); %lognrnd(log(vr.GainManipulation.Mean),vr.GainManipulation.Gain, numel(vr.GainManipulation.RandomTimes), 1)
vr.GainManipulation.NextTimes = [ vr.GainManipulation.times(end)+vr.GainManipulation.Resolution^-1] + [0 : vr.GainManipulation.ChangeInGainOffset : vr.GainManipulation.ChangeInGainOffset *vr.GainManipulation.NumberToGenerate] ; 
vr.GainManipulation.NextValue = [vr.GainManipulation.Value ; vr.GainManipulation.NextValue] ;
%% On 15/08/2018 GC corrected this...
F = griddedInterpolant([vr.GainManipulation.times vr.GainManipulation.NextTimes], log([vr.GainManipulation.Gains vr.GainManipulation.NextValue']) ,vr.GainManipulation.InterpolationMethod) ; 
vr.GainManipulation.times = [vr.GainManipulation.times vr.GainManipulation.NextTimes(1) :1/vr.GainManipulation.Resolution : vr.GainManipulation.NextTimes(end)]; 
vr.GainManipulation.Gains = exp(F(vr.GainManipulation.times));clear F;  
end


%% Before that it was like this...
% F = griddedInterpolant([vr.GainManipulation.times vr.GainManipulation.NextTimes], [ vr.GainManipulation.Gains  vr.GainManipulation.NextValue' ] ) ; 
% vr.GainManipulation.times = [vr.GainManipulation.times vr.GainManipulation.NextTimes(1) :1/vr.GainManipulation.Resolution : vr.GainManipulation.NextTimes(end)]; 
% vr.GainManipulation.Gains = [vr.GainManipulation.Gains   vr.GainManipulation.NextValue' ] ;
% vr.GainManipulation.Gains = F(vr.GainManipulation.times);clear F;
% vr.GainManipulation.SmoothedGains = filtfilt(vr.GainManipulation.G,1,vr.GainManipulation.Gains) ;
end
%% On 15/08/2018 GC corrected this...
%vr.GainManipulation.SmoothedGains(vr.GainManipulation.times < vr.timeElapsed) = [];
vr.GainManipulation.Gains(vr.GainManipulation.times < vr.timeElapsed) = [];
vr.GainManipulation.times(vr.GainManipulation.times < vr.timeElapsed) = [];
[~,vr.GainManipulation.TmpIndex] = min(abs(vr.GainManipulation.times-vr.timeElapsed));
vr.GainManipulation.Value  = unique((vr.GainManipulation.Gains(vr.GainManipulation.TmpIndex)));
% %% Test gain manipulation change
% vr.GainManipulation.Value = vr.GainManipulation.Value + vr.iterations/10 ; 

%% Before that it was like this...
% vr.GainManipulation.SmoothedGains(vr.GainManipulation.times < vr.timeElapsed) = [];
% vr.GainManipulation.Gains(vr.GainManipulation.times < vr.timeElapsed) = [];
% vr.GainManipulation.times(vr.GainManipulation.times < vr.timeElapsed) = [];
% [~,vr.GainManipulation.TmpIndex] = min(abs(vr.GainManipulation.times-vr.timeElapsed));
% vr.GainManipulation.Value  = unique((vr.GainManipulation.SmoothedGains(vr.GainManipulation.TmpIndex)));



    fwrite(vr.GainManipulation.fidSynch, [vr.timeElapsed  vr.GainManipulation.Value vr.GainManipulation.Value],'double');

    %% PIdp at each frame...
    %% GC changed this on 22/11/2018, it was as below...
    %vr.AnimalDisplacement.InstantaneousDisplacement = vr.dp(2) ./ vr.GainManipulation.PreviousValue  ;
    %% and turned into ...
        % it was .... 
        %vr.AnimalDisplacement.InstantaneousDisplacement = vr.dp(2) ./ log(vr.GainManipulation.PreviousValue ) ;
        % now (19/11/2019) changed into by GC...
        vr.AnimalDisplacement.InstantaneousDisplacement = vr.dp(2) ./ (vr.GainManipulation.PreviousValue ) ;
        
    %% PIpos at each frame...
    vr.PositionPI.pos = [vr.PositionPI.pos + vr.PositionPI.PreviousInstantaneousDisplacement];
    ... save those...
    %% it was...fwrite(vr.AnimalDisplacement.fidSynch, [vr.timeElapsed  vr.AnimalDisplacement.InstantaneousDisplacement],'double');
    % and turned into the following on the 19/11/2019 by GC...
    %fwrite(vr.AnimalDisplacement.fidSynch, [vr.timeElapsed  vr.dp(2)./log(vr.GainManipulation.PreviousValue) ],'double');
    % and then corrected into the following...
    fwrite(vr.AnimalDisplacement.fidSynch, [vr.timeElapsed  vr.AnimalDisplacement.InstantaneousDisplacement],'double');
    
    fwrite(vr.PositionPI.fidSynch, [vr.timeElapsed vr.PositionPI.pos],'double');
    % ... then update the previous with the current one...
    vr.PositionPI.PreviousInstantaneousDisplacement = vr.AnimalDisplacement.InstantaneousDisplacement;

    %vr.pos = vr.position(2); 

    vr.PreviousDp = vr.dp;

    
    
end