function [vr] = LogTeleTunnelBehaviour(vr)
vr.NameOfCurrentEnvironment = vr.EnvironmentSettings.Evironments{ find(vr.EnvironmentSettings.LabelEnvironment == vr.currentWorld)} ;
eval(['vr.NumberOfCurrentEnvironmentVisited =  vr.EnvironmentsVisited.' vr.NameOfCurrentEnvironment ';' ]);
%fwrite(vr.Behaviour.fidBehaviour, [vr.TrialSettings.iTrial vr.timeElapsed vr.poslog(1,:) vr.velocity(2)]);
fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.velocity(2)  vr.currentWorld vr.TrialSettings.iTrial vr.NumberOfCurrentEnvironmentVisited ]','double');
end