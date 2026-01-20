function [vr] =  RewardDeliverySettings(vr);


vr = SetRewardDelivery(vr);
% vr.RewardDelivery.daqSessRewardDelivery = analogoutput('nidaq', 'Dev3');
% vr.RewardDelivery.Channel = 0; % the AI number
% addchannel(vr.RewardDelivery.daqSessRewardDelivery,vr.RewardDelivery.Channel,'voltage');
% set(vr.RewardDelivery.daqSessRewardDelivery,'samplerate',10);


% 
% % Specify TTL props...
% vr.RewardDelivery.TTLPeak = 5; %peak voltage;
% vr.RewardDelivery.TTLDuration = 4;% in 100 ms unit, if 4 means 400 ms...
% vr.RewardDelivery.TTLSignal = [repmat(vr.RewardDelivery.TTLPeak,1,vr.RewardDelivery.TTLDuration)]; % creates the TTL
% vr.RewardDelivery.TTLSignal(end+1:end+2) = [0 0]; % adds one more data point and sets it to 0...
vr.RewardDelivery.fidLicking = fopen('Reward.data','w');%creates the file where the behavioural data is stored (better than updating this into the vr structure)...
vr.RewardDelivery.RewardLog = zeros(vr.TrialSettings.MaxNumerTrials,numel(vr.EnvironmentSettings.LabelEnvironment));  % that will increase during recordings for each world that a reward was given....
if isfield(vr.worlds{vr.WorldIndexWithReward}.objects.indices,'GoalCue') & ~isfield(vr.worlds{vr.WorldIndexWithReward}.objects.indices,'GoalCueOLD');
vr.NumberOfCues = numel(vr.exper.worlds{vr.WorldIndexWithReward}.objects{vr.worlds{vr.WorldIndexWithReward}.objects.indices.GoalCue}.x);
% elseif isfield(vr.worlds{vr.WorldIndexWithReward}.objects.indices,'GoalCue') & isfield(vr.worlds{vr.WorldIndexWithReward}.objects.indices,'GoalCueOLD');
% vr.NumberOfCues = numel(vr.exper.worlds{vr.WorldIndexWithReward}.objects{vr.worlds{vr.WorldIndexWithReward}.objects.indices.GoalCue}.x)
else
vr.NumberOfCues =  1;   
end
vr.RewardDelivery.GoalCueLog = zeros(vr.TrialSettings.MaxNumerTrials,vr.NumberOfCues,vr.NumberOfTimesRewardEnvironmentPresented) ;  % that will increase during recordings, only for the cue areas...
vr.RewardDelivery.TimeStamps = [] ;
%vr.RewardDelivery.Positions = [];
vr.RewardDelivery.MinimumTimeDistance = [4];% seconds...


end
