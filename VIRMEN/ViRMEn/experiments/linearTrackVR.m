function code = linearTrackVR
% linearTrackWithCylinders   Code for the ViRMEn experiment linearTrackWithCylinders.
%   code = linearTrackWithCylinders   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% --- INITIALIZATION code: executes before the ViRMEN engine starts. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vr = initializationCodeFun(vr)

%% hardware initialisation
% First, there are a couple of things that we only do when it is a real trial: initialise DAQ hardware, and data save file.
% Important note on 'vr.debugMode':scanimage
%    0=no debugging, all hardware is present, run it for real, 
%    1=full debug mode active, no hardware required no files written
%    2=no hardware interaction, but will save data files.
vr.debugMode = eval(vr.exper.variables.debugMode);

if vr.debugMode == 0
    vr = initialiseHardware(vr);
end

%% UI input for log file
% (2) Get some trial name information, and 2P recording time. This needs to come first, not post-trial, as the user needs to input the current scanimage trial_XXX number %
% First, get user input on trial names etc %
trialConfigInput = inputdlg({'Mouse number','Virmen trial letter (CAPITALS please!)','2P starting trial number','2P default trial length'},'Enter trial info',[1; 1; 1; 1], ...
                            {'m234', 'A', '1', vr.exper.variables.default2PhotonRecordingDuration});
% Save these to vr. struct.
vr.virmenFileLetter = trialConfigInput{2};
vr.finalFileName = [trialConfigInput{1} '_' datestr(now,'yyyymmdd') '_' vr.virmenFileLetter];
vr.currentFileIdx2P = str2double( trialConfigInput{3} );
vr.recordingDuration2P = str2double(trialConfigInput{4});

%% Initialisation
% (4) Initialise some key variables in the vr. structure. %
% (4a) Rewards - world specific:
for i = 1:length(vr.exper.worlds)
    for j=1:length( vr.exper.worlds{i}.objects )
        if regexp( vr.exper.worlds{i}.objects{j}.fullName, regexptranslate('wildcard','rewardZone*') ); ind=j; break; end
    end
    
    vr.rewardLocations{i} = vr.exper.worlds{i}.objects{ind}.y;  % This contains a 1:nReward list of the y locations of the reward zone centres.
    vr.nRewardZones{i} = length(vr.rewardLocations{i});
    %
    vr.rewardIsActive{i} = true(vr.nRewardZones{i},1);  % This will control: a) is it visible, b) can it drive the solenoid output
    %
    % (4b) Rewards: also need the 'raw' vertices and triangles that constitute the reward zones, so that they can be made invisible when inactive.
    % This is tricky, as all of the different vertices and triangles are grouped together under one object, so we have to first
    % retrive them, then split them up on the basis of their location in the world.
    temp_fNames = fieldnames(vr.worlds{i}.objects.indices);
    ind = ~cellfun('isempty',strfind(temp_fNames,'rewardZone')); %as reward zones are called differently in each world this needs to be checked a bit cumbersome
    clear temp_fNames
    
    rewardVerInd = vr.worlds{i}.objects.vertices(ind,:);   % = the 'start' and 'stop' inds of the vertices that correspond to the rewardZone object
    rVert = vr.worlds{i}.surface.vertices(:,rewardVerInd(1):rewardVerInd(2));  % These are now the actual vertices
    rr = eval( vr.exper.variables.rewardRadius );  % This is the reward radius, NOTE, it is a string in vr., you need to 'eval' it.
    vr.rewardTriIndByZone{i} = cell(length(vr.rewardLocations{i}),1);        % This is going to be the indices of triangles which belong to which reward zone
    for k=1:length(vr.rewardLocations{i})                               % based on the position on the track.
        % For each reward zone, which vertices are within poistion +/- radius?
        singleZoneVertInd = find(  rVert(2,:)>vr.rewardLocations{i}(k)-(rr*1.2) & rVert(2,:)<vr.rewardLocations{i}(k)+(rr*1.2)  )  +  rewardVerInd(1)  -   1;   % Need to add 'rewardVerInd(1)-1', so that it becomes an index into the *full* vertex array, not just that for reward zone.
        % .. unfortunately, only triangles, not vertices have the 'visibility' property, so we now need to work out  which traingles use these vertices ..
        temp = ismember( vr.worlds{i}.surface.triangulation, singleZoneVertInd );
        vr.rewardTriIndByZone{i}{k} = any( temp, 1 );   % And then store this index
        %save indices of zones - we need that for shifting the rewards
        %around (really only 1 and 2)
        vr.rewardVertices{i}{k} = singleZoneVertInd;
    end
end
%some general reward related stuff (global)
vr.nRewardsGiven = 0;  % This keeps track of the total number of rewards recieved by the mouse
vr.rewardTriggerRadius = eval( vr.exper.variables.rewardTriggerRadius );  % This sets how close to the reward centre to actually trigger the reward.
vr.currRewardDropSize = eval(vr.exper.variables.rewardDropSize); %for updating the reward drop size
vr.maxPossRewardDropSize = eval( vr.exper.variables.maxPossRewardDropSize ); %max possible reward drop size (5)
vr.sRateSolanoid = eval(vr.exper.variables.sRateSolanoid); %sample rate
vr.interRewardDist = eval( vr.exper.variables.interRewardDistHP ); %distance between rewards in HP (in Virmen units)
vr.isReward = 0;
vr.isRewardBlock = true;      % blocks reward activation
vr.isfirstRewardShift = false; %state variable for shifting first reward in environment right in front of animal

% (4c) Some other general variables %
vr.isRecording = false;      % Are we currently recording virmen data?
vr.isExit = false;           % fail safe so exiting includes sanity check
vr.isRecording2P = false;    % Are we also currently recording 2P data?
vr.recordingStartTime = [];      % Keep track of the start time for the virmen recording session
vr.recordingStartTime2P = [];   % Keep track of the start time for the current 2P recording session
vr.recordingExists = false;   % Set this to true if the virmen recording is run, so we know to deal with file in the termination function.
vr.currentDirection = eval(vr.exper.variables.startDirection); % The current direction of the animal on the track, 1=N (increasing y), -1=S (decreasing y)
vr.turnaroundActive = false;     % Signals whether the animal is currently in the turnaround screen-blanked period 
vr.turnaroundStartTime = [];     % Will act as a timer, such that the turnaround blanking is of the correct duration.
vr.turnaroundDelay = eval( vr.exper.variables.turnaroundDelay );  % Get the turnaround blanking duration (user-set) in a more convenient format.
vr.trackLength = eval( vr.exper.variables.trackLength );
vr.movementGain = eval( vr.exper.variables.movementGain );
vr.monitorAspectRatio = eval( vr.exper.variables.monitorAspectRatio );
vr.perspectiveScale = eval( vr.exper.variables.perspectiveScale );
vr.wheelCircumference = eval( vr.exper.variables.wheelCircumference );

if vr.debugMode~=1
    vr.tempFileDir = 'F:\';
    vr.tempFileLocation = [vr.tempFileDir 'virmenTempData.dat'];
    vr.tempFileLocationTXT = [vr.tempFileDir 'virmenTempData.txt'];
    if ~isdir(vr.tempFileDir)
        mkdir(vr.tempFileDir);
    end
    vr.tempFileFid = fopen(vr.tempFileLocation,'w');  % The actual data always goes in this temp file during the recording.
    vr.tempFileFidTXT = fopen(vr.tempFileLocationTXT,'w');
    %write header
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','########## Header ##########');
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n','Mouse ID:', trialConfigInput{1});
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n','Date:', datestr(now,'yyyymmdd'));
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n','Data file name:', vr.finalFileName);
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','############################');
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','### Imaging Session Info ###');
end

%switch to holding env
vr.currentWorld = strcmp(cellfun(@(x) x.name,vr.exper.worlds,'UniformOutput',false),'holdingEnvironment'); 
vr.worldToggle = true; %will prevent world to be switched within switch over delay
vr.switchDelay = eval( vr.exper.variables.worldSwitchDelay ); %delay when switching between worlds
vr.worldNames = cellfun(@(x) x.name,vr.exper.worlds,'UniformOutput',false); %world name is not easily accessible otherwise
vr.teleportPoint = eval(vr.exper.variables.teleportPoint); %point on HP track where animal is teleported back


