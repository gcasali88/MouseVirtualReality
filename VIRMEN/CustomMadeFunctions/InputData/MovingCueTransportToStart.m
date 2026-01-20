function [ vr ] = MovingCueTransportToStart( vr )
%Detects when mouse is at end of track and then transports back to start
if isempty(vr.pos);vr.pos = vr.position(2);end;


if vr.position(2) <= vr.trackLength+ diff(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y)/2 && ~isnan(vr.pos)
    vr.pos = vr.position(2);
else
    vr.pos = NaN;
    %vr.position(2) = 0;
end



if isnan(vr.pos);%-1 & vr.currentWorld ~= find(strcmp(vr.EnvironmentSettings.Evironments, 'HoldingRoom' ));
    if  unique(vr.worlds{vr.currentWorld}.surface.visible(FindExtremesOfArray( reshape(  vr.worlds{vr.currentWorld}.objects.vertices(1: vr.worlds{vr.currentWorld}.objects.indices.EndPipe,:),[],1)))) ==1;
        vr.HoldingRoom.ts = vr.timeElapsed;
        vr.worlds{vr.currentWorld}.surface.visible(FindExtremesOfArray( reshape( vr.worlds{vr.currentWorld}.objects.vertices(1: vr.worlds{vr.currentWorld}.objects.indices.EndPipe,:),[],1))) = 0 ;
        vr.HoldingRoom.RandomDelay= ((6-2).*rand(1,1)+2);
    end 
        vr.dp(1,:) = 0;
        vr.velocity(1,:) = 0;
        vr.movement(1,:) = 0;
      
    if  vr.timeElapsed-vr.HoldingRoom.ts > vr.HoldingRoom.RandomDelay   
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
        vr.TrialSettings.iTrial = vr.TrialSettings.iTrial + 1;
        vr.NewTria1  = +1;       
        vr.pos =0 ;
        vr.position(2)= 0;
    end

end

end


