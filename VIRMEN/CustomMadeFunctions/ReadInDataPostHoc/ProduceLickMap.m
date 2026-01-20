function [VR,LickMap] = ProduceLickMap(VR,LickColor,Vars,WorldWithRewardArea,Boundaries,RewardedArea,ForEachCompartmentVisits) ; 




Vars = daVarsStruct;
%% Lick map average results...
LickMap.VR = ProduceMapOfLicking(VR,Boundaries,0,'map') ; 
LickMap.VR.AcrossTrials = [];
%% Trial by trial results...
FieldsToKeep =     {'GaussSpike' 'GaussDwell' 'GaussMap' 'UnSmoothedSpike' 'UnSmoothedDwell' 'UnSmoothedMap' } ;
FieldsTBeCalled = {'GaussLick' 'GaussDwell' 'GaussLickMap' 'UnSmoothedLick' 'UnSmoothedDwell' 'UnSmoothedLickMap' } ;
       for iTrial = transpose(unique(VR.pos.Trial))
            TrialVR = VR;
            TrialVR.pos.xy_cm(TrialVR.pos.Trial ~= iTrial,:) = NaN ;
            TrialMap = ProduceMapOfLicking(TrialVR,Boundaries,0,'map') ; 
                for iFieldToKeep = 1  : numel(FieldsToKeep);
                    eval(['LickMap.VR.AcrossTrials.' FieldsTBeCalled{iFieldToKeep } '(iTrial,:) = TrialMap.' FieldsToKeep{iFieldToKeep } '  ; ' ])
                end;
            clear TrialMap TrialVR iFieldToKeep iTrial; 
       end ;
       
clear FieldsTBeCalled;
  
TemporalBoundaries(:,1) = [1 ; find(diff( VR.pos.Trial )== 1)+1];
TemporalBoundaries(:,2) = [ find(diff( VR.pos.Trial )== 1); numel(VR.pos.Trial)] ;
LickMap.TemporalBoundariesTs = VR.pos.ts(TemporalBoundaries) ;

%% Lick Ts
LickIndices = [find(diff((VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold ))>0)]+1 ;

LickMap.Lick.Ts = VR.pos.ts(LickIndices) ;
LickMap.Lick.Pos = VR.pos.xy_cm(LickIndices,1) ;
[~,LickMap.Lick.Trial] = FindElementsWithMultipleBoundaries(LickMap.Lick.Ts, reshape(LickMap.TemporalBoundariesTs,[],2) , 'inside') ;


%% Reward Ts...

LickMap.Reward.Ts = VR.Virmen.Reward.ts ;
LickMap.Reward.Pos = VR.Virmen.Reward.pos ;
[~,LickMap.Reward.Trial] = FindElementsWithMultipleBoundaries(LickMap.Reward.Ts, reshape(LickMap.TemporalBoundariesTs,[],2) , 'inside') ;




%% Speed map average results...              
SpeedMap = ProduceSpeedPlot( VR , Boundaries) ;
FieldsToKeep =     {'MeanSpeed' 'SmoothedMeanSpeeed' } ;
       for iTrial = transpose(unique(VR.pos.Trial))
            TrialVR = VR;
            TrialVR.pos.speed(TrialVR.pos.Trial ~= iTrial,:) = NaN ;    
            TrialSpeedMap = ProduceSpeedPlot( TrialVR , Boundaries) ;
                for iFieldToKeep = 1  : numel(FieldsToKeep);
                    eval(['SpeedMap.' FieldsToKeep{iFieldToKeep} 'AcrossTrials(iTrial,:) = TrialSpeedMap.' FieldsToKeep{iFieldToKeep } '  ; ' ])
                end;
            clear TrialSpeedMap iTrial iFieldToKeep ; 
        end      
clear FieldsToKeep;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PosExtrema = round(FindExtremesOfArray(Boundaries)) ;
PosToRm = ([PosExtrema(1):Vars.rm.binSizePosCm:PosExtrema(2)])+Vars.rm.binSizePosCm/2 ;
PosToRm(PosToRm > PosExtrema(2))=[];
LickMap.VR.Pos = PosToRm;

P =plot([PosToRm], LickMap.VR.GaussMap(1:numel(PosToRm)),'Color',LickColor,'LineWidth',2);
xlabel('pos (cm)'); ylabel('Lick (Hz)');
hold on ;
ylim([0,5])
%%
for iVisit = 1 : numel(ForEachCompartmentVisits)
    eval(['LickMap.VR.Compartments.' ForEachCompartmentVisits{iVisit} '= LickMap.VR.GaussMap ( FindElementsWithMultipleBoundaries(LickMap.VR.Pos, Boundaries(iVisit,:),' char(39) 'inside' char(39) ') )  ;' ])
