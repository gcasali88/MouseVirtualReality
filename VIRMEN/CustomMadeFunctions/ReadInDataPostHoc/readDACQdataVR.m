function mtint = readDACQdataVR ( filepath, flnmroot ,VRData)
% reads in all files associated with a single DACQ recording session and
% assembles into a structure called mtint.
% reads in all files associated with a single DACQ recording session and
% assembles into a structure called mtint.
cd(filepath)
% ---------------- add some metadata to the structure ----------------
mtint.flnmroot = flnmroot;
mtint.filepath = filepath;
mtint.header = getDACQHeader ( [filepath,flnmroot,'.set'], 'set' );

% ---------------- start read pos ---------------------
% find out how many leds were tracked and read pos file appropriately
idx1 = find(strcmpi('colactive_1',mtint.header(:,1)));
idx2 = find(strcmpi('colactive_2',mtint.header(:,1)));
led1 = str2double(char(mtint.header(idx1,2)));
led2 = str2double(char(mtint.header(idx2,2)));
if led1 & led2
    n_leds = 2;
elseif led1
    n_leds = 1;
end
    Vars  = daVarsStruct;
[led_pos,post,led_pix] = rawpos([filepath,flnmroot,'.pos'],n_leds); % raw led positions
% allocate to structure
mtint.Ephys.led_pos = led_pos;
mtint.Ephys.ts = post;
mtint.Ephys.led_pix = led_pix;
mtint.Ephys.trial_duration = length(led_pos) / Vars.pos.sampleRate ; 
% get header info
header = getDACQHeader ( [filepath,flnmroot,'.pos'], 'pos' );
mtint.Ephys.header = header;
    max_speed = 100; % in m/s
    box_car = Vars.pos.boxCar ;

mtint.Virmen = VRData;
%     mtint.vr.pos.speed=VRData.pos.speed;
%     mtint.vr.pos.ts = VRData.pos.ts ;
%     mtint.vr.pos.xy_cm = [VRData.pos.pos zeros(size(VRData.pos.pos))];
%     mtint.vr.pos.dir = [zeros(size(VRData.pos.pos))];
% 
% % ---------------- end read pos ---------------------

