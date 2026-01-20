function ConcatenateAndBatchCluFiles( Parameters, SetFiles )
%Based on LM functions, it combines multiples sessions (i.e. open field +
%VR sessions), in a single Tetrode file with the suffis _concatenated.
% A method to batch the runKK is missing atm.
%   Detailed explanation goes here
%% Check for cut files first...
CutFiles = dir([Parameters.FilePath '*.cut']);  
   

%% and ... clu files 
files = dir;
CluFiles = ConcatentateIntoStructureIndices(files,'.','name',[],11);
CluFiles = files(find(~cellfun(@isempty,strfind(CluFiles , 'clu'))));
clear files 
%% Create the prms structure...
prms.fNames = SetFiles;
prms.dataRootDir = Parameters.FilePath;
prms.writeDir = [Parameters.FilePath 'ConcatenatedTrials'];
mkdir(prms.writeDir);
prms.addStr = '_Concatenated'; % string to be added to file (dateStamp(XX).(tetNum))
% just for tint
prms.leaveOverhang = 1; % flag for removing/leaving trial overhang
% just for kilosort
prms.sRate = 48000; %sample rateprms.noiseMax = 5; 
prms.tempWriteDir = [prms.writeDir '\'];
prms.TempFolderMachine = 'C:\Users\ucbtgc0\AppData\Local\Temp\'; %path to temp folder (usually hidden) in windows (updating username should do the trick)
prms.fancyKKpath = 'C:\Program Files (x86)\Axona\fancykk\';
[~,tetsAvailable] = list_and_check_DACQFiles( prms.dataRootDir,cellstr(prms.fNames) );
prms.fNameOut = {};

%% Run the tetrode-concatenation in batches of trials to map cells across days....
%% First condition is that no cut files already exist (i.e. - you already accounted for the clu/cut transformation)....
if numel(CutFiles)~=0
CutName = textscan(char(CutFiles(1).name), '%s' , 'Delimiter', {'.cut'}); 
CutName=CutName{1};
CutName = textscan(char(CutFiles(1).name), '%s' , 'Delimiter', {'_'})   ; 
CutName = ([reshape(CutName{1,1}(1:end-1,1),1,size(CutName{1},1)-1 )]) ;
%CutName = strcat(CutName{:}) ;
SetFileName = textscan(char(SetFiles(1)), '%s' , 'Delimiter', {'.set'}); 
SetFileName =  SetFileName{1} ;
SetFileName = textscan(char(SetFileName), '%s' , 'Delimiter', {'_'})   ; 
SetFileName = ([reshape(SetFileName{1,1}(1:end,1),1,size(SetFileName{1},1) )]);
%SetFileName = strcat(SetFileName{:}) ;
else
    CutName = '';
end
 
if numel(CluFiles)~=0
CluName = textscan(char(CluFiles(1).name), '%s' , 'Delimiter', {'.clu'});CluName=CluName{1}(1) ;
else
    CluName = '';
end
if numel(CutFiles) > 0  && ... == max(tetsAvailable)
         strcmp(strcat(CutName{:}),strcat(SetFileName{:}))   ;; %strcmp((CutName) , SetFiles{1}(1:end-4) );    
% it means that you have alraedy cut the cells so ignore everything
% below....
disp(['Tetrodes already cut, skip concatenations and KKWick...' ])
elseif numel(CutFiles) == 0 && numel(CluFiles) == max(tetsAvailable) &&  strcmp ( CluName , SetFiles{1}(1:end-4) );    
disp(['Tetrodes already clustered, skip concatenations and KKWick...' ])
  
else 
    
%% Creater combined tetrode data...
% Search if any trial was alraedy concatenated 
cd(prms.writeDir) ;
files = dir();
fileNames = ConcatentateIntoStructureIndices(files,'.','name',[],11) ;
RealConcatenatedFiles = find(~cellfun(@isempty,strfind(fileNames , '_Concatenated')));
RealCluFiles = find(~cellfun(@isempty,strfind(fileNames , 'clu')));
ConcatenatedFiles = files(RealConcatenatedFiles(~ismember(RealConcatenatedFiles,RealCluFiles))) ;
ConcatenatedFileNames = ConcatentateIntoStructureIndices(ConcatenatedFiles,'.','name',[],0)	;

if numel(ConcatenatedFiles) == max(tetsAvailable)
disp('Skip Concatenation....');
for iTetrode = tetsAvailable; prms.fNameOut{iTetrode} = ConcatenatedFiles(iTetrode).name ; end;
else
cd(prms.writeDir) ;
for iTetrode = tetsAvailable
[dirOut, prms.fNameOut{iTetrode}] = concat_TetrodeTrialData( iTetrode, 'tint',prms);
disp(['Tetrode ' num2str(iTetrode) ' succesfully concatenated...' ])
end;
end
%% Now create a filelist with the name of the trials to run KKwick...

cd(prms.TempFolderMachine)
fid = fopen([prms.TempFolderMachine 'fancy_kk_commands.list'],'w');
for iTetrode = tetsAvailable
fprintf(fid,'"%s%s"\r\n',prms.tempWriteDir,prms.fNameOut{iTetrode}); %it was...
% fprintf(fid,'"%s%s"\r\n', [prms.TempFolderMachine,prms.fNameOut] ); %
end;
fclose(fid);

disp('KKWick called...');
system([prms.fancyKKpath 'runkk.bat'],'-echo'); %call fancy KK 
%%  Once the Clu files are created somehow, move those clu generated files into the main directory when you can drag them together with the name of the first session...
cd(prms.writeDir) ;
CluFilesGenerated = 0;
while CluFilesGenerated < max(tetsAvailable)
files = dir;
 CluFiles = ConcatentateIntoStructureIndices(files,'.','name',[],11);
CluFilesGenerated = sum(cell2mat( strfind(CluFiles , 'clu')) > 0);
%disp([ num2str(CluFilesGenerated) ' generated, wait for all clu files to be generated...' ]);
end
disp([ num2str(CluFilesGenerated) ' generated, proceed with moving to mother directory...' ]);



files = dir();
fileNames = ConcatentateIntoStructureIndices(files,'.','name',[],11) ;
CluFiles = files(find(~cellfun(@isempty,strfind(fileNames , 'clu')))); %% IT WAS files(find(~cellfun(@isempty,strfind(fileNames , 'clu'))));
 for iTetrode = 1:numel(CluFiles) ;
	ToDelete =(strfind(CluFiles(iTetrode).name,'_Concatenated')) ;       
    k =(strfind(CluFiles(iTetrode).name,'clu'));      
    
    NewNameFile = [CluFiles(iTetrode).name(1:ToDelete-1) '.' CluFiles(iTetrode).name(k:end)];
    NewPath = [Parameters.FilePath NewNameFile];
    %Create a new file with a different name...
          [status,message,messageId] = movefile(CluFiles(iTetrode).name,NewNameFile,'f');
          [status,message,messageId] = movefile(NewNameFile,Parameters.FilePath,'f');
          disp([NewNameFile ' created and moved into mother directory' ])
          
 end





end

