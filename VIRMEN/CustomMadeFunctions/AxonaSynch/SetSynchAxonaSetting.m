function [ vr ] = SetSynchAxonaSetting( vr )
%Useful after daqreset...
if isfield(vr,'AxonaSynch')
delete(vr.AxonaSynch.daqSessAxonaSynch);
end
vr.AxonaSynch.daqSessAxonaSynch = analogoutput('nidaq', ['Dev' num2str(vr.NIDev)]); %session
vr.AxonaSynch.Channel =1;
vr.AxonaSynch.AxonaSystemUnitChannel = 2 ;%channel
addchannel(vr.AxonaSynch.daqSessAxonaSynch,vr.AxonaSynch.Channel,[vr.AxonaSynch.Channel],'AxonaSynch');
vr.AxonaSynch.Period = 10 ; % in seconds, it is every roughly how long the pulse is sent....
vr.AxonaSynch.Voltage = 3; % in volts it specifies the voltage sent
set(vr.AxonaSynch.daqSessAxonaSynch,'samplerate',10000);
vr.AxonaSynch.PulseSignal = [ vr.AxonaSynch.Voltage ; (vr.AxonaSynch.Voltage -vr.AxonaSynch.Voltage) ];


end

