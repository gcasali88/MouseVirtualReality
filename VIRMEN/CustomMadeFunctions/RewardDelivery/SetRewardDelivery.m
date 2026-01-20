function [ vr ] = SetRewardDelivery( vr )
%Useful after daqreset...
if isfield(vr,'RewardDelivery')
delete(vr.RewardDelivery.daqSessRewardDelivery);
end
vr.RewardDelivery.daqSessRewardDelivery = analogoutput('nidaq', ['Dev' num2str(vr.NIDev)]);
vr.RewardDelivery.Channel = 0; % the AO number
addchannel(vr.RewardDelivery.daqSessRewardDelivery,[vr.RewardDelivery.Channel] , {'RewardChannel'});%,'voltage');
set(vr.RewardDelivery.daqSessRewardDelivery,'samplerate',1000);
vr.RewardDelivery.TTLPeak = 4.5; %peak voltage;
vr.RewardDelivery.TTLDuration = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Valve Open for (ms):'))}) ];  % in 1 ms unit, if 50 means 50 ms...
vr.RewardDelivery.TTLSignal = [repmat(vr.RewardDelivery.TTLPeak,1,vr.RewardDelivery.TTLDuration)]; % creates the TTL
vr.RewardDelivery.TTLSignal(end+1) = [0]; % adds one more data point and sets it to 0...


end

