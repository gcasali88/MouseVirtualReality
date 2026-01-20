function code = TrainingApparatus
% TrainingApparatus   Code for the ViRMEn experiBment TrainingApparatus.
%   code = TrainingApparatus   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
%% Specify Saving  data properties;
get_working_pc_and_cd;
vr.Experiment = 'Training';
vr = InputDataIntoVirmen( vr)  ;  
vr = TrainingTrialSettings(vr); 
vr = TrainingTrialEnvironmentSettings( vr );
vr = BehaviourSettings( vr);
vr = SetWindowsSetup(vr);
daqreset;
%%%%%%%%%%%%%%%% Rotary Encoder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(char(vr.TrialSettings.movementFunctionAfterPause ) , 'moveWithRotaryEncoder');vr = RotaryEncoderSettings(vr);end
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
vr.text(10).string = '0';vr.text(10).position = [-.14 0.3];  vr.text(10).size =.05;vr.text(10).color = [1 1 0];  vr.text(10).window= [4];
vr.text(11).string = '0';vr.text(11).position = [-.14 0.6];  vr.text(11).size =.05;vr.text(11).color = [1 1 0];  vr.text(11).window= [4];
vr.text(12).string = '0';vr.text(12).position = [-.14 0.7];  vr.text(12).size =.05;vr.text(12).color = [1 1 0];  vr.text(12).window= [4];
vr.text(13).string = '0';vr.text(13).position = [-.14 0.5];  vr.text(13).size =.05;vr.text(13).color = [1 1 0];  vr.text(13).window= [4];

vr.TrialSettings.iTrial=1;
[ vr ] = LoadEnvironments(vr);  %resets the visits across compartments...
vr.NewTrialStarted=0;  
vr.NewTrialStartingColors = vr.worlds{vr.currentWorld}.surface.colors ;
end


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)


if vr.timeElapsed > vr.MaxTrialLength*60 || vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials ; 
vr.experimentEnded=1;  
end
%% Determine if the elapsed time of the current trial is longer than maximum time permitted...
vr.TimeForEachLapElapsed = [(vr.timeElapsed - vr.NewTrialTs) > vr.MaxLapLength] & ~vr.TaskSolved(vr.TrialSettings.iTrial) ;


%% Pos...if further frontal or back wall teletrasport back to the start
vr = RunTeletransportationTrainingEnvironment(vr);%     if vr.position(2)+vr.dp(2) > max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y);%         vr.position(2)=0;vr.dp=0; vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;%     elseif vr.position(2)+vr.dp(2) < min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.BackWall}.y);%        vr.position(2)=0;vr.dp=0;   vr.TrialSettings.iTrial=vr.TrialSettings.iTrial+1;%     end   %     if vr.TrialSettings.iTrial  ~=1;% %     end%     vr.pos = vr.position(2);vr.AssignedEnvironment=[vr.AssignedEnvironment;vr.currentWorld];%     fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2) vr.AssignedEnvironment(end) vr.TrialSettings.iTrial]','double');
eval([ 'vr.EnvironmentsVisited.'   vr.EnvironmentSettings.Evironments{ find(vr.currentWorld == [ vr.EnvironmentSettings.LabelEnvironment])} '=1;' ]);

%% Is the animal in the goal related area ?
if isfield(vr.worlds{vr.currentWorld}.objects.indices,'GoalCue') ;
%% If Goal cue is the end of the tunnel...
        
        vr.InRewardArea =  ~isempty( FindElementsWithMultipleBoundaries(  vr.position(2) ,vr.RewardAreaLimits ,'inside')) ;
        
        
        vr.InGoalLocation = vr.position(2) > nanmean(vr.RewardAreaLimits );
        
        %% If Goal cue before the end of the tunnel...
            %     vr.InRewardArea =  vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - ...
            %              vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 - (vr.RewardWindowWidth/2) ...
            %              && vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - ...
            % %              vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 + (vr.RewardWindowWidth/2);
            %         if vr.RewardIfLicking==0; %% This is important, it virtually shifts the location of the reward at the extremes of the rewarded area...
            %         vr.InGoalLocation = ...
            %         vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - ...
            %              vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 ...
            %              && vr.position(2) < vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - ...
            %              vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 + (vr.RewardWindowWidth/2) ;
            %         else
            %         vr.InGoalLocation = vr.InRewardArea ; ...vr.position(2) > vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 - (vr.RewardWindowWidth/2) && vr.position(2) <  vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.y - vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.height/2 + (vr.RewardWindowWidth/2);
            %         end
     vr.WhichCueLocation=1;   
else
    vr.InGoalLocation = 0;
    vr.InRewardArea = 0;
end
    
    %% Scan photo detector...
    if vr.DetectLicking
        [vr] = ScanPhotoLickDetection(vr);% %% Scan lick detection...% if vr.LickDetection.daqSessLickDetection.SamplesAcquired ~= 0% stop(vr.LickDetection.daqSessLickDetection);% [vr] = ScanLickDetection(vr);% start(vr.LickDetection.daqSessLickDetection);% end
       %[vr] = ScanBatteryLickDetection(vr);
    end
  

%% Set reward conditions ...
    if  isfield(vr.worlds{vr.currentWorld}.objects.indices,'GoalCue') && vr.RewardMovementOnset == 0  && ~vr.RewardIfLicking ; 
    vr.reward_condition = ... 
        vr.InGoalLocation  && ...
        vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0  || ...
        vr.InRewardArea  && vr.PhotoLickDetection.Licking && vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
        
    if ~vr.TaskSolved(vr.TrialSettings.iTrial);
    vr.TaskSolved(vr.TrialSettings.iTrial) = vr.TaskSolved(vr.TrialSettings.iTrial)+ vr.InRewardArea  && vr.PhotoLickDetection.Licking && vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
    end    
    elseif isfield(vr.worlds{vr.currentWorld}.objects.indices,'GoalCue') && vr.RewardMovementOnset == 0  && vr.RewardIfLicking ;
     vr.reward_condition =  vr.InRewardArea & ...
        vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 && vr.PhotoLickDetection.Licking && vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) <  vr.MaxNumberOfLicks ;
       if ~vr.TaskSolved(vr.TrialSettings.iTrial);
           vr.TaskSolved(vr.TrialSettings.iTrial) = vr.TaskSolved(vr.TrialSettings.iTrial) + vr.reward_condition;
       end
    elseif vr.RewardMovementOnset
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
    if [vr.reward_condition | vr.ManualReward ] && vr.timeElapsed>0 && strcmp((vr.AxonaSynch.daqSessAxonaSynch.Running),'Off') & strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off');% ...
            %%% test if the reward condition has been satisfied%if vr.PhotoLickDetection.LickEvents < 10 & vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial) ==0;
    [vr] = StartReward(vr);
    vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)= vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)+1;
    if vr.reward_condition
    vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1,1) = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1)+1; 
    
    if    vr.TaskSolved(vr.TrialSettings.iTrial) 
            vr.BlackScreen = 1;
            vr.BlackScreenTs = [vr.timeElapsed];    
    end
    
    end
    end
    

    
    %% Manage Black or White Screen displayed.
    
    if vr.BlackScreen && (vr.timeElapsed - vr.BlackScreenTs  ) > vr.BlackScreenTimeOut ;
        vr.NewTrialStarted = 1;
    end
      
     if  (vr.TimeForEachLapElapsed & ~vr.WhiteScreen) | (~vr.WhiteScreen & vr.DetectLicking & vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial) >=  vr.MaxNumberOfLicks  & vr.currentWorld == vr.WorldIndexWithReward) ;
         vr.WhiteScreen = 1;
         vr.WhiteScreenTs = vr.timeElapsed;
     end
     
   
    if  vr.WhiteScreen & (vr.timeElapsed - vr.WhiteScreenTs  ) > vr.WhiteScreenTimeOut ;
        vr.NewTrialStarted = 1;
     end
     
    vr.worlds{vr.currentWorld}.surface.visible(:) = ~vr.BlackScreen;
    
    if vr.WhiteScreen
    vr.worlds{vr.currentWorld}.surface.colors(1:3,:) = vr.WhiteScreen ;        %vr.exper.worlds{vr.currentWorld}.transparency = 1;
    end
    
%% Axona TTL...
if vr.timeElapsed==0 ;vr = ScanAxonaSynch(vr);
elseif vr.timeElapsed - vr.AxonaSynch.LastPulse > vr.AxonaSynch.Period && ...
    strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') && vr.PhotoLickDetection.Licking ==0 && strcmp(vr.PhotoLickDetection.daqSessLickDetection.Running,'Off')
    vr = ScanAxonaSynch(vr);
end
%% Provide info while running...

vr.text(1).string = ['IN LICKS  ' num2str(vr.PhotoLickDetection.LickEventsInsideRewardArea(vr.TrialSettings.iTrial))  '/'  num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial))]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(2).string = ['OUT LICKS ' num2str(vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial)) '/'  num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial))]; %%datestr(now-vr.timeStarted,'MM.SS')];
if vr.timeElapsed==0
vr.text(3).string = 'SPD 0' ; %%datestr(now-vr.timeStarted,'MM.SS')];
else 
vr.text(3).string = ['SPD ' num2str(round(vr.velocity(2)))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
end
if         vr.TaskSolved(vr.TrialSettings.iTrial)
end
vr.text(4).string = ['TIME ' datestr(now-vr.timeStarted,'MM.SS')];
vr.text(5).string = ['REWARD ' num2str( sum(vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,:))) '/'  num2str(sum(vr.RewardDelivery.RewardLog(:)))]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(6).string = ['TRIAL ' num2str(vr.TrialSettings.iTrial)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(7).string = ['AXONA ' num2str(vr.AxonaSynch.NPulse)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(8).string = ['WORLD ' num2str(vr.currentWorld)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(9).string = ['POS ' num2str(round(vr.pos))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(10).string = ['TOT LICKS  ' num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial)) '/'  num2str(nansum(vr.PhotoLickDetection.LickEvents))]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(11).string = ['LICK TRIGGERED  ' num2str(vr.PhotoLickDetection.LickTriggered )];
vr.text(12).string = ['TRIALS SOLVED  ' num2str(nansum(vr.TaskSolved)) '/'  num2str(vr.TrialSettings.iTrial)]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(13).string = ['TASK SOLVED  ' num2str(vr.TaskSolved(vr.TrialSettings.iTrial))]; %%datestr(now-vr.timeStarted,'MM.SS')];



if vr.NewTrialStarted
vr.RewardIfLicking = rand(1,1)< vr.LickingActiveConditionProbability ;
end


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
%%insert that also...
%%[ time, type, chan ]=read_INP_file( 'C:\Users\Giulio\Documents\Multicompartment\Trial\20170130\Session1\trial.inp' )

end
end