function code = UncertaintyExperiment
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
vr = UncertaintySelectWorld(vr);
vr = UncertaintyTrialSettings(vr);
%%Select and open correct world 
vr = UncertaintylTrialEnvironmentSettings( vr );



if     vr.RunExperiment ;
        vr.experimentEnded=0;

%% Deal with Gain manipulation...
vr = GainManipulationSettings(vr);

%% Open DAQ sessions...
daqreset;
vr = RotaryEncoderSettings(vr);
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
vr.text(11).string = '0';vr.text(11).position = [-.14 0.6];  vr.text(11).size =.05;vr.text(11).color = [1 1 0];  vr.text(11).window= [4];
vr.text(12).string = '0';vr.text(12).position = [-.14 0.7];  vr.text(12).size =.05;vr.text(12).color = [1 1 0];  vr.text(12).window= [4];
vr.text(13).string = '0';vr.text(13).position = [-.14 0.5];  vr.text(13).size =.05;vr.text(13).color = [1 1 0];  vr.text(13).window= [4];

vr.NewTrialStarted=0;
vr.NewTrialStartingColors = vr.worlds{vr.currentWorld}.surface.colors ;
else
    vr.RunExperiment = 0 ;
    vr.experimentEnded=1;

end
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

%End  if max time reached
if vr.timeElapsed > vr.TrialSettings.MaxLengthOfTrial*60 || vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials+1;
   vr.experimentEnded=1;
end    
%% Transport back to start of track
vr = UncertaintyTransportToStart(vr); 
vr = RunGainManipulation(vr) ;

eval([ 'vr.EnvironmentsVisited.'   vr.EnvironmentSettings.Evironments{ find(vr.currentWorld == [ vr.EnvironmentSettings.LabelEnvironment])} '=1;' ]);
%vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];
vr.AssignedEnvironment=[vr.currentWorld];


%% Is the animal in the reward area ?
vr.InRewardArea = vr.position(2) < vr.RewardLocation + (vr.RewardWindowWidth/2) && vr.position(2) > vr.RewardLocation - (vr.RewardWindowWidth/2);
vr.InGoalLocation = vr.position(2) > vr.RewardLocation;
vr.WhichCueLocation=1;   
   
   %% Scan photo detector... starts the lick detector
    if vr.DetectLicking
        [vr] = ScanPhotoLickDetection(vr);% %% Scan lick detection...% if vr.LickDetection.daqSessLickDetection.SamplesAcquired ~= 0% stop(vr.LickDetection.daqSessLickDetection);% [vr] = ScanLickDetection(vr);% start(vr.LickDetection.daqSessLickDetection);% end
       %[vr] = ScanBatteryLickDetection(vr);
    end
  
%% Set reward conditions ...
%% Is the animal in the reward area ?
    
    if vr.InRewardArea && ~vr.RewardMovementOnset   && ~vr.RewardIfLicking ; %give reward only in reward zone but don't have to lick
    vr.reward_condition = ... 
        vr.InGoalLocation  && ...
        ~vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) || ...
        vr.InRewardArea  && vr.PhotoLickDetection.Licking && vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
        if ~vr.TaskSolved(vr.TrialSettings.iTrial);
        vr.TaskSolved(vr.TrialSettings.iTrial) = vr.TaskSolved(vr.TrialSettings.iTrial)+ vr.InRewardArea  && vr.PhotoLickDetection.Licking && vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
        end 
    
    elseif vr.InRewardArea && ~vr.RewardMovementOnset  && vr.RewardIfLicking ; %give reward only if in reward zone AND licking
     vr.reward_condition =  vr.InRewardArea && ...
         ~vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) && vr.PhotoLickDetection.Licking && vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) <  vr.MaxNumberOfLicks ;
        if ~vr.TaskSolved(vr.TrialSettings.iTrial);
           vr.TaskSolved(vr.TrialSettings.iTrial) = vr.TaskSolved(vr.TrialSettings.iTrial) + vr.reward_condition;
        end
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
    
%%   Control black screen... 
    if vr.BlackScreen && (vr.timeElapsed - vr.BlackScreenTs  ) > vr.BlackScreenTimeOut ;
        %vr.BlackScreen = 0;  
        vr.NewTrialStarted = 1;
    end  
    
    if  ~vr.WhiteScreen & vr.DetectLicking & vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) >=  vr.MaxNumberOfLicks  & vr.currentWorld == vr.WorldIndexWithReward ;% | [~vr.NewTrialStarted & ~vr.WhiteScreen & ~vr.BlackScreen & (vr. timeElapsed - vr.NewTrialTs) > vr.MaxDurationOfEachTrial ] 
         vr.WhiteScreen = 1;
         vr.WhiteScreenTs = vr.timeElapsed;
     end
     
     if  vr.WhiteScreen & (vr.timeElapsed - vr.WhiteScreenTs  ) > vr.WhiteScreenTimeOut ;
        vr.NewTrialStarted = 1;
     end
     
     if vr.BlackScreen;
        vr.worlds{vr.currentWorld}.surface.colors(1:3,:) =  ~vr.BlackScreen ; 
        vr.worlds{vr.currentWorld}.surface.visible(:) = vr.BlackScreen;
        vr.worlds{vr.currentWorld}.backgroundColor = [~vr.BlackScreen ~vr.BlackScreen ~vr.BlackScreen] ;
    else
       vr.worlds{vr.currentWorld}.surface.visible(:) = ~vr.BlackScreen;
       vr.worlds{vr.currentWorld}.backgroundColor = vr.BackGroundColor ;
    end
    
    
    if vr.WhiteScreen
    vr.worlds{vr.currentWorld}.surface.colors(1:3,:) = vr.WhiteScreen ;        %vr.exper.worlds{vr.currentWorld}.transparency = 1;
    vr.worlds{vr.currentWorld}.backgroundColor(:) = [vr.WhiteScreen] ; ;
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
vr.text(9).string = ['POS ' num2str(round(vr.position(2)))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(10).string = ['TOT LICKS  ' num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(11).string = ['LICK TRIGGERED  ' num2str(vr.PhotoLickDetection.LickTriggered )];
vr.text(12).string = ['TRIALS SOLVED  ' num2str(nansum(vr.TaskSolved)) '/'  num2str(vr.TrialSettings.iTrial)]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(13).string = ['TASK SOLVED  ' num2str(vr.TaskSolved(vr.TrialSettings.iTrial))]; %%datestr(now-vr.timeStarted,'MM.SS')];

if vr.NewTrialStarted
   vr.RewardIfLicking = rand(1,1)< vr.LickingActiveConditionProbability( find(histcounts( vr.timeElapsed , 60*vr.LickingActiveConditionProbabilityTimeWindows ))) ;
end

end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

if  ~vr.RunExperiment 

    Answers.TrialInfo = vr.TrialInfo.Answers;
    Answers.BehaviourInfo = vr.BehaviourInfo.Answers;
    Prompts.TrialInfo = vr.TrialInfo.Prompt;
    Prompts.BehaviourInfo = vr.BehaviourInfo.Prompt;
    save('Answers' , 'Answers','Prompts')
    vr.experimentEnded=0 ;
    vr.RunExperiment  =  1 ;
    vr.exper = run(vr.exper);
else
    
    
    
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

OutputDataFromVirmen(vr) ;
end
%save('vr','vr')
end
end