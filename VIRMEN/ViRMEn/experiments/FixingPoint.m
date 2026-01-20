function code = FixingPoint
% FixingPoint   Code for the ViRMEn experiment FixingPoint.
%   code = FixingPoint   Returns handles to the functions that ViRMEn
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
vr.Experiment = 'FixingPoint';
vr = InputDataIntoVirmen( vr);
vr = SetMovingPointSettings(vr);
[vr ] = FixedPointTrialSettings(vr);

[ vr ] = FixedPointTrialEnvironmentSettings( vr );

daqreset;
vr = RewardDeliverySettings(vr);
%%%%%%%%%%%%%%%% Set licking detector %%%%%%%%%%%%%%%%%%%%%%%%
%vr = LickDetectionSettings(vr);
vr = PhotoLickDetectionSettings(vr);
%%%%%%%%%%%%%%%% Set ephs synch locking         
vr = SynchAxonaSettings(vr);
%%%%%%%%%%%%%%%%%%%%%%%%%% Run Trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Text boxes...
vr.text(1).string = '0';vr.text(1).position = [-.14  0.2];   vr.text(1).size = .05;vr.text(1).color = [1 0 1];   vr.text(1).window = [4];
vr.text(2).string = '0';vr.text(2).position = [-.14  0.1];   vr.text(2).size = .05;vr.text(2).color = [1 0 1];   vr.text(2).window = [4];
%vr.text(3).string = '0';vr.text(3).position = [-.14  0.0];   vr.text(3).size = .05;vr.text(3).color = [1 1 0];   vr.text(3).window = [4];
vr.text(4).string = '0';vr.text(4).position = [-.14 -0.1];   vr.text(4).size = .05;vr.text(4).color = [0 1 1];   vr.text(4).window = [4];
vr.text(5).string = '0';vr.text(5).position = [-.14 -0.2];   vr.text(5).size = .05;vr.text(5).color = [1 1 1];   vr.text(5).window = [4];
vr.text(6).string = '0';vr.text(6).position = [-.14 -0.3];   vr.text(6).size = .05;vr.text(6).color = [0 1 0];   vr.text(6).window = [4];
vr.text(7).string = '0';vr.text(7).position = [-.14 -0.4];   vr.text(7).size = .05;vr.text(7).color = [1 0 0];   vr.text(7).window = [4];
%vr.text(8).string = '0';vr.text(8).position = [-.14 -0.5];   vr.text(8).size = .05;vr.text(8).color = [1 1 1];   vr.text(8).window = [1];
%vr.text(9).string = '0';vr.text(9).position = [-.14 -0.6];   vr.text(9).size = .05;vr.text(9).color = [1 1 0];   vr.text(9).window = [1];
vr.text(10).string = '0';vr.text(10).position = [-.14 0.3];  vr.text(10).size =.05;vr.text(10).color = [1 1 0];  vr.text(10).window= [4];
vr.text(11).string = '0';vr.text(11).position = [-.14 0.6];  vr.text(11).size =.05;vr.text(11).color = [1 1 0];  vr.text(11).window= [4];
%%
vr.TrialSettings.iTrial=1;
[ vr ] = LoadEnvironments(vr);  %resets the visits across compartments...
vr.NewTrialStarted=0;  
vr.PreviousPositionInReward = 0;
end


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if vr.timeElapsed > vr.MaxTrialLength*60 || vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials ; 
vr.experimentEnded=1;  
end
%%
vr = MoveFixingPoint (vr) ;
%vr = MoveFixingPoint2(vr);
eval([ 'vr.EnvironmentsVisited.'   vr.EnvironmentSettings.Evironments{ find(vr.currentWorld == [ vr.EnvironmentSettings.LabelEnvironment])} '=1;' ]);

%% Is the animal in the goal related area ?
vr.InGoalLocation = [inpolygon(vr.pos(:,1),vr.pos(:,2),vr.circle.xp,vr.circle.yp) ] ;
vr.InNewGoalLocation = vr.InGoalLocation - vr.PreviousPositionInReward; 
vr.PreviousPositionInReward = vr.InGoalLocation;
if vr.InNewGoalLocation>0 ;
end

if vr.InNewGoalLocation == -1; vr.TrialSettings.iTrial = vr.TrialSettings.iTrial +1;end
    