% list all the files that have the flnmroot
filelist = dir([filepath,flnmroot,'.*']);
% extract only the tetrode files from this list
% if unique(filepath == ['S:\Jeffery lab\Giulio Casali\PhD\Floor_Wall\r605_mEC\20140602\open_field\']) == 1 
%     filelist(7) = []
% end
    for ifile = 1:numel(filelist)
        type(ifile) = str2double(filelist(ifile).name(strfind(filelist(ifile).name,'.')+1:end));
    end
type(isnan(type)) = 0;
filelist = filelist(logical(type));
% ---------------- start read tetrodes ---------------------
% read tetrode files
available_tetrodes = zeros(1,numel(filelist));
for ifile = 1:numel(filelist)
    available_tetrodes (ifile) =  str2double(filelist(ifile).name(end));
end

max_available_tetrode = max(available_tetrodes);
theoretical_tetrodes = 1:max_available_tetrode;
missing_tetrode = setdiff(theoretical_tetrodes,available_tetrodes);

    for ifile = 1: max_available_tetrode
    current_tet = ifile;%str2double(filelist(ifile).name(strfind(filelist(ifile).name,'.')+1:end));
    if isfinite(current_tet)
       
        if  ~isempty(missing_tetrode) & current_tet ==  missing_tetrode
                header = getDACQHeader ( [filepath,flnmroot,'.',num2str(current_tet-1)], 'tet' );
                header{end,2} = '0';
                mtint.tetrode(ifile).id           = current_tet;  
                mtint.tetrode(current_tet).ch1    =  [];
                mtint.tetrode(current_tet).ch2    =  [];
                mtint.tetrode(current_tet).ch3    =  [];
                mtint.tetrode(current_tet).ch4    =  [];
              mtint.tetrode(ifile).pos_sample   =  [];
             mtint.tetrode(ifile).cut           =  [];
        
        else    
        header = getDACQHeader ( [filepath,flnmroot,'.',num2str(current_tet)], 'tet' );
        mtint.tetrode(ifile).id = current_tet;
        mtint.tetrode(ifile).header = header;
        [ts,ch1,ch2,ch3,ch4] = getspikes([filepath,flnmroot,'.',num2str(current_tet)]); % uncomment
%       this line and the 4 below to get the spikes on each channel
        mtint.tetrode(ifile).ts = ts;
        mtint.tetrode(current_tet).ch1 = ch1;
        mtint.tetrode(current_tet).ch2 = ch2;
        mtint.tetrode(current_tet).ch3 = ch3;
        mtint.tetrode(current_tet).ch4 = ch4;
        mtint.tetrode(ifile).pos_sample = ceil(ts * 50);
        mtint.tetrode(ifile).cut = [];
    
        end
        
        
        
        end
end
% ---------------- end read tetrodes ---------------------

% ---------------- start read cuts ---------------------
% read them in and assign to structure
for ifile = 1:numel(mtint.tetrode)
    current_tet = mtint.tetrode(ifile).id;
    if exist([filepath,flnmroot,'_',num2str(current_tet),'.cut'],'file')
        clust = getcut([filepath,flnmroot,'_',num2str(current_tet),'.cut']);
    else
        clust = [];
    end
    mtint.tetrode(ifile).cut = clust;
end
% ---------------- end read cuts ---------------------

% list all eeg files
eegfilelist = dir([filepath,flnmroot,'.eeg*']);

% ---------------- start read eeg ---------------------
% read them in and assign to structure
% for ifile = 1:numel(eegfilelist)
%     try
%         [EEG,Fs] = geteeg([filepath,eegfilelist(ifile).name]);
%     catch
%         EEG = NaN;
%         Fs = NaN;
%     end
%     mtint.EEG(ifile).EEG = EEG;
%     mtint.EEG(ifile).Fs = Fs;
%     % get eeg header info
%     try
%         header = getDACQHeader ( [filepath,eegfilelist(ifile).name], 'eeg' );
%     catch
%         header = NaN;
%     end
%     mtint.eeg(ifile).header = header;
% end
% --
[ systemV, maxEEGch ] = check_DACQ_version( mtint.header );
eegChUsed=zeros(maxEEGch,1);
for n=1:maxEEGch
    tmp=key_value(['saveEEG_ch_' num2str(n)], mtint.header, 'num', 'exact');
    if isempty(tmp) || ~tmp %Deal with situation where it's empty is not used
        eegChUsed(n)=0;
    else eegChUsed(n)=1;
    end
end
eegChUsed=find(eegChUsed==1);
loadList=intersect(eegChUsed, [1:numel(eegfilelist)]);
clear eeg_out;
for n = 1 : length(loadList) %Go through and load all eeg specified
if n==1
%eeg_out = struct('EEG',{1},'Fs',{1},'dummy',{});
%eeg_out(1).dummy = 1;
eeg_out = struct('EEG',{1},'Fs',{1});
%eeg_out(1).dummy = 1;
else
%[eeg_out]=[eeg_out; struct('EEG',{1},'Fs',{1},'dummy',{}) ] ;
%eeg_out(n).dummy = 1;    
[eeg_out]=[eeg_out; struct('EEG',{1},'Fs',{1}) ] ;
%eeg_out(n).dummy = 1;
end 
end


for n = 1 : numel(loadList) %Go through and load all eeg specified
    if n==1
    [EEG,Fs] = geteeg([filepath,mtint.flnmroot,'.eeg']);
                    eeg_out(n).EEG = [eeg_out(n).EEG;EEG];
                    eeg_out(n).Fs = [eeg_out(n).Fs;Fs];
            
          
             %eeg_out = rmfield(eeg_out(n),'dummy');            
    else
      
     EEGFORMAT= ['.eeg' num2str(n)];
     [EEG,Fs] = geteeg([filepath,mtint.flnmroot, EEGFORMAT ]);
             eeg_out(n).EEG = [eeg_out(n).EEG;EEG];
             eeg_out(n).Fs = [eeg_out(n).Fs;Fs];                                 
             %eeg_out = rmfield(eeg_out(n),'dummy');
        end
end   
 
%end
    mtint.EEG = eeg_out;

end
%--------------  read eeg ---------------------
%[ mtint ] = postprocess_DACQ_data( mtint );

