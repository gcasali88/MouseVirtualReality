function RecoverUnSavedVRMatlabData


selpath = uigetdir;
cd(selpath)
vr = uigetfile;

load vr
    
OutputDataFromVirmen(vr)






% else
%  disp(['vr.mat missing, impossible to recover data...']);   
% end
end