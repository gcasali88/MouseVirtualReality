function code = MultiCompartmentExperiment
% MultiCompartmentExperiment   Code for the ViRMEn experiment MultiCompartmentExperiment.
%   code = MultiCompartmentExperiment   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr);
%% Specify Saving  data properties;
get_working_pc_and_cd;
vr.Experiment = 'Multicompartment';
vr = InputDataIntoVirmen( vr)  ;  
vr = MultiCompartmentTrialSettings(vr); 
vr = MultiCompartmentEnvironmentSettings( vr );
vr = BehaviourSettings( vr);
daqreset;
%%%%%%%%%%%%%%%%%%%%%%%%%%% DAQ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
%% Set/open DAQ sessions...
%%%%%%%%%%%%%%%% Rotary Encoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(char(vr.TrialSettings.movementFunctionAfterPause ) , 'moveWithRotaryEncoder');vr = RotaryEncoderSettings(vr);end
%%%%%%%%%%%%%%%% Set reward delivery system %%%%%%%%%%%%%%%%%%
vr = RewardDeliverySettings(vr);
%%%%%%%%%%%%%%%% Set licking detector %%%%%%%%%%%%%%%%%%%%%%%%
%vr = LickDetectionSettings(vr);
vr = PhotoLickDetectionSettings(vr);
%%%%%%%%%%%%%%%% Set ephs synch locking         
vr = SynchAxonaSettings(vr);
%%%%%%%%%%%%%%%%%%%%%%%%%% Run Trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set up text boxes
vr.text(1).string = '0';vr.text(1).position = [-.14  0.2];   vr.text(1).size = .05;vr.text(1).color = [1 0 1];   vr.text(1).window = [4];
vr.text(2).string = '0';vr.text(2).position = [-.14  0.1];   vr.text(2).size = .05;vr.text(2).color = [1 0 1];   vr.text(2).window = [4];
vr.text(3).string = '0';vr.text(3).position = [-.14  0.0];   vr.text(3).size = .05;vr.text(3).color = [1 1 0];   vr.text(3).window = [4];
vr.text(4).string = '0';vr.text(4).position = [-.14 -0.1];   vr.text(4).size = .05;vr.text(4).color = [0 1 1];   vr.text(4).window = [4];
vr.text(5).string = '0';vr.text(5).position = [-.14 -0.2];   vr.text(5).size = .05;vr.text(5).color = [1 1 1];   vr.text(5).window = [4];
vr.text(6).string = '0';vr.text(6).position = [-.14 -0.3];   vr.text(6).size = .05;vr.text(6).color = [0 1 0];   vr.text(6).window = [4];
vr.text(7).string = '0';vr.text(7).position = [-.14 -0.4];   vr.text(7).size = .05;vr.text(7).color = [1 0 0];   vr.text(7).window = [4];
vr.text(8).string = '0';vr.text(8).position = [-.14 -0.5];   vr.text(8).size = .05;vr.text(8).color = [1 1 1];   vr.text(8).window = [4];
vr.text(9).string = '0';vr.text(9).position = [-.14 -0.6];   vr.text(9).size = .05;vr.text(9).color = [1 1 0];   vr.text(9).window = [4];
vr.text(10).string = '0';vr.text(10).position = [-.14 0.3];  vr.text(10).size =.05;vr.text(10).color = [1 1 0];  vr.text(10).window =[4];

vr.TrialSettings.iTrial=0;
vr.NewTrialStarted = 0;
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if vr.timeElapsed > vr.MaxTrialLength*60 || vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials ; 
vr.experimentEnded=1;  
end
% if vr.NewTrialStarted;
% daqreset;
% vr = SetPhotoLickDetection(vr);
% vr = SetRewardDelivery(vr);
% vr = SetSynchAxonaSetting(vr);
% [ vr ] = RotaryEncoderSettings( vr );
% [ vr ] = LoadEnvironments(vr);  %resets the visits across compartments...
% end;
   
    %% Run teletransportation across environments...
[ vr] = RunTeletransportationMultiCompartment(vr );