%% Textbox controls
% (3) Initialise text boxes for controls %
% (3a) Pos recording start/stop button
textWindowIdx = [5, 6, 7];
n=1;
vr.text(n).string = 'POS REC START';
vr.text(n).position = [-0.65 0.65];
vr.text(n).size = 0.1;
vr.text(n).color = [0 1 0];  % Should be green initially, switch to red for 'STOP'
vr.text(n).window = textWindowIdx(1);
% (3b) Pos recording time elapsed timer (shows trial name when not recording)
n=2;
vr.text(n).string = ['(RECORD TO FILE ' vr.virmenFileLetter, ')']; % This refers to the virmen .dat file name
vr.text(n).position = [-0.73 0.5];
vr.text(n).size = 0.08;
vr.text(n).color = [1 1 1];  % White
vr.text(n).window = textWindowIdx(1);
% (3c) 2P record start/stop button
n=3;
vr.text(n).string = '2PHOTON REC START';
vr.text(n).position = [-0.85 0.05];
vr.text(n).size = 0.1;
vr.text(n).color = [0.5 0.5 0.5];   % Grey initially, switch to green (for active) when virmen recording is active
vr.text(n).window = textWindowIdx(1);
% (3d) 2P record time elapsed timer (when not recording, displays trial # to be used next)
n=4;
vr.text(n).string = ['(' num2str(vr.recordingDuration2P) 'SEC, TO FILE ' num2str(vr.currentFileIdx2P,'%03i'), ')'];
vr.text(n).position = [-0.84 -0.1];
vr.text(n).size = 0.08;
vr.text(n).color = [1 1 1];
vr.text(n).window = textWindowIdx(1);
% (3e) button will change what happens when  recording is started
n=11;
vr.text(n).string = '2PHOTON REC MODE';
vr.text(n).position = [-0.85 -0.57];
vr.text(n).size = 0.1;
vr.text(n).color = [1 1 1];  
vr.text(n).window = textWindowIdx(1);
% modes: 'switch' - switch world from current world; 'stay' - record in
% current world; 'track' - record on track (i.e. switch when in HP, stay
% when already on track
n=12;
vr.text(n).string = 'TRACK';
vr.text(n).position = [-0.3 -0.8];
vr.text(n).size = 0.1;
vr.text(n).color = [1 0 0];   
vr.text(n).window = textWindowIdx(1);
% (3f) Immediate reward button.
n=5;
vr.text(n).string = 'REWARD NOW';
vr.text(n).position = [-0.5 -0.65];
vr.text(n).size = 0.1;
vr.text(n).color = [0 0 1];
vr.text(n).window = textWindowIdx(2);
% (3g) buttons to regulate amount of reward
n=6;
if vr.currRewardDropSize > vr.maxPossRewardDropSize
    vr.text(n).color = [0.5 0.5 0.5];
    vr.currRewardDropSize = vr.maxPossRewardDropSize;
    vr.rewardPattern = [ ones(vr.currRewardDropSize,1).*5; 0; 0; 0; 0];
else
    vr.text(n).color = [0 1 0];
end
vr.text(n).string = ['MORE (' num2str(vr.currRewardDropSize*1000/vr.sRateSolanoid) 'MS)'];
vr.text(n).position = [-0.6 0.35];
vr.text(n).size = 0.1;
vr.text(n).window = textWindowIdx(2);

n=7;
vr.text(n).string = ['LESS (' num2str(vr.currRewardDropSize*1000/vr.sRateSolanoid) 'MS)'];
vr.text(n).position = [-0.6 0.2];
vr.text(n).size = 0.1;
if vr.currRewardDropSize <= 1
    vr.text(n).color = [0.5 0.5 0.5];
    vr.currRewardDropSize = 1;
    vr.rewardPattern = [ 5; 0; 0; 0; 0 ];
else
    vr.text(n).color = [0 1 0];
end
vr.text(n).window = textWindowIdx(2);
% reward distance buttons
n=13;
vr.text(n).string = ['FURTHER (' num2str(vr.interRewardDist) 'CM)'];
vr.text(n).position = [-0.8 -0.15];
vr.text(n).size = 0.1;
vr.text(n).color = [0 1 0];
vr.text(n).window = textWindowIdx(2);

n=14;
vr.text(n).string = ['CLOSER (' num2str(vr.interRewardDist) 'CM)'];
vr.text(n).position = [-0.76 -0.30];
vr.text(n).size = 0.1;
if vr.interRewardDist <= 25
    vr.text(n).color = [0.5 0.5 0.5];
    vr.interRewardDist = 25;
else
    vr.text(n).color = [0 1 0];
end
vr.text(n).window = textWindowIdx(2);
% this button will activate feeder so animal can be rewarded
n=8;
vr.text(n).string = 'REWARD OFF';
vr.text(n).position = [-0.5 0.7];
vr.text(n).size = 0.1;
vr.text(n).color = [0.5 0.5 0.5];
vr.text(n).window = textWindowIdx(2);
% button to switch manually between worlds
n=9;
vr.text(n).string = 'SWITCH WORLD';
vr.text(n).position = [-0.6 0.65];
vr.text(n).size = 0.1;
vr.text(n).color = [1 0 0];
vr.text(n).window = textWindowIdx(3);
% name of current world
n=10;
vr.text(n).string = 'HOLD';
vr.text(n).position = [-0.18 0.3];
vr.text(n).size = 0.1;
vr.text(n).color = [0.8 0.8 0.8];
vr.text(n).window = textWindowIdx(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (5) Finally, we actually need to initialise some things about the first 
%     run in the world.
% Set the starting reward to be inactive and invisible, and set vr.nextReward correctly %
if vr.currentDirection == 1         % Depending the starting direction, inactive the first reward the animal will see at the end of the track.
    vr.nextReward = 2;                
else 
    vr.nextReward = vr.nRewardZones{ vr.currentWorld } - 1;  
end

for i = 1:length(vr.exper.worlds)
    %set all rewards to be invisible
    tempInd =  [ vr.rewardTriIndByZone{ i }{  vr.rewardIsActive{ i } } ];
    vr.rewardLocInd{i} =  any( reshape( tempInd,length(vr.worlds{ i }.surface.visible),[] ),2 ); %save index for convenience
    vr.worlds{ i }.surface.visible( vr.rewardLocInd{i} ) = false;  % Set rewards to be invisible.
end
assignin('base','vr',vr);   % For debugging purposes.


%% Run time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% --- RUNTIME code: executes on every iteration of the ViRMEn engine. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vr = runtimeCodeFun(vr)

%% world control
%Check if world has to be switched
if vr.textClicked==9 && vr.worldToggle
    vr = worldSwitch(vr);
end

%% grab current reward index ()
%we need this index quite a lot, so store it
vr.currRewardInd =  vr.rewardTriIndByZone{ vr.currentWorld }{  vr.nextReward };

%% re-set fail safe for exit if clicked accidently
if vr.isExit && ~isnan(vr.textClicked) && vr.textClicked~=1 && ~strcmp(vr.text(1).string,'PLEASE EXIT VIRMEN') 
    vr.text(1).string = 'POS REC STOP';
    vr.text(1).color = [1 0 0];
    vr.text(1).position = [-0.65 0.65];
    vr.text(1).size = 0.1;
    vr.isExit = false;
end

%% run time
if strcmp(vr.exper.worlds{vr.currentWorld}.name,'linearTrack')
    vr = runTime_linTrack(vr);    
elseif strcmp(vr.exper.worlds{vr.currentWorld}.name,'holdingEnvironment')
    vr = runTime_holdEnv(vr);    
end

%% recording/data logging
vr = recControl( vr );

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% --- TERMINATION code: executes after the ViRMEn engine stops. ---  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vr = terminationCodeFun(vr)

if vr.debugMode ~= 1 && vr.recordingExists
    % Move the temp data files to the final directory %
    finalDataDir = uigetdir('F:\MouseData','Choose a folder to save the data');
    copyWorked = copyfile(vr.tempFileLocation, [finalDataDir, '/', vr.finalFileName, '.dat']);
    exper = copyVirmenObject(vr.exper); %#ok<NASGU>
    %txt output
    %txt file output
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','############################');
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','### ViRMEn Session Info ####');
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n','ViRMEn recording start:', char(vr.sessionTime(1)) );
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n','ViRMEn recording stop:', char(vr.sessionTime(2)) );
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t\r\n\r\n','ViRMEn session duration (hh:mm:ss):', datestr(vr.sessionTime(2)-vr.sessionTime(1),'HH:MM:SS'));
    fprintf(vr.tempFileFidTXT,'%-s\r\n\r\n','############################');
    
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','##### DAT File Format ######');
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','Note: First entry in DAT file is n of columns to extract');
    fprintf(vr.tempFileFidTXT,'%-s\t %-s\t   %-s\t   %-s\t   %-s\t   %-s\t   %-s\t   %-s\t   %-s\t   %-s\t   %-s\t  %-s\t  %-s\t\r\n\r\n','Dat file structure (column names):','Time','Xpos',...
            'Ypos','Dir','Xspeed','Yspeed','TrialID_2P','2P frame #','-isReward','rewardDropSize','-isTurn', 'WorldIndex');
    for i = 1:length(vr.worldNames)  
        fprintf(vr.tempFileFidTXT,'%-s\t %s\t %s\t\r\n\r\n','World index:',num2str(i),vr.worldNames{i});
    end
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','#############################');
    %add some 2P settings info
    fprintf(vr.tempFileFidTXT,'%-s\t\r\n\r\n','##### 2P Settings Info ######');
    %if sessions were recorded add some UI defined info
    if vr.currentFileIdx2P > 1
        UIdialogStr = cell(vr.currentFileIdx2P-1,3);
        for n = 1:vr.currentFileIdx2P-1
            UIdialogStr{n,1} = ['Session ' num2str(n,'%03i') ' Power (mW):' ];
            UIdialogStr{n,2} = ['Session ' num2str(n,'%03i') ' PMT gain:' ];
            UIdialogStr{n,3} = ['Session ' num2str(n,'%03i') ' FOV #:' ];
        end
        TXTInput = inputdlg( UIdialogStr,'Enter additional Session info',ones(numel(UIdialogStr),1),horzcat(cellstr(repmat('50',numel(UIdialogStr)/size(UIdialogStr,2),1))',...
            cellstr(repmat('450',numel(UIdialogStr)/size(UIdialogStr,2),1))',cellstr(repmat('1',numel(UIdialogStr)/size(UIdialogStr,2),1))'));
        for n = 1:vr.currentFileIdx2P-1
            fprintf( vr.tempFileFidTXT,'%-s\t %-s\t\r\n',['Imaging ' UIdialogStr{n,1}], TXTInput{n});
            fprintf( vr.tempFileFidTXT,'%-s\t %-s\t\r\n',['Imaging ' UIdialogStr{n,2}], TXTInput{n+size(UIdialogStr,1)} );
            fprintf( vr.tempFileFidTXT,'%-s\t %-s\t\r\n\r\n',['Imaging ' UIdialogStr{n,3}], TXTInput{n+2*size(UIdialogStr,1)} );
        end
    end
    fprintf(vr.tempFileFidTXT,'%-s\t','############ END ############');
    %
    if copyWorked
        delete(vr.tempFileLocation);
        save([finalDataDir, '\', vr.finalFileName, '.mat'],'exper');  % ALso save the 'exper' structure with the data. 
        copyfile(vr.tempFileLocationTXT, [finalDataDir, '\', vr.finalFileName, '.txt']);
    else
        disp(['!!IMPORTANT NOTICE!! There was a problem moving temporary recording file to final data folder.' ...
            ' Temp files are still in present, in ' vr.tempFileDir]);
        save([vr.tempFileDir 'virmenTempData.mat'],'exper');     % Save the 'exper' structure to the temp folder, in this case.
    end 
end

% Close all file handles %
fclose all;
