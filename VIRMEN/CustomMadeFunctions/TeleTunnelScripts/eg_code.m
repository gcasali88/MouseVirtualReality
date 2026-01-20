function vr = eg_code(vr)
vr.rand = randn(1000,1);
vr.cstart = -eval(vr.exper.variables.chamberLength)/2;
vr.tstart = -eval(vr.exper.variables.floorHeight)/2;
vr.worldcode = [2 1 3; 5 4 6; 8 7 9];
vr.trial_module = ceil(rand*3);
vr.trial_module_log = [0 vr.trial_module];
vr.TrialSettings.BlockLog = 1;
vr.TrialSettings.TrialBlocks = 2;
vr.tunnel_length = zeros(1,100);
vr.position = ([0 vr.cstart 3 0]);
vr.worldcode_visited = [];
vr.currentWorld = vr.worldcode(1,1);
vr.cstart = -eval(vr.exper.variables.chamberLength)/2;
vr.tstart = -eval(vr.exper.variables.floorHeight)/2;

vr.TrialSettings.iTrial = 1;
%vr.temp_world_log = zeros(vr.trial_number,1);
vr.poslog = [0 0 0 0 0];
end