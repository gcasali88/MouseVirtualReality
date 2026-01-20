

function vr = MoveFixingPoint2 (vr)

%vr.worlds{vr.currentWorld}.surface.visible(1, vr.WallIndx) = false;
% 
% vr.MeanTrialLenght = 10; %% seconds...
% vr.SigmaTrialLenght = 2; %% seconds...

if vr.timeElapsed - vr.PeriodOfNewSampleTs(end)  > vr.PeriodOfNewSample || vr.timeElapsed==0
%   
if isempty(vr.TimeStampsAcrossTrials);
vr.TimeFromLastTrial = vr.timeElapsed ;
else
vr.TimeFromLastTrial = vr.timeElapsed- vr.TimeStampsAcrossTrials(end) ;
end
vr.DirectionToTheCentre = wrapTo360( rad2deg(atan2(vr.pos(2)- vr.CentreLocation(2),vr.pos(1)- vr.CentreLocation(1)))  ) ;
vr.DirectionAwayFromTheCentre = wrapTo360(vr.DirectionToTheCentre +180) ; 


vr.WithinTrialStrenght = [log(normcdf(vr.TimeFromLastTrial ,vr.MeanTrialLenght ,vr.SigmaTrialLenght) / normcdf(vr.MeanTrialLenght ,vr.MeanTrialLenght ,vr.SigmaTrialLenght) )]...
                            ;

vr.StrenghDirectionToTheCentre = wrapTo360(   normrnd( (360+vr.DirectionToTheCentre), (45+vr.WithinTrialStrenght)));
vr.StrenghDirectionAwayFromCentre = wrapTo360(   normrnd( (360+vr.DirectionToTheCentre), (45-vr.WithinTrialStrenght)));

vr.speed = vr.MaxSpeed + (vr.MinSpeed-vr.MaxSpeed).*rand(1,1);

vr.StrenghSpeedToTheCentre = vr.speed *  vr.WithinTrialStrenght ;

vr.StrenghSpeedAwayFromCentre = vr.speed *  vr.WithinTrialStrenght^-1 ;





%% b = wrapTo360(vr.CurrentAngle - vr.DirRange/2))
%% a = wrapTo360(vr.CurrentAngle + vr.DirRange/2))

%% Distance from Y Borders;


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

% vr.sigma = vr.DirRange * (vr.MinDistance/vr.DistanceFromCentre);

%wrapTo360( normrnd(vr.mu,vr.sigma)) ;

vr.direction = vr.StrenghDirectionToTheCentre; %wrapTo360( normrnd(vr.mu,vr.sigma)) ;%%wrapTo360(vr.CurrentAngle - vr.DirRange/2) + wrapTo360( (vr.CurrentAngle + vr.DirRange/2) - (vr.CurrentAngle - vr.DirRange/2) ) .*rand(1,1) ;
%disp(['Direction = ' num2str(vr.direction) ]);
%vr.direction = wrapTo360(vr.direction + 90); 


vr.CurrentAngle = vr.direction ;
vr.PeriodOfNewSampleTs =[vr.PeriodOfNewSampleTs;vr.timeElapsed];

 
end






% vr.x = vr.worlds{vr.currentWorld}.surface.vertices(1, vr.FixingPointIndx);
% vr.y = vr.worlds{vr.currentWorld}.surface.vertices(3, vr.FixingPointIndx);

vr.dx = [vr.StrenghSpeedToTheCentre * cosd(vr.StrenghDirectionToTheCentre)] + ...
        [vr.StrenghSpeedAwayFromCentre * cosd(vr.StrenghDirectionAwayFromCentre)]; 

vr.dy = [vr.StrenghSpeedToTheCentre * sind(vr.StrenghDirectionToTheCentre)] + ...
        [vr.StrenghSpeedAwayFromCentre * sind(vr.StrenghDirectionAwayFromCentre)]; 




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
