end


%%
for iEnvironment = 1 : VR.Virmen.vr.NumberOfTimesRewardEnvironmentPresented                                    
    for iReward = 1 : VR.Virmen.vr.NumberOfCues 
        hArea = area(RewardedArea(iReward,:,iEnvironment),[ max(get(gca,'YLim')) max(get(gca,'YLim'))]) ;
        set(hArea,'FaceColor',Vars.SpeedModulation.FloorShadeColor,'EdgeColor',Vars.SpeedModulation.FloorShadeColor);
        uistack(hArea,'bottom' );
    end
end;


yyaxis right;
plot(SpeedMap.PosBin,SpeedMap.SmoothedMeanSpeeed,'r','LineWidth',2);
ylabel('Speed (cm/s)');
set(gca,'YColor',[1 0 0 ]);
ylim([0,40]);
yyaxis left; ;;
title([ 'Lick rate / speed map' ]);

hold on ;   
Rewards = VR.Virmen.Reward.pos ;
%for iArea = 1 : size(Boundaries,1)  
for iEnvironment = 1 : VR.Virmen.vr.NumberOfTimesRewardEnvironmentPresented  ;                                  
for iReward = 1 : VR.Virmen.vr.NumberOfCues; 
  
if sum(isnan(Rewards)) == numel(Rewards)  ;
   Rewards = []; 
end
  
[InsideArea] = FindElementsWithMultipleBoundaries(Rewards,RewardedArea(iReward,:,iEnvironment),'inside');
 if ~isempty( InsideArea)  
    hReward = area( [nanmean(Rewards(InsideArea))-StError(Rewards(InsideArea))  nanmean(Rewards(InsideArea))+StError(Rewards(InsideArea)) ] ,[ max(get(gca,'YLim')) max(get(gca,'YLim'))]); 
    set(hReward,'FaceColor',Vars.SpeedModulation.FloorShadeColor,'EdgeColor',Vars.SpeedModulation.FloorColor);
 end
 
 %l=line([nanmean(VR.Virmen.Reward.pos(InsideArea)) nanmean(VR.Virmen.Reward.pos(InsideArea))]/,[ 0 max(get(gca,'YLim'))],'Color','r','LineWidth',2);
end 
end
%  
%  %% Draw lines ...  
% clear Boundaries;
% Boundaries=VR.pos.xy_cm( (find(diff(VR.pos.Environment)~=0)+1),1);
% Boundaries = unique(round(Boundaries/10)*10);
% 
% 
for iBound = 1: numel(Boundaries)
 hold on;
line([Boundaries(iBound) Boundaries(iBound)],[FindExtremesOfArray(get(gca,'YLim'))],...
    'Color','k','LineStyle','--');
end

set(gca,'XLim',[Boundaries],    'XTick',[EqualBinning( Boundaries , range(Boundaries)/5 )] );    

%% Draw lines signaling for different environments...

% clear Boundaries;
% Boundaries=VR.pos.xy_cm( (find(diff(VR.pos.Environment)~=0)+1),1);
% Boundaries = unique(round(Boundaries/10)*10);


% for iBound = 1: numel(Boundaries)
%  hold on;
% 
%  
% line([Boundaries(iBound) Boundaries(iBound)],[FindExtremesOfArray(VR.pos.ts)],...
%     'Color','k','LineStyle','--');
%  
%  
% %  
% % line([round( min(Data.pos.pos(Data.pos.Environment==iWorld))) round( min(Data.pos.pos(Data.pos.Environment==iWorld)))],[min(Data.pos.ts) max(Data.pos.ts)],...
% %     'Color','k','LineStyle','--');
% % line([round( max(Data.pos.pos(Data.pos.Environment==iWorld))) round( max(Data.pos.pos(Data.pos.Environment==iWorld)))],[min(Data.pos.ts) max(Data.pos.ts)],...
% %     'Color','k','LineStyle','--');
% 
% %round(max(Data.pos.pos(Data.pos.Environment==iWorld)))
% end
% 
% set(gca,'XTick',round([min(VR.pos.xy_cm(:,1)) : Vars.VR.Display.XTickForSpikePlot : max(VR.pos.xy_cm(:,1)) ]),'YTick',round([min(VR.pos.ts(:,1)) : Vars.VR.Display.YTickForSpikePlot : max(VR.pos.ts(:,1)) ]));
%
if isfield(VR.Virmen,'TaskSolved')
    SpeedMap.CorrectTrials = VR.Virmen.vr.TaskSolved(1: VR.Virmen.vr.TrialSettings.iTrial);
end
LickMap.SpeedMap = SpeedMap ;

end
