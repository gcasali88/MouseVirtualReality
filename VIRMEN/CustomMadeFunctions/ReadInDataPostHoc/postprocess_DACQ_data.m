function [ mtint ] = postprocess_DACQ_data( mtint )
% does postprocessing on data collected from readDACQdata.m
% mainly does positional processing as readDACQdata.m uses rawpos.m which
% returns raw led positions, timestamps and num led pixels directly from
% the .pos file with very little processing.
% Could also do other post-processing steps here


% try out mtints postprocess_pos_data
maxSpeed = 1; % in m/s?
boxcar = 0.4; % in ms - same value as tint classic (on base window)
[xy, dir, speed, times, jumpyPercent] = postprocess_pos_data(mtint.pos, maxSpeed, boxcar, mtint.header);
pix_per_metre = key_value('pixels_per_metre', mtint.pos.header, 'num') /100; %;


mtint.pos.xy_pixels = xy;
mtint.pos.xy_cm     = xy/pix_per_metre;
mtint.pos.dir = dir;
mtint.pos.speed = speed;
mtint.pos.jumpyPercent = jumpyPercent;
mtint.pos.led_pos;
% deal with any pos sample values that are outside the range of valid
% positions


% ------------- output some potentially useful data to the cli ------------
fprintf('%d files read:\n',numel(mtint.flnmroot));
if iscell(mtint.flnmroot)
    for i = 1:numel(mtint.flnmroot)
        fprintf('%s\n',[mtint.filepath,mtint.flnmroot{i}]);
    end
else
    fprintf('%s\n',[mtint.filepath,mtint.flnmroot]);
end

for i = 1:numel(mtint.tetrode)
    fprintf('Read %d spikes from tetrode %d\n',numel(mtint.tetrode(i).pos_sample),mtint.tetrode(i).id);
end
fprintf('%d positions read from %d leds with %g %% jumpy positions\n',numel(mtint.pos.xy_pixels(:,1)), size(mtint.pos.led_pos,2),jumpyPercent);
fprintf('Positions smoothed with %dms average\n',boxcar*1000);
fprintf('Read %d EEG points\n',numel(mtint.EEG.EEG));
duration = key_value('duration',mtint.pos.header,'num');
fprintf('Total trial time: %d\n',duration);
for i = 1:numel(mtint.tetrode)
    if isempty(mtint.tetrode(i).cut)
    else
        fprintf('Cut file loaded for tetrode: %d\n',i);
    end
end