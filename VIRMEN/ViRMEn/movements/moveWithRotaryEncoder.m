function [displacement,movementType] = moveWithRotaryEncoder(vr)

% Read data from NIDAQ
count = vr.RotaryEncoder.daqSessRotEnc.inputSingleScan ;
resetCounter( vr.RotaryEncoder.counterCh );

% Remove NaN's from the data (these occur after NIDAQ has stopped)
if isnan(count);  count = 0;   end

% Need to control for wheel going backwards (means counts go backwards from 2^32) %
if count > 100000;   count = count - (2^32);   end

% Convert to actual position offset %
% 4096 counts per cycle in a Kubler 05.2400.1122.1024 when used in 'X4' mode;
% wheel circumference wass 55.3cm (for nominal dia 7 inch) in TW settings
% but measured in GC is 62.8 (10 cm is the radius of the wheel...).
% 1 virmen unit = 1cm @ vr.movementGain = 1.
pOff = (count/4096) * 20*pi * 62.8/55.3;
% if vr.GainManipulation.Value < 0 
%  pOff= pOff / abs(vr.GainManipulation.Value);
% else
 if (vr.GainManipulation.Value) < 0
     
 end
pOff= pOff * (vr.GainManipulation.Value);
%log(vr.GainManipulation.Value)
%end


%pOff= pOff *vr.GainManipulation.Value;
%pOff2 = count;
% if mod( vr.iterations, 20 )==0  &&  pOff~=0;
%     fprintf(1,'disp=%f2.4',pOff);
% end

% Update displacement %
%if pOff <0; pOff = 0;end;
displacement = [0 pOff 0 0];
movementType = 'displacement';

