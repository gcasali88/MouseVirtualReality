function [ vr] = RunTeletransportationRunTeletransportationMultiCompartment(vr )
%It controls the teletransportation, based on settings into VR
%%   Detailed explanation goes here (it will...)

%% Run Teletransportation...    

vr.AssignedEnvironment =[vr.AssignedEnvironment; vr.currentWorld];
vr.NewTrialStarted = 0;

if strcmp(vr.exper.worlds{vr.currentWorld}.name,'FirstIntermediatePipe') 
    if vr.position(2)+vr.dp(2) < [max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.objectVerticalWall}.y)];
       % if before moving out...

        if numel(vr.AssignedEnvironment)==1 || vr.AssignedEnvironment(end-1) == 3;
            %% if this is the first timepoint or is it the first time of a new trial, store this time point...
            %% And reset DAQ tools...
            %if vr.timeElapsed~= 0
            vr.NewTrialStarted=1;
            vr.TimeStampsAcrossTrials=[vr.TimeStampsAcrossTrials; vr.timeElapsed];  %store this timestamp
            vr.TrialSettings.iTrial = vr.TrialSettings.iTrial+1;        %increase the trial id
            [ vr ] = LoadEnvironments(vr);  %resets the visits across compartments...
            %end
        end              
        
        
        %% signal FirstIntermediatePipe ...
        if vr.timeElapsed - vr.TimeStampsAcrossTrials(vr.TrialSettings.iTrial) < vr.TrialSettings.InterTrialStop(vr.TrialSettings.iTrial) ;
            vr.exper.movementFunction = @StayStill;
        else
            %vr.exper.movementFunction = @moveForwardAtHighSpeed;
            vr.exper.movementFunction = vr.TrialSettings.movementFunctionAfterPause ;
        end
        
        %%
        if strcmp(char(vr.exper.movementFunction), 'StayStill');
                %vr.position(2)=0;
                vr.movement(2)=0;
                vr.pos=0;                    
                vr.dp(2) = 0;
        end
        
         % first from FirstPipe to Comp A...
    elseif vr.position(2)+vr.dp(2) > [[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.objectVerticalWall}.y)]];
        NewPos =+vr.position(2)-[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.objectVerticalWall}.y)];
        vr.currentWorld = 2;
        vr.position(2)  = [NewPos]; vr.dp(:);clear NewPos;
        vr.TimeStampsAcrossCompartments(vr.TrialSettings.iTrial,2) = vr.timeElapsed;
        %vr.PosStampsAcrossCompartments(vr.TrialSettings.iTrial,1) = vr.pos;
        vr.AssignedEnvironment(end)=vr.currentWorld;
    end
   
    
%if in A...
elseif strcmp(vr.exper.worlds{vr.currentWorld}.name,'A')  
    
    if vr.position(2)+vr.dp(2) < min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y)
        %Stay in A...
        vr.EnvironmentsVisited.A=1;
        vr.AssignedEnvironment(end)=vr.currentWorld;
    else vr.position(2)+vr.dp(2)>min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
        %Switch from A to Pipe...
    NewPos = vr.position(2) - min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
    vr.currentWorld=3;
    vr.position(2) = NewPos;;vr.dp(:);
    vr.AssignedEnvironment(end)=vr.currentWorld;
    clear NewPos;
    end
%% if in IntermediatePipe...
elseif  strcmp(vr.exper.worlds{vr.currentWorld}.name,'IntermediatePipe') ... 
     
    if  vr.position(2)+vr.dp(2)<[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)] ;
        vr.EnvironmentsVisited.IntermediatePipe=1;
        vr.AssignedEnvironment(end)=vr.currentWorld;
        NewEnv = vr.currentWorld;

%% Exits from Intermediate Pipe
    elseif  vr.position(2)+vr.dp(2)>[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]
            % Send to Bi (NewEnv = 4);
            if      vr.pos < 2*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    1*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)]
                NewEnv =4 ;
                vr.EnvironmentsVisited.B=1;
                NewPos = vr.position(2)- max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                vr.AssignedEnvironment(end) = vr.currentWorld ;
                % Send to Bii (NewEnv = 4);
            elseif  vr.pos > 2*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    1*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)] & ...
                    vr.pos < 3*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    2*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)]
                NewEnv =4 ;
                vr.EnvironmentsVisited.B=2;
                NewPos = vr.position(2)- max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                vr.AssignedEnvironment(end) = vr.currentWorld ;
                % Send to C (NewEnv = 5);
            elseif  vr.pos > 3*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    3*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)] & ...
                    vr.pos < 3*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    4*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)]
                NewEnv =5;
                vr.EnvironmentsVisited.C=1;
                NewPos = vr.position(2)- max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                vr.AssignedEnvironment(end) = vr.currentWorld ;
                % Send to P1 (NewEnv = 1);
            elseif  vr.pos > 4*[max(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipeWall}.y)]+ ...
                    4*[min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)]
                
                if vr.TrialSettings.iTrial == vr.TrialSettings.MaxNumerTrials;
                    vr.experimentEnded=1;
                end
                NewEnv =1;
                NewPos= 0;
            end
        vr.position(2) = NewPos;
        %vr.dp(:);
        vr.currentWorld = NewEnv;  
        %vr.AssignedEnvironment(end) = vr.currentWorld ;
        clear NewPos NewEnv;
    end

%% in B...
elseif strcmp(vr.exper.worlds{vr.currentWorld}.name,'B')  
        if  vr.position(2)+vr.dp(2) < min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y)
            vr.AssignedEnvironment(end)= vr.currentWorld;
        elseif vr.position(2)+vr.dp(2)>= min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                NewPos = [vr.position(2)] - [min(vr.exper.worlds{2}.objects{vr.worlds{2}.objects.indices.EndPipe}.y)];
                NewEnv=3;
                vr.position(2) = NewPos;
                %vr.dp(:);
                vr.currentWorld = NewEnv;  
                vr.AssignedEnvironment(end)=vr.currentWorld;
                clear NewPos NewEnv; 
        end
% in C...
elseif strcmp(vr.exper.worlds{vr.currentWorld}.name,'C')  
        if      vr.position(2)+vr.dp(2) < min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y)
                vr.AssignedEnvironment(end)=vr.currentWorld;
        elseif  vr.position(2)+vr.dp(2)>= min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                NewPos = [vr.position(2)]+vr.dp(2) - min(vr.exper.worlds{vr.currentWorld}.objects{vr.worlds{vr.currentWorld}.objects.indices.EndPipe}.y);
                NewEnv=3; %it was 3...
                vr.position(2) = NewPos;
                %vr.dp(:);
                vr.currentWorld = NewEnv;  
                vr.AssignedEnvironment(end)=vr.currentWorld;
                clear NewPos NewEnv; 
        end
end

if numel(vr.AssignedEnvironment) == 1;
vr.pos = vr.dp(2);
elseif vr.AssignedEnvironment(end)==1 & vr.AssignedEnvironment(end-1) == 3; %that is the shift between environment 3 (pipe) to environment 1 (initial pipe)
vr.pos = vr.dp(2) ;
else
vr.pos = vr.dp(2)+ vr.pos;   
end

%% Store Behavioural data
[ vr] = LogBehaviouralData(vr);

