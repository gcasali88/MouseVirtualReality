function code = CompartmentA
% CompartmentA   Code for the ViRMEn experiment CompartmentA.
%   code = CompartmentA   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
% Initialize runtime variables
% vr.numRewards = 0;
% vr.numDeliver = 0;
% vr.startTime = now;
% 
% daqreset;
% % Set Rotary encoder properties...
% vr.daqSessRotEnc = daq.createSession('ni');
% vr.counterCh = vr.daqSessRotEnc.addCounterInputChannel('Dev3', 'ctr1', 'Position');
% vr.counterCh.EncoderType = 'X4';%it was X4 from TW
% % Set licking detector...
% vr.daqSessLickDetection = daq.createSession('ni');
% vr.LickDetectionChannel = 0;
% [vr.LickDetection.ch,vr.LickDetection.id]=addAnalogInputChannel(vr.daqSessLickDetection,'Dev3', vr.LickDetectionChannel, 'Voltage'); %creates the session for daq licking
% vr.LickDetection.MinimumTimeDistance = 3; % Seconds (if the voltage is higher than threshold within minimum temporal lag is not stored as additional licking event...
% vr.LickDetection.Licking = 0; % creates variables which will be 
% vr.LickDetection.LickEvents = 0;
% vr.LickDetection.LickTimeStamps = [];
% vr.LickDetection.LickPositions = [];
% vr.LickDetection.VoltageThreshold =  2; %Volts...
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
% [vr] = ScanLickDetection(vr);
% 
% reward_condition = 0;
%     
% if reward_condition % test if the reward condition has been satisfied
% vr.numRewards = vr.numRewards + 1;
% end
% 
% 
% if vr.position(2) > 350 % test if the animal is at the end of the track (y > 200)
% vr.position(2) = 0; % set the animal’s y position to 0
% vr.dp(:) = 0; % prevent any additional movement during teleportation
% end
 end


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% disp(['The animal received ' num2str(vr.numRewards) ' rewards.']);
% disp(['The animal licked ' num2str(vr.LickDetection.LickEvents) ' times.']);
end