%% Scan photo detector...
if vr.DetectLicking
  [vr] = ScanPhotoLickDetection(vr);% %% Scan lick detection...% if vr.LickDetection.daqSessLickDetection.SamplesAcquired ~= 0% stop(vr.LickDetection.daqSessLickDetection);% [vr] = ScanLickDetection(vr);% start(vr.LickDetection.daqSessLickDetection);% end
 %[vr] = ScanBatteryLickDetection(vr);
end
    
%% Set reward conditions ...
    
if  vr.RewardIfLicking ==0; 
    vr.reward_condition = ... 
        vr.InNewGoalLocation>0  && ...
        vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 ;
    
elseif vr.RewardIfLicking
 vr.reward_condition = ... 
        vr.InNewGoalLocation >0 && ...
        vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1) ==0 &&  vr.PhotoLickDetection.Licking;

else
        vr.reward_condition = 0;
end;
    %% Add Key pressing option...
    vr.ManualReward = ~isnan(vr.keyPressed);

        %% Activate Reward
    if [vr.reward_condition | vr.ManualReward ] && vr.timeElapsed>0 && strcmp((vr.AxonaSynch.daqSessAxonaSynch.Running),'Off') & strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') ...
            %%% test if the reward condition has been satisfied%if vr.PhotoLickDetection.LickEvents < 10 & vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial) ==0;
    [vr] = StartReward(vr);
    vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)= vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,vr.currentWorld)+1;
    if vr.reward_condition
    vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1,1) = vr.RewardDelivery.GoalCueLog(vr.TrialSettings.iTrial,1)+1;
    end
    end

%% Axona TTL...
if vr.timeElapsed==0 ;vr = ScanAxonaSynch(vr);
elseif vr.timeElapsed - vr.AxonaSynch.LastPulse > vr.AxonaSynch.Period && ...
    strcmp((vr.RewardDelivery.daqSessRewardDelivery.Running),'Off') && vr.PhotoLickDetection.Licking ==0 && strcmp(vr.PhotoLickDetection.daqSessLickDetection.Running,'Off')
    vr = ScanAxonaSynch(vr);
end



%% Box plots...
vr.text(1).string = ['IN LICKS  ' num2str(vr.PhotoLickDetection.LickEventsInsideRewardArea(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(2).string = ['OUT LICKS ' num2str(vr.PhotoLickDetection.LickEventsOutSideRewardArea(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
% if vr.timeElapsed==0
% vr.text(3).string = 'SPD 0' ; %%datestr(now-vr.timeStarted,'MM.SS')];
% else 
% vr.text(3).string = ['SPD ' num2str(round(vr.velocity(2)))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
% end

vr.text(4).string = ['TIME ' datestr(now-vr.timeStarted,'MM.SS')];
vr.text(5).string = ['REWARD ' num2str( sum(vr.RewardDelivery.RewardLog(vr.TrialSettings.iTrial,:))) '/'  num2str(sum(vr.RewardDelivery.RewardLog(:)))]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(6).string = ['TRIAL ' num2str(vr.TrialSettings.iTrial)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(7).string = ['AXONA ' num2str(vr.AxonaSynch.NPulse)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
%vr.text(8).string = ['WORLD ' num2str(vr.currentWorld)  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
%vr.text(9).string = ['POS ' num2str(round(vr.pos))  ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(10).string = ['TOT LICKS  ' num2str(vr.PhotoLickDetection.LickEvents(vr.TrialSettings.iTrial)) ]; %%datestr(now-vr.timeStarted,'MM.SS')];
vr.text(11).string = ['LICK TRIGGERED  ' num2str(vr.PhotoLickDetection.tmpV<  vr.PhotoLickDetection.VoltageThreshold )];





end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr);
   
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
%fclose(vr.Behaviour.fidBehaviour);
OutputDataFromVirmen(vr);
%   vr.Data = [];
% % open the binary file
% vr.BehaviourData = fopen('Behaviour.data','r');
% % read all data from the file into the matrix
% vr.Behaviour= transpose(fread(vr.BehaviourData,[3,Inf],'double'));
% figure(2);plot(vr.Behaviour(:,2),vr.Behaviour(:,3));set(gca,'DataAspectRatio',[1 1 1]);
% xlim([vr.WallXLimits]);
% ylim([vr.WallYLimits]);
% 
% save('vr','vr');  
end
end