function [ vr ] = SetWindowsSetup( vr )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if vr.Setup ==1;

    
vr.exper.windows{1}.transformation =2;
vr.exper.windows{1}.monitor = 2;
vr.exper.windows{2}.transformation =3;
vr.exper.windows{2}.monitor = 3;
vr.exper.windows{3}.transformation =4;
vr.exper.windows{3}.monitor = 4;
vr.exper.windows{4}.transformation = 1;
vr.exper.windows{4}.monitor = 6;
vr.exper.windows{5}.transformation =1;
vr.exper.windows{5}.monitor  = 5;

elseif vr.Setup ==2;
    
vr.exper.windows{1}.transformation =2;
vr.exper.windows{1}.monitor = 4; %% it was 2 

vr.exper.windows{2}.transformation =3;
vr.exper.windows{2}.monitor = 2; %% it was 4

vr.exper.windows{3}.transformation =4;
vr.exper.windows{3}.monitor = 3;%% it was 5

vr.exper.windows{4}.transformation =1;
vr.exper.windows{4}.monitor = 6; %% it was  6

vr.exper.windows{5}.transformation =1;
vr.exper.windows{5}.monitor = 5; %% it was 3

% vr.exper.windows{3}.monitor = 3;
% vr.exper.windows{4}.monitor = 4;
% vr.exper.windows{5}.monitor = 1;
% vr.exper.windows{6}.monitor = 1;

end

end

