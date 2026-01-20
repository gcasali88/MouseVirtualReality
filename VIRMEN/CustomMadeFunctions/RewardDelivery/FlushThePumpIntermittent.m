%%
function FlushThePumpIntermittent(t,times)
%%
%%time is in seconds...
s =  analogoutput('nidaq', 'Dev2');
channel = 0; % the AO number
addchannel(s,[channel] , {'RewardChannel'});%,'voltage');
set(s,'samplerate',1000);

TTLPeak = 6; %peak voltage;
TTLDuration = t*1000;% in 1 ms unit, if 4 means 400 ms...
TTLSignalOpen = [repmat(TTLPeak,1,TTLDuration)]; % creates the TTL
TTLSignalClose = [repmat(0,1,TTLDuration)]; % creates the TTL

TTLSignal = [TTLSignalOpen TTLSignalClose]; % adds one more data point and sets it to 0...
TTLSignal = [repmat(TTLSignal,1,times)];
putdata(s,TTLSignal');  %loads the gun.... 
start(s)
wait(s,TTLDuration+1);
beep;
disp(['Flushed for ' num2str(t) ' seconds ' num2str(times) ' times...']);
end
%%