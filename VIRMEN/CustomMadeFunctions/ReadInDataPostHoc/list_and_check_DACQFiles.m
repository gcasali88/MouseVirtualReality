function [fileStruct,tetsAvailable] = list_and_check_DACQFiles ( varargin )
% when a user wants to load multiple files this fcn checks for the
% presence/ absence of tetrode, pos files etc and re-orders files based on
% the combined cut file so the order of files loaded is the same as they
% were cut in Tint
if nargin == 0
    [files,filepath] = uigetfile('*.set','Select the .set file...',...
        'MultiSelect','on');
    files = cellstr(files);
elseif nargin == 2
    filepath = varargin{1};
    files = varargin{2};
end
if ~strcmp(filepath(end),filesep)
    filepath(end+1) = filesep;
end
% create a structure to hold the names of files etc
fileStruct = struct('flnmroot',{},'posFilePresent',{},'tetrodeFiles',{},'eegFiles',{});

for ifile = 1:numel(files)
    % check all pos files are present
    fileStruct(ifile).flnmroot = files{ifile}(1:strfind(files{ifile},'.') -1 ) ;
    if isempty(dir([filepath,fileStruct(ifile).flnmroot,'.pos']))
        error('filePresenceCheck:posFile',[fileStruct(ifile).flnmroot, '.pos is missing so exiting']);
    else
        fileStruct(ifile).posFilePresent = 1;
    end
    % check for tetrode files
    tet_filelist = dir([filepath,fileStruct(ifile).flnmroot,'.*']);
    f_type = zeros(numel(files),numel(tet_filelist));
    for i = 1:numel(tet_filelist)
        f_type(i) = str2double(tet_filelist(i).name(strfind(tet_filelist(i).name,'.')+1:end));
    end
    f_type(isnan(f_type) | (f_type == 0)) = [];
    fileStruct(ifile).tetrodeFiles = f_type;
    % check for eeg files
    if isempty(dir([filepath,fileStruct(ifile).flnmroot,'.eeg*']))
        warning('filePresenceCheck:eegFile',[fileStruct(ifile).flnmroot, '.eeg is missing'])
    else
        fileStruct(ifile).eegFiles = 1;
    end   
end
% this final check asks the user to select a cut file that corresponds to
% the combined cut file for all the trials, it then reads that file and
% re-orders the fileStruct so that the list of files passed back is
% correctly ordered so that the files are loaded in the same order they
% were cut in Tint
% if numel(fileStruct) > 1
%     [cut_file,filepath] = uigetfile('*.cut','Select the COMBINED .cut file...','MultiSelect','off');
%     [~,exact_text] = getcut([filepath,cut_file]);
%     idx = strfind(exact_text,': '); % should contain two values
%     flist = textscan(exact_text(idx(1)+2:idx(2)-8),'%s','delimiter',',');
%     fileStruct = sortstruct(fileStruct,'flnmroot',flist{1});
% end
% check what tetrode files are present across trials
tetsAvailable = fileStruct(1).tetrodeFiles;
for ifile = 2:numel(fileStruct)
    tetsAvailable = intersect(tetsAvailable,fileStruct(ifile).tetrodeFiles);
end

