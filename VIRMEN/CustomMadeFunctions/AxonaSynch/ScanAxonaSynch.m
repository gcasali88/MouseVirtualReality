function vr = ScanAxonaSynch(vr)
% %% It sends a TTL pulse 
% outputSingleScan(vr.AxonaSynch.daqSessAxonaSynch,[vr.AxonaSynch.Voltage ]);
% outputSingleScan(vr.AxonaSynch.daqSessAxonaSynch,[vr.AxonaSynch.Voltage-vr.AxonaSynch.Voltage ]);
putdata(vr.AxonaSynch.daqSessAxonaSynch,vr.AxonaSynch.PulseSignal);  %loads the gun.... 
start(vr.AxonaSynch.daqSessAxonaSynch); % end fire...
vr.AxonaSynch.LastPulse = [vr.timeElapsed];
vr.AxonaSynch.NPulse = [vr.AxonaSynch.NPulse+1];
vr.AxonaSynch.ts = [vr.AxonaSynch.ts ;vr.AxonaSynch.LastPulse ];

if isempty(vr.pos)
fwrite(vr.AxonaSynch.fidSynch, [vr.AxonaSynch.LastPulse  0],'double');
else    
fwrite(vr.AxonaSynch.fidSynch, [vr.AxonaSynch.LastPulse  vr.pos],'double');
end

end

