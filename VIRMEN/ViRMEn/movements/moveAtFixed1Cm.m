function [displacement,movementType] = moveAtFixed1Cm(vr)

% Pretend Read data from NIDAQ

pOff = 1 + vr.iterations/10 ;% * rand(1,1);

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
