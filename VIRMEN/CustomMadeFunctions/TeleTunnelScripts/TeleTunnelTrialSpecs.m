function vr = TeleTunnelTrialSpecs(vr)
vr.rand = randn(1000,1);
while sum(abs(vr.rand)>2)
    vr.rand(abs(vr.rand)>2) = randn;
end
vr.cstart = -eval(vr.exper.variables.chamberLength)/2;
vr.tstart = -eval(vr.exper.variables.floorHeight)/2;
vr.worldcode = [2 1 3; 5 4 6; 8 7 9];
vr.trial_module = ceil(rand*3);
vr.trial_module_log = [0 vr.trial_module];
vr.TrialSettings.BlockLog = 1;
vr.TrialSettings.TrialBlocks = 2;
vr.tunnel_length = zeros(1,vr.TrialSettings.MaxNumerTrials);
vr.position = ([0 vr.cstart 3 0]);


vr.worldcode_visited = [];
vr.currentWorld = vr.worldcode(1,1);



%vr.temp_world_log = zeros(vr.trial_number,1);
vr.poslog = [0 0 0 0 0];

%vr.startTime = 0;
%Experiment_log = [];
%Experiment_log.numtrials = vr.trial_number -1;

end