function code = Uncertainty
% UncertaintyExperiment   Code for the ViRMEn experiment UncertaintyExperiment.
%   code = UncertaintyExperiment   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

%Specify saving data properties
vr.Experiment = 'Uncertainty';
vr = UncertaintyInsertTestData(vr);

%Basic trial settings- taken mostly from InsertTestData
vr = UncertaintyTrialSettings(vr);

%Select and open correct world 
vr = UncertaintySelectWorld(vr);

vr = UncertaintylTrialEnvironmentSettings( vr );
% Open DAQ sessions...
vr = GainManipulationSettings(vr);
daqreset;
%if strcmp(char(vr.TrialSettings.movementFunctionAfterPause ) , 'moveWithRotaryEncoder');
    vr = RotaryEncoderSettings(vr);
%end
vr = RewardDeliverySettings(vr);
% % %%%%%%%%%%%%%%%% Set licking detector %%%%%%%%%%%%%%%%%%%%%%%%
 vr = LickDetectionSettings(vr);
 vr = PhotoLickDetectionSettings(vr);
% % %%%%%%%%%%%%%%%% Set ephs synch locking         
 vr = SynchAxonaSettings(vr);
%Settings for Uncertainty gain manipulation...
%log environments visited...
vr = LoadEnvironments(vr);
vr = BehaviourSettings( vr);

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
vr.text(10).string = '0';vr.text(10).position = [-.14 0.3];  vr.text(10).size =.05;vr.text(10).color = [1 1 0];  vr.text(10).window= [4];

end
%end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = RunGainManipulation(vr) ;
eval([ 'vr.EnvironmentsVisited.'   vr.EnvironmentSettings.Evironments{ find(vr.currentWorld == [ vr.EnvironmentSettings.LabelEnvironment])} '=1;' ]);
vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];
[ vr] = LogBehaviouralData(vr );

%% Is the animal in the reward area ?
vr.InRewardZone = vr.position(2) < vr.RewardLocation + (vr.RewardWindowWidth/2) && vr.position(2) > vr.RewardLocation - (vr.RewardWindowWidth/2);
vr.InGoalLocation = vr.InRewardZone;
vr.WhichCueLocation=1;   
   
   %% Scan photo detector... starts the lick detector
    if vr.DetectLicking
        [vr] = ScanPhotoLickDetection(vr);% %% Scan lick detection...% if vr.LickDetection.daqSessLickDetection.SamplesAcquired ~= 0% stop(vr.LickDetection.daqSessLickDetection);% [vr] = ScanLickDetection(vr);% start(vr.LickDetection.daqSessLickDetection);% end
       %[vr] = ScanBatteryLickDetection(vr);
    end
  
%% Set reward conditions ...
%% Is the animal in the reward area ?
    if vr.timeElapsed > 0 
        
    end 
    if vr.InRewardZone == 1 && vr.RewardMovementOnset == 0  && vr.RewardIfLicking ==0; %give reward only in reward zone but don't have to lick
    vr.reward_condition = ... 
        vr.position(2) >= vr.RewardLocation  && ...
        vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
    
    elseif vr.InRewardZone == 1 && vr.RewardMovementOnset == 0  && vr.RewardIfLicking ; %give reward only if in reward zone AND licking
     vr.reward_condition =  vr.InRewardZone && ...
         vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 && vr.PhotoLickDetection.Licking && vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) <  vr.MaxNumberOfLicks ;

    elseif vr.RewardMovementOnset %give reward periodically whenever they run
       if isempty(   vr.RewardDelivery.TimeStamps) 
           vr.reward_condition = vr.velocity(2) > vr.RewardMovementSpeedThreshold ;
       else
           vr.reward_condition = vr.velocity(2) > vr.RewardMovementSpeedThreshold && abs(vr.timeElapsed - vr.RewardDelivery.TimeStamps(end)) > vr.RewardDelivery.MinimumTimeDistance ...
               && vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)<vr.MaxNumberRewardsPerTrial;
       end
       
    else
        vr.reward_condition = 0;
    end;
    %% Add Key pressing option...
    vr.ManualReward = ~isnan(vr.keyPressed);
   
    %% Activate Reward
    if [vr.reward_condition | vr.ManualReward ] && vr.timeElapsed>0 && strcmp((vr.AxonaSynch.daqSessAxonaSynch.Running),'Off') & strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') ...
            %%% test if the reward condition has been satisfied%if vr.PhotoLickDetection.LickEvents < 10 & vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial) ==0;
    [vr] = StartReward(vr);
    vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)= vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)+1; %log how many times they were given the reward
    if vr.reward_condition
    vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1,1) = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1)+1; %log how many times they met the conditions for reward
    end
    end
    %% %% Axona TTL...
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


%% Transport back to start of track

if vr.GainManipulation.Value < 0
    
end
vr = UncertaintyTransportToStart(vr);

if vr.GainManipulation.Value < 0
    
end


%End  if max time reached
if vr.timeElapsed > vr.TrialSettings.MaxLengthOfTrial*60 || vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials+1;
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
%
fclose(vr.AxonaSynch.fidSynch);
fclose(vr.PhotoLickDetection.fidLicking);
fclose(vr.PhotoLickDetection.fidDetection);

% % open the binary file
% vr.GainManipulation.POSTHOC = fopen('GainManipulation.data','r');
% % read all data from the file into the matrix
% vr.GainManipulation.POSTHOCData= transpose(fread(vr.GainManipulation.POSTHOC,[2,Inf],'double'));
% 
% vr.AnimalDisplacement.POSTHOC = fopen('AnimalDisplacement.data','r');
% % read all data from the file into the matrix
% vr.AnimalDisplacement.POSTHOCData= transpose(fread(vr.AnimalDisplacement.POSTHOC,[2,Inf],'double'));
% 
% vr.PositionPI.POSTHOC = fopen('PositionPI.data','r');
% vr.PositionPI.POSTHOCData = transpose(fread(vr.PositionPI.POSTHOC,[2,Inf],'double'));

OutputDataFromVirmen(vr)
%save('vr','vr')
end
end