function [displacement,movementType] = MoveAtFixedSpeedByGainManipulation(vr)
Speed = 15 ;
Time = 0.020;

pOff = Speed * Time ; 

if vr.GainManipulation.Value < 0
    
 pOff= pOff / abs(vr.GainManipulation.Value);
else
 pOff= pOff * vr.GainManipulation.Value;
   
end

%pOff2 = count;
% if mod( vr.iterations, 20 )==0  &&  pOff~=0;
%     fprintf(1,'disp=%f2.4',pOff);
% end

% Update displacement %
%if pOff <0; pOff = 0;end;
displacement = [0 pOff 0 0];
movementType = 'displacement';