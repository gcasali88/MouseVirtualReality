function vr = MoveCuesRandomly(vr);  

Objects = fields(vr.worlds{vr.currentWorld}.objects.indices );
eval(['Objects = Objects(~ismember(Objects,{' char(39) 'Floor_' num2str(vr.currentWorld) char(39) ',' char(39) 'EndPipe' char(39) '})) ;'  ]);
Objects = Objects(~ismember(Objects,'GoalCue'));
Sides = {'L' 'R'};
GoalCueRandomSide = rand(1,1);
GoalCueOnL = 0;
GoalCueOnR = 0;
CueXPos = [-25 25] ;

GoalCueOnL = GoalCueOnL+ GoalCueRandomSide<= 0.5 ;
GoalCueOnR = GoalCueOnR+ GoalCueRandomSide > 0.5 ;

%% Randomly locate cues across the entire track...
for iSide = 1  : numel(Sides);
eval(['NObjects = numel(Objects) / numel(Sides) +  GoalCueOn' Sides{iSide} ' ; ;' ]);
MinimumDistanceCriteriaMet = 0;
while MinimumDistanceCriteriaMet == 0;
tmpLocation = round((rand(NObjects,1)*vr.trackLength));
MinimumDistanceCriteriaMet = sum(diff(sort(tmpLocation) ) > vr.TrialSettings.CueSize)==numel(sort(tmpLocation))-1;
end
for iObject = (1 : numel(Objects)/numel(Sides)) +( iSide-1)*numel(Objects)/numel(Sides) ;

eval(['indx = vr.worlds{vr.currentWorld}.objects.indices.' Objects{iObject} ';' ]);
eval(['vertexFirstLast = vr.worlds{vr.currentWorld}.objects.vertices(indx,:);' ]);
eval(['vertexFirstLastIndices = vertexFirstLast(1):vertexFirstLast(end);' ]);

OldPos = nanmean(vr.exper.worlds{vr.currentWorld}.objects{iObject}.y);
NewPos = tmpLocation(iObject-(iSide-1)*numel(Objects)/numel(Sides));

eval(['vr.CueLocation.' Objects{iObject} '(vr.TrialSettings.iTrial) = NewPos; ' ])

DeltaPos = NewPos - OldPos  ;
vr.worlds{vr.currentWorld}.surface.vertices(2, vertexFirstLastIndices) = ...
vr.worlds{vr.currentWorld}.surface.vertices(2, vertexFirstLastIndices) + DeltaPos;
    
vr.exper.worlds{vr.currentWorld}.objects{iObject}.y = ...
[NewPos - vr.TrialSettings.HalfCueSize ,...
 NewPos + vr.TrialSettings.HalfCueSize];

clear indx vertexFirstLast vertexFirstLastIndices OldPos NewPos DeltaPos;
end
disp('New cue location shown...');


if eval(['GoalCueOn' Sides{iSide}]);
    indx = vr.worlds{vr.currentWorld}.objects.indices.GoalCue;
    vertexFirstLast = vr.worlds{vr.currentWorld}.objects.vertices(indx,:);
    vertexFirstLastIndices = vertexFirstLast(1):vertexFirstLast(end);

    OldYPos = nanmean(vr.exper.worlds{vr.currentWorld}.objects{indx}.y);
    NewYPos = tmpLocation(end);
    DeltaYPos = NewYPos - OldYPos  ;
    
    OldXPos = nanmean(vr.exper.worlds{vr.currentWorld}.objects{indx}.x);
    NewXPos = CueXPos(iSide) ;
    DeltaXPos = NewXPos - OldXPos  ;
    
    vr.worlds{vr.currentWorld}.surface.vertices(1, vertexFirstLastIndices) = ...
    vr.worlds{vr.currentWorld}.surface.vertices(1, vertexFirstLastIndices) + DeltaXPos;   
    
    vr.worlds{vr.currentWorld}.surface.vertices(2, vertexFirstLastIndices) = ...
    vr.worlds{vr.currentWorld}.surface.vertices(2, vertexFirstLastIndices) + DeltaYPos;   


    vr.exper.worlds{vr.currentWorld}.objects{indx}.y = ...
    [NewYPos - vr.TrialSettings.HalfCueSize ,...
     NewYPos + vr.TrialSettings.HalfCueSize];
    
    vr.exper.worlds{vr.currentWorld}.objects{indx}.x = ...
    [NewXPos ,NewXPos ];
    
    vr.RewardLocation  = NewYPos;
    
    vr.CueLocation.GoalCue(vr.TrialSettings.iTrial,:) =  [NewXPos NewYPos] ; 
    
    clear NewXPos NewYPos OldXPos OldYPos DeltaXPos DeltaYPos 
end

end
%% Now place the Goal Cue on one of the two sides at the time...






end 

