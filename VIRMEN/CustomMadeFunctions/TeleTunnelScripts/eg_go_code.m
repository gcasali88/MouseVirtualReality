%% This code controls the transitions between enivronments
function vr = eg_go_code(vr)
    %Entry Chamber (May want to scrap)
    if vr.currentWorld == vr.worldcode(1,1)
        vr.pos_offset = vr.cstart;
        if vr.position(2)>(-vr.cstart +7)
           vr.worldcode_visited = [vr.currentWorld,vr.worldcode_visited];
           vr.currentWorld = vr.worldcode(vr.trial_module,2);
           vr.pos_offset = vr.tstart;
           vr.position = ([0 vr.tstart 3 0]);
        end
    % Tunnel to Reward Chamber (Chamber2) transition
    elseif vr.currentWorld == 1 || vr.currentWorld == 4
           vr.tunnel_stop = (vr.rand(vr.TrialSettings.iTrial)*200 -vr.tstart*0.0);
        if vr.position(2)>vr.tunnel_stop
           vr.worldcode_visited = [vr.currentWorld,vr.worldcode_visited];
           vr.tunnel_length(vr.TrialSettings.iTrial)  = vr.tunnel_stop - vr.tstart;
           vr.poslog = [vr.currentWorld vr.position;vr.poslog];
           vr.pos_offset = vr.cstart +vr.tstart -vr.tunnel_stop; %The offset subtracting chamber start n tunnel start + uncertainty
           vr.currentWorld = vr.worldcode(2,3);
           vr.position = ([0 vr.cstart 3 0]);
        end
    elseif vr.currentWorld == 7
        
        if vr.position(2)>-vr.tstart*0.0
            vr.tunnel_length(vr.TrialSettings.iTrial) = -vr.tstart*1.5;
            vr.worldcode_visited = [vr.currentWorld,vr.worldcode_visited];
            vr.poslog = [vr.currentWorld vr.position;vr.poslog];
            vr.pos_offset = vr.cstart +vr.tstart;
            vr.currentWorld = vr.worldcode(2,3);
            vr.position = ([0 vr.cstart 3 0]);
        end
    %Reward Chamber (second Chamber) to tunnel/Entry Chamber transition
    elseif vr.currentWorld ==6|| vr.currentWorld ==9
        if vr.position(2)>(-vr.cstart +7)          
            if mod(vr.TrialSettings.iTrial,vr.TrialSettings.TrialBlocks)==0 %Transition to next trial block
                vr.TrialSettings.BlockLog = vr.TrialSettings.BlockLog+1;
                while vr.trial_module == vr.trial_module_log(vr.TrialSettings.BlockLog)|vr.trial_module ==vr.trial_module_log(vr.TrialSettings.BlockLog-1)
                    vr.trial_module = ceil(rand*3);
                end
                vr.trial_module_log(vr.TrialSettings.BlockLog+1) = vr.trial_module;
                vr.worldcode_visited = [vr.currentWorld,vr.worldcode_visited];
                vr.currentWorld = vr.worldcode(1,1);
                vr.pos_offset = vr.cstart;
                vr.position = ([0 vr.cstart 3 0]);
                vr.TrialSettings.iTrial = vr.TrialSettings.iTrial+1;
                
            else
              vr.worldcode_visited = [vr.currentWorld,vr.worldcode_visited];
              vr.currentWorld = vr.worldcode(vr.trial_module,2);
              vr.pos_offset = vr.tstart;
              vr.position = ([0 vr.tstart 3 0]);
              vr.TrialSettings.iTrial = vr.TrialSettings.iTrial+1;

            end
        end
    end
 vr.pos = vr.position(2) - vr.pos_offset;

end