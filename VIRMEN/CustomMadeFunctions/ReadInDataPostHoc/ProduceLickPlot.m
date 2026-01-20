function VR = ProduceLickPlot(VR,TrackColor,OutsideLickColor,InsideLickColor,RewardColor,WorldWithRewardArea,Boundaries,RewardedArea) ; 
Vars = daVarsStruct;
RewardedArea = reshape(RewardedArea,[],[2]);
hold on ;   
if ~isfield(VR.Virmen.vr,'NumberOfTimesRewardEnvironmentPresented')
    if strcmp(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.name,'TrainingWorld')
     VR.Virmen.vr.NumberOfTimesRewardEnvironmentPresented   = 1;
    end
end
if ~isfield(VR.Virmen.vr,'NumberOfCues')
    if strcmp(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.name,'TrainingWorld')
     VR.Virmen.vr.NumberOfCues   = 1;
    end
end    
for iEnvironment = 1 : VR.Virmen.vr.NumberOfTimesRewardEnvironmentPresented                                    
for iReward = 1 : VR.Virmen.vr.NumberOfCues 
%% Plotted vs Time..
    %hArea = area(RewardedArea(iReward,:,iEnvironment),[ max(VR.pos.ts) max(VR.pos.ts)]) ;
    hArea = area(RewardedArea(iReward,:,iEnvironment),[ max(VR.pos.Trial) max(VR.pos.Trial)]) ;
    set(hArea,'FaceColor',Vars.SpeedModulation.FloorShadeColor,'EdgeColor',Vars.SpeedModulation.FloorShadeColor);
    uistack(hArea,'bottom' );
end
end;


hold on ;

%% Plotted vs Time..
%plot(VR.pos.xy_cm(:,1),VR.pos.ts,'Color',TrackColor);%,'Marker','.');
%% Plotted vs Trial
plot(VR.pos.xy_cm(:,1),VR.pos.Trial, '.' , 'Color',TrackColor ) ;

axis tight; hold on ; 
OutsideArea = [];
InsideArea = [];
for iEnvironment = 1 : VR.Virmen.vr.NumberOfTimesRewardEnvironmentPresented  ;                                  
for iReward = 1 : VR.Virmen.vr.NumberOfCues; 

[OutsideArea] =[OutsideArea; FindElementsWithMultipleBoundaries(VR.pos.xy_cm(:,1),RewardedArea(iReward,:,iEnvironment),'outside')];% it was Boundaries but needs being the rewarded area...
[InsideArea] = [InsideArea;FindElementsWithMultipleBoundaries(VR.pos.xy_cm(:,1),RewardedArea(iReward,:,iEnvironment),'inside')];
end
end

if max(VR.Licking.Voltage) > 9
Licks = find(VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold);
else
Licks = find(VR.Licking.Voltage > VR.Virmen.vr.PhotoLickDetection.VoltageThreshold);
end
    
OutsideLicks = intersect(Licks,OutsideArea) ;
InsideLicks =intersect(Licks,InsideArea) ; 
%% Plotted vs Time..
% plot(VR.pos.xy_cm(OutsideLicks,1),VR.pos.ts(OutsideLicks),'.' ,'Color',OutsideLickColor);
% plot(VR.pos.xy_cm(InsideLicks,1),VR.pos.ts(InsideLicks),'.' ,'Color',InsideLickColor);
%% while plotted agains Trials
plot(VR.pos.xy_cm(OutsideLicks,1),VR.pos.Trial(OutsideLicks),'.' ,'Color',OutsideLickColor);
plot(VR.pos.xy_cm(InsideLicks,1),VR.pos.Trial(InsideLicks),'.' ,'Color',InsideLickColor);


%% Plotted agains Time is...
%Rewards = plot(VR.Virmen.Reward.pos,VR.Virmen.Reward.ts,'.' ,'Color',RewardColor);
%% while plotted agains Trials
plot(VR.pos.xy_cm(knnsearch(VR.pos.ts,VR.Virmen.Reward.ts),1)  , VR.pos.Trial(knnsearch(VR.pos.ts,VR.Virmen.Reward.ts)) ,'.' ,'Color',RewardColor);

% if sum(~isnan(VR.Virmen.Reward.pos))==1;
% Rewards = plot(VR.Virmen.Reward.pos,...
%           [FindElementsWithMultipleBoundaries(VR.Virmen.Reward.ts, [ [1  ; find(diff(VR.pos.Trial))+1 ] , [ find(diff(VR.pos.Trial)) ;  numel(VR.pos.Trial) ] ],'inside')] ,'.' ,'Color',RewardColor);
% end;
title('Lick plot');axis ; hold off;xlabel('pos (cm)');ylabel('Trial #');
set(gca,'XLim',[Boundaries],    'XTick',[EqualBinning( Boundaries , range(Boundaries)/5 )] );    
ylim([0 max(VR.pos.Trial)+1]);
       
end