%% Is the animal in the goal related area ?
if isfield(vr.worlds{vr.currentWorld}.objects.indices,'GoalCue') ;
        if ~vr.RewardIfLicking ; %% This is important, it virtually shifts the location of the reward at the extremes of the rewarded area...
       vr.InFirstGoalLocation = ...
        vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(1) && ...
        vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(1) + ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius;
             
        vr.InSecondGoalLocation  = ...
        vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(2) && ...
        vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(2) + ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius;
        
        else
        vr.InFirstGoalLocation = ...
        vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(1) - ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius ...
             && vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(1) + ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius ;
         
        vr.InSecondGoalLocation  = ...
        vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(2) - ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius ...
             && vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y(2) + ...
             vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.radius ;
        
        end
        vr.WhichCueLocation = [ vr.InFirstGoalLocation vr.InSecondGoalLocation ] ;
        
        
        if vr.DiscriminateRewardedAreas    
            eval(['vr.InGoalLocation = vr.WhichCueLocation(vr.RewardedCuesIntoRepeatedCompartments(vr.EnvironmentsVisited.' vr.WorldNameWithReward ')) ; ' ])
        else
            vr.InGoalLocation = sum([ vr.WhichCueLocation ]) >0;
        end
        
else
    vr.InGoalLocation = 0;
end
vr.InRewardArea = vr.InGoalLocation;
%% Scan photo detector...
    if vr.DetectLicking
        [vr] = ScanPhotoLickDetection(vr);% %% Scan lick detection...% if vr.LickDetection.daqSessLickDetection.SamplesAcquired ~= 0% stop(vr.LickDetection.daqSessLickDetection);% [vr] = ScanLickDetection(vr);% start(vr.LickDetection.daqSessLickDetection);% end
 %      [vr] = ScanBatteryLickDetection(vr);
    end
    %% Add Key pressing option...
    vr.ManualReward = ~isnan(vr.keyPressed);
    
%% StartReward if conditions are met....
if  isfield(vr.worlds{vr.currentWorld}.objects.indices,'GoalCue') ;
 if vr.InGoalLocation ;
     if vr.RewardIfLicking ==0;
    vr.reward_condition = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.B)==0 ;
     else
    vr.reward_condition = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.B)==0 & vr.PhotoLickDetection.Licking ;
     end
     else 
   vr.reward_condition = 0;
 end
else
    vr.reward_condition = 0;
end;

if [vr.reward_condition | vr.ManualReward ] && vr.timeElapsed>0 && strcmp((vr.AxonaSynch.daqSessAxonaSynch.Running),'Off') & strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') ;
[vr] = StartReward(vr);
if vr.reward_condition
vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.B) = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,find(vr.WhichCueLocation),vr.EnvironmentsVisited.B) +1; 
end
end
%% Axona TTL...
if vr.timeElapsed==0 ;vr = ScanAxonaSynch(vr);
elseif vr.timeElapsed - vr.AxonaSynch.LastPulse > vr.AxonaSynch.Period && ...
    strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') && vr.PhotoLickDetection.Licking ==0 && strcmp(vr.PhotoLickDetection.daqSessLickDetection.Running,'Off')
    vr = ScanAxonaSynch(vr);
end
%% Provide info while running...

vr.text(1).string = ['IN LICKS  ' num2str(vr.PhotoLickDetection.LickEventsInsideRewardArea(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(2).string = ['OUT LICKS ' num2str(vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
if vr.timeElapsed==0
vr.text(3).string = 'SPD 0' ; %%datestr(now-vr.timeStarted,'MM.SS')];
else 
vr.text(3).string = ['SPD ' num2str(round(vr.velocity(2)))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
end
vr.text(4).string = ['TIME ' datestr(now-vr.timeStarted,'MM.SS')];
vr.text(5).string = ['REWARD ' num2str( sum(vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,:))) '/'  num2str(sum(vr.RewardDelivery.RewardLog(:)))]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(6).string = ['TRIAL ' num2str(vr.TrialSettings.iTrial)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(7).string = ['AXONA ' num2str(vr.AxonaSynch.NPulse)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(8).string = ['WORLD ' num2str(vr.currentWorld)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(9).string = ['POS ' num2str(round(vr.pos))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(10).string = ['TOT LICKS  ' num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];



%% Close if max number trials reached...
if vr.TrialSettings.iTrial== vr.TrialSettings.MaxNumerTrials+1;
stop(vr.LickDetection.daqSessLickDetection);
vr.experimentEnded=1;
end
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if strcmp(vr.RewardDelivery.daqSessRewardDelivery.Running,'on')
    stop(vr.RewardDelivery.daqSessRewardDelivery);
end;
vr = ScanAxonaSynch(vr); % close the timestamps to Axona...
fclose(vr.Behaviour.fidBehaviour);
%fclose(vr.PhotoLickDetection.fidLicking);
fclose(vr.AxonaSynch.fidSynch);
fclose(vr.PhotoLickDetection.fidLicking);
fclose(vr.PhotoLickDetection.fidDetection);
%fclose(vr.BatteryLickDetection.fidLicking);
%fclose(vr.BatteryLickDetection.fidDetection);

OutputDataFromVirmen(vr);

end
end