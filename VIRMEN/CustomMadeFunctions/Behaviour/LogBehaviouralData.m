function [ vr] = LogBehaviouralData(vr );
%% This function logs behavioural data

 
% 
% 
% % if numel(vr.AssignedEnvironment) == 1;
% % vr.pos = vr.dp(2);
% % elseif vr.AssignedEnvironment(end)==1 & vr.AssignedEnvironment(end-1) == 3; %that is the shift between environment 3 (pipe) to environment 1 (initial pipe)
% % vr.pos = vr.dp(2) ;
% % else
% % vr.pos = vr.dp(2)+ vr.pos;   
% % end
% %vr.pos=[vr.pos;vr.dp(2) + vr.pos(end)];
% % end
% % vr.t=[vr.t;vr.timeElapsed];
% % vr.speed = [vr.speed;vr.velocity(2)];
% % vr.iteration = [vr.iteration;vr.iterations];
% 
% %timestamp = now;
% % write timestamp and the x & y components of position and velocity to a file
% % using floating-point precision
% Useful to store the name of the current environment...

vr.AssignedEnvironment=[vr.currentWorld];
vr.NameOfCurrentEnvironment = vr.EnvironmentSettings.Evironments{ find(vr.EnvironmentSettings.LabelEnvironment == vr.currentWorld)} ;
eval(['vr.NumberOfCurrentEnvironmentVisited =  vr.EnvironmentsVisited.' vr.NameOfCurrentEnvironment ';' ]);

fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2) vr.AssignedEnvironment(end) vr.TrialSettings.iTrial vr.NumberOfCurrentEnvironmentVisited ]','double');

end

