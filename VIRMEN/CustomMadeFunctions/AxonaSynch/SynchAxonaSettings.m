function vr = SynchAxonaSettings(vr);
%Settings to create daq sessions and send pulse to Axona during
%recordings...
vr = SetSynchAxonaSetting(vr);
% vr.AxonaSynch.daqSessAxonaSynch = analogoutput('nidaq', 'Dev3'); %session
% vr.AxonaSynch.Channel =1;%channel
% addchannel(vr.AxonaSynch.daqSessAxonaSynch,vr.AxonaSynch.Channel,'voltage');
% vr.AxonaSynch.Period = 10 ; % in seconds, it is every roughly how long the pulse is sent....
% vr.AxonaSynch.Voltage = 4; % in volts it specifies the voltage sent
% vr.AxonaSynch.fidSynch = fopen('AxonaSynch.data','w');
% set(vr.AxonaSynch.daqSessAxonaSynch,'samplerate',1000);
% vr.AxonaSynch.PulseSignal = [ vr.AxonaSynch.Voltage ; (vr.AxonaSynch.Voltage -vr.AxonaSynch.Voltage) ];
%putdata(vr.AxonaSynch.daqSessAxonaSynch,vr.AxonaSynch.PulseSignal);  %loads the gun.... 
vr.AxonaSynch.fidSynch = fopen('AxonaSynch.data','w');
vr.AxonaSynch.NPulse = 0;
vr.AxonaSynch.ts = [];
end

