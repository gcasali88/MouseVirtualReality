function vr = SetMovingPointSettings(vr)

vr.FixingPointIndxFirstLast =    vr.worlds{vr.currentWorld}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.Point,:);
vr.FixingPointIndx = [vr.FixingPointIndxFirstLast(1):vr.FixingPointIndxFirstLast(end)];
vr.MeanTrialLenght = 10; %% seconds...
vr.SigmaTrialLenght = 2; %% seconds...

%vr.WallIndxFirstLast =    vr.worlds{vr.currentWorld}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.Wall,:);
%vr.WallIndx = [vr.WallIndxFirstLast(1):vr.WallIndxFirstLast(end)];

vr.PeriodOfNewSample = 1; %in seconds...  %% it was 2
vr.PeriodOfNewSampleTs = 0; %in seconds...

vr.MinSpeed = 0;
vr.MaxSpeed = 4;        %% it was 4
vr.MeanSpeed = 1 ;      %% it was 1    
vr.StSpeed = .5 ;      %% it was .5


vr.DirRange = 270;% in degrees
vr.CurrentAngle = rad2deg(2*pi*rand(1));
vr.CurrentAngle = wrapTo360( vr.CurrentAngle + 90);
vr.direction = vr.CurrentAngle;%(vr.CurrentAngle + vr.DirRange/2) + (( vr.CurrentAngle - vr.DirRange/2) - (vr.CurrentAngle + vr.DirRange/2) ) .*rand(1,1);

vr.speed = vr.MaxSpeed + (vr.MinSpeed-vr.MaxSpeed).*rand(1,1);

vr.WallYLimits = [-120 120]; %[vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Wall}.bottom vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Wall}.top];
vr.WallXLimits = [-120 120];%[vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Wall}.x];% vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.Wall}.top];
%vr.BallYPOS =     vr.worlds{vr.currentWorld}.surface.vertices(2, vr.FixingPointIndx) ;
%vr.worlds{vr.currentWorld}.surface.visible(1, vr.WallIndx) = false;

%% Settings for the reward area...
vr.RewardCircleIndxFirstLast =   vr.worlds{vr.currentWorld}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.GoalCue,:);
vr.RewardCircleIndx = [vr.RewardCircleIndxFirstLast(1):vr.RewardCircleIndxFirstLast(end)];


%% If you want to change this...
vr.CentreLocationRandomShiftX = 0;%normrnd(0, [vr.WallXLimits(2) - vr.WallXLimits(1)]/6 , 1) ; %%randi(vr.WallXLimits,1);
vr.CentreLocationRandomShiftY = 0;%normrnd(0, [vr.WallYLimits(2) - vr.WallYLimits(1)]/6 , 1) ; %%randi(vr.WallYLimits,1);

vr.worlds{vr.currentWorld}.surface.vertices(1,vr.RewardCircleIndx) = vr.worlds{vr.currentWorld}.surface.vertices(1,vr.RewardCircleIndx)  + vr.CentreLocationRandomShiftX ;
vr.worlds{vr.currentWorld}.surface.vertices(3,vr.RewardCircleIndx) = vr.worlds{vr.currentWorld}.surface.vertices(3,vr.RewardCircleIndx)  + vr.CentreLocationRandomShiftY ;

vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.x = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.x + vr.CentreLocationRandomShiftX ;
vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.elevation = vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.elevation + vr.CentreLocationRandomShiftY ;

vr.CentreLocation = [vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.x , ...
vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.elevation ] ;


vr.DistanceFromCentre = pdist( [0 0; [min(vr.WallYLimits) max(vr.WallYLimits)] ],'euclidean'); %% distance to the bottom
vr.Behaviour.fidBehaviour = fopen('Behaviour.data','w');%creates the file where the behavioural data is stored (better than updating this into the vr structure)...
vr.pos = [vr.exper.worlds{vr.currentWorld}.objects{1}.x vr.exper.worlds{vr.currentWorld}.objects{1}.elevation ] ;
[~,vr.circle.xp,vr.circle.yp]=circle(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.x,vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.elevation,vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.GoalCue}.majorRadius,0);


end