

function vr = MoveFixingPoint (vr)

%vr.worlds{vr.currentWorld}.surface.visible(1, vr.WallIndx) = false;


 if vr.timeElapsed - vr.PeriodOfNewSampleTs(end)  > vr.PeriodOfNewSample
%     
% vr.MinSpeed = 0;    
vr.speed = vr.MinSpeed + (vr.MaxSpeed-vr.MinSpeed).*rand(1,1);
vr.speed = normrnd(vr.MeanSpeed,vr.StSpeed) ;
%disp(['Speed = ' num2str(vr.speed) ]);

%% b = wrapTo360(vr.CurrentAngle - vr.DirRange/2))
%% a = wrapTo360(vr.CurrentAngle + vr.DirRange/2))

%% Distance from Y Borders
vr.DistanceFromTheBottom = pdist([vr.pos; [vr.pos(1) min(vr.WallYLimits)] ],'euclidean'); %% distance to the bottom
vr.DistanceFromTheTop = pdist([vr.pos; [vr.pos(1) max(vr.WallYLimits)] ],'euclidean') ;%% distance to the top
 
 
vr.DistanceFromTheLeft = pdist([vr.pos; [min(vr.WallXLimits) vr.pos(2) ] ],'euclidean') ;%% distance to the left
vr.DistanceFromTheRight =pdist([vr.pos; [max(vr.WallXLimits) vr.pos(2) ] ],'euclidean'); %% distance to the right


[vr.MinDistance,vr.ClosestWall] = min([vr.DistanceFromTheBottom  vr.DistanceFromTheTop vr.DistanceFromTheLeft vr.DistanceFromTheRight] );


if vr.ClosestWall == 1;
vr.mu = 90 +360;
    
elseif    vr.ClosestWall == 2;
       
vr.mu = 270 +360;

elseif    vr.ClosestWall == 3;
       
vr.mu = 0 +360;

elseif    vr.ClosestWall == 4;
       
vr.mu = 180 +360;

end

vr.sigma = vr.DirRange * (vr.MinDistance/vr.DistanceFromCentre);

%wrapTo360( normrnd(vr.mu,vr.sigma)) ;

vr.direction = wrapTo360( normrnd(vr.mu,vr.sigma)) ;%%wrapTo360(vr.CurrentAngle - vr.DirRange/2) + wrapTo360( (vr.CurrentAngle + vr.DirRange/2) - (vr.CurrentAngle - vr.DirRange/2) ) .*rand(1,1) ;
%disp(['Direction = ' num2str(vr.direction) ]);
%vr.direction = wrapTo360(vr.direction + 90); 


vr.CurrentAngle = vr.direction ;
vr.PeriodOfNewSampleTs =[vr.PeriodOfNewSampleTs;vr.timeElapsed];

 
end






% vr.x = vr.worlds{vr.currentWorld}.surface.vertices(1, vr.FixingPointIndx);
% vr.y = vr.worlds{vr.currentWorld}.surface.vertices(3, vr.FixingPointIndx);

vr.dx = vr.speed * cosd(vr.direction) ; 
vr.dy = vr.speed * sind(vr.direction) ; 





if vr.pos(:,1)+[vr.dx] > max(vr.WallXLimits) | vr.pos(:,1)+[vr.dx] < min(vr.WallXLimits)
vr.dx = 0;
end;

if vr.pos(:,2)+[vr.dy] > max(vr.WallYLimits) | vr.pos(:,2)+[vr.dy] < min(vr.WallYLimits)
vr.dy = 0;
end;


vr.pos =[vr.pos] + [vr.dx vr.dy] ;


% vr.x = vr.x + vr.dx;
% vr.y = vr.y + vr.dy;


% if sum(vr.x > max(vr.WallXLimits))>0;
% vr.x(vr.x > max(vr.WallXLimits)) = max(vr.WallXLimits);
% end
% 
% if sum(vr.x < min(vr.WallXLimits))>0;
% vr.x(vr.x < min(vr.WallXLimits)) = min(vr.WallXLimits);
% end
% 
% 
% 
% if sum(vr.y > max(vr.WallYLimits)) >0
% vr.y(vr.y > max(vr.WallYLimits)) = max(vr.WallYLimits);
% end
% 
% if sum(vr.y < min(vr.WallYLimits)) >0;
% vr.y(vr.y < min(vr.WallYLimits)) = min(vr.WallYLimits);
% end


vr.worlds{vr.currentWorld}.surface.vertices(1, vr.FixingPointIndx) = vr.worlds{vr.currentWorld}.surface.vertices(1, vr.FixingPointIndx)+ vr.dx;
vr.worlds{vr.currentWorld}.surface.vertices(3, vr.FixingPointIndx) =vr.worlds{vr.currentWorld}.surface.vertices(3, vr.FixingPointIndx)+ vr.dy;
%vr.worlds{vr.currentWorld}.surface.vertices(2, vr.FixingPointIndx) = vr.BallYPOS;



% vr.exper.worlds{1}.objects{vr.worlds{1}.objects.indices.objectVerticalWall}.texture.shapes{3}.x = vr.x;
% vr.exper.worlds{1}.objects{vr.worlds{1}.objects.indices.objectVerticalWall}.texture.shapes{3}.y = vr.y;
% vr.exper.worlds{vr.currentWorld}.triangulate;
fwrite(vr.Behaviour.fidBehaviour, [vr.timeElapsed vr.pos vr.TrialSettings.iTrial ]','double');

end
































