function OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits , Parameters )
MaxLength = 400 ;
figpath = 'Z:\giulioC\Data\VR\CueLockingExperiment';
cd(figpath)
Vars = daVarsStruct;
% MEC_Tetrode = 4 ;
% MEC_Cell = 22 ; 
% HPC_Tetrode = 16;
% HPC_Cell  = 2;
for iSession = 1  : numel(fields(VRs))
eval([ 'VR = VRs.Session_' num2str(iSession) ';'] );
clear Cue1 Cue2 Cue3; clear Ceiling  CeilingTiles CeilingPositions ;
if strcmp(VR.Virmen.vr.NameOfTheWorld,'B')  
WorldIndex= 2;
nCue = 1;
Cue1 = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.spottyceiling;
Cue1Tiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue1}.tiling(1) ;
Cue1Positions1 = sort( VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue1}.texture.shapes{2}.y)';


Cue2 = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.stripeyfloor;
Cue2Tiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue2}.tiling(1) ;
Cue2Positions1 = [0 .5];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';

elseif strcmp(VR.Virmen.vr.NameOfTheWorld,'C')
WorldIndex= 1;
nCue = 2;

Cue1 = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.stripeyfloor;
Cue1Tiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue1}.tiling(1) ;
Cue1Positions1 = [ 0 .5 ];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';



Cue2 = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.spottyceiling;
Cue2Tiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue2}.tiling(1) ;
Cue2Positions1 = [ 0.1 .25 ];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';

%Ceiling = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.spottyceiling;
%CeilingTiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Ceiling}.tiling(1) ;
%CeilingPositions = [.1 .25];% sort( VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Ceiling}.texture.shapes{2}.y)';
%Floor = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.stripeyfloor;
%FloorTiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Floor}.tiling(1) ;
%FloorPositions1 = [ 0 .5 ];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';
%FloorPositions2 = [ .5 1];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';
%clear FloorPositions2;       

elseif strcmp(VR.Virmen.vr.NameOfTheWorld,'A')
WorldIndex= 3;
nCue = 1;
%Ceiling = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.spottyceiling;
 %CeilingTiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Ceiling}.tiling(1) ;
 %CeilingPositions = [.1 .25];% sort( VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Ceiling}.texture.shapes{2}.y)';
Cue1 = VR.Virmen.vr.worlds{WorldIndex}.objects.indices.stripeysidewalls;
Cue1Tiles  = VR.Virmen.vr.exper.worlds{WorldIndex}.objects{Cue1}.tiling(2) ;
Cue1Positions1 = [ 0 .5 ];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';
% For Caswell application change widht...
Cue1Positions1 = [ 0.1 .25 ];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';

%FloorPositions2 = [ .5 1];%sort( VR.Virmen.vr.exper.worlds{BWorldIndex}.objects{Floor}.texture.shapes{4}.y)';
end        
        
TrackLength = 1000;
Period = TrackLength / Cue1Tiles ;
Units = [0:Period: TrackLength]' ;
[~,~,VR.pos.Unit ] = histcounts(VR.pos.xy_cm(:,1),Units) ; 
iTrial = 1;
TrialIndex = find(VR.pos.Trial == iTrial & VR.pos.Environment == WorldIndex);

%% Cue 1 ...
Cue1Period = TrackLength / Cue1Tiles ;
Cue1Start = [[(Cue1Positions1(1) * Cue1Period):Cue1Period :  TrackLength]]' ;
Cue1Start = Cue1Start(1:ceil(Cue1Tiles));
Cue1End = [(Cue1Positions1(2) * Cue1Period):Cue1Period :  TrackLength]'  ;
Cue1 = [Cue1Start Cue1End] ;


%% Cue 2 ...
if nCue ==2;
Cue2Period = TrackLength / Cue2Tiles ;
Cue2Start = [[(Cue2Positions1(1) * Cue2Period):Cue2Period :  TrackLength]]' ;
Cue2Start = Cue2Start(1:ceil(Cue2Tiles));
Cue2End = [(Cue2Positions1(2) * Cue2Period):Cue2Period :  TrackLength]'  ;
Cue2 = [Cue2Start Cue2End] ;   
end
% FloorCuePeriod = TrackLength / FloorTiles ;
% FloorCue1Start = [[(FloorPositions1(1) * FloorCuePeriod):FloorCuePeriod :  TrackLength]]';
% FloorCue1Start = FloorCue1Start(1:FloorTiles); 
% FloorCue1End =[(FloorPositions1(2) * FloorCuePeriod):FloorCuePeriod :  TrackLength]'  ;
% Floor1Cue = [FloorCue1Start FloorCue1End];
% if exist('FloorPositions2')
% FloorCue2Start = [[(FloorPositions2(1) * FloorCuePeriod):FloorCuePeriod :  TrackLength]]';FloorCue2Start = FloorCue2Start(1:FloorTiles); FloorCue2End =[(FloorPositions2(2) * Period):FloorCuePeriod :  TrackLength]'  ;
% Floor2Cue = [FloorCue2Start FloorCue2End];
% FloorCue2rea = zeros(length(VR.pos.xy_cm(TrialIndex)),1);
% InsideFloor2 = FindElementsWithMultipleBoundaries ( VR.pos.xy_cm(TrialIndex,1)  ,  Floor2Cue,'inside');
% end
Cue1Area = ones(length(VR.pos.xy_cm(TrialIndex)),1);
Cue2Area = ones(length(VR.pos.xy_cm(TrialIndex)),1);

   
InsideCue1 = FindElementsWithMultipleBoundaries ( VR.pos.xy_cm(TrialIndex,1)  ,  Cue1,'outside');
Cue1Area(InsideCue1) = 0 ;
if nCue > 1
InsideCue2 = FindElementsWithMultipleBoundaries ( VR.pos.xy_cm(TrialIndex,1)  ,  Cue2,'outside');
Cue2Area(InsideCue2) = 0 ;
end

% figure(iSession);
% subplot(2,1,1);
% if nCue > 1
% hCue2 = area(VR.pos.xy_cm(TrialIndex,1), Cue2Area) ;xlim([ 0 MaxLength]); set(hCue2,'FaceColor',[204 204 255]/255);
% end
%title(['Cue Period = ' (num2str(round(Cue1Period))) ' cm' ])
% hAreaCeiling = area(VR.pos.xy_cm(TrialIndex,1), CeilingCueArea) ;xlim([ 0 MaxLength]); set(hAreaCeiling,'FaceColor',[128 128 128]/255);
%set(gca,'XTick',round(sort(unique(Units))),'YTick',[]);xlabel ('Position (cm)');
figure(iSession);
subplot(2,1,1);
Tetrode = MEC_Tetrode;
Cell = MEC_Cell;
RateMap = RateMapForVR(VR,Tetrode,Cell,SmoothingFactor,Vars.rm.binSizePosCm ,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,0) ;
hMEC = area(RateMap.Pos(find(RateMap.Pos < MaxLength)),RateMap.map(find(RateMap.Pos < MaxLength)),'EdgeColor','k','FaceColor',[255 102 102]/255,'LineWidth',1);
hold on ;
hCue1 = area(VR.pos.xy_cm(TrialIndex,1), Cue1Area*max(get(gca,'YLim'))) ;
xlim([ 0 MaxLength]); set(hCue1,'FaceColor',[192 192 192]/255);
uistack(hCue1,'bottom');

xlabel ('Position (cm)');
ylabel('FR (Hz)');
set(gca,'XTick',round(sort(unique(Units))),'FontSize',20,'FontWeight','Bold' , 'LineWidth',4,'Layer','top');
title ('MEC','FontSize',40,'FontWeight','Bold' );


subplot(2,1,2);
Tetrode =HPC_Tetrode;
Cell = HPC_Cell;
RateMap = RateMapForVR(VR,Tetrode,Cell,SmoothingFactor,Vars.rm.binSizePosCm ,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,0) ;
if Tetrode > 8
hHPC = area(RateMap.Pos(find(RateMap.Pos < MaxLength)),RateMap.map(find(RateMap.Pos < MaxLength)),'EdgeColor','k','FaceColor',[204 255 255]/255,'LineWidth',1);
else
hHPC = area(RateMap.Pos(find(RateMap.Pos < MaxLength)),RateMap.map(find(RateMap.Pos < MaxLength)),'EdgeColor','k','FaceColor',[255 102 102]/255,'LineWidth',1);
end

set(gca,'XTick',round(sort(unique(Units))));xlabel ('Position (cm)');ylabel('FR (Hz)');title ('HPC');
hold on ;
hCue1 = area(VR.pos.xy_cm(TrialIndex,1), Cue1Area*max(get(gca,'YLim'))) ;
xlim([ 0 MaxLength]); set(hCue1,'FaceColor',[192 192 192]/255);


uistack(hCue1,'bottom');
xlabel ('Position (cm)');
ylabel('FR (Hz)');
set(gca,'XTick',round(sort(unique(Units))),'FontSize',20,'FontWeight','Bold' , 'LineWidth',4,'Layer','top');
if Tetrode > 8
    title ('HPC','FontSize',40,'FontWeight','Bold' );
else
title ('MEC','FontSize',40,'FontWeight','Bold' );
end

title_Cell = [ Parameters.Mouse '_' Parameters.Date '_MEC_T' num2str(MEC_Tetrode) '_C' num2str(MEC_Cell) '_HPC_T' num2str(HPC_Tetrode) '_C' num2str(HPC_Cell)  '_Session_' num2str(iSession) ];
set(gcf,'PaperOrientation','portrait','PaperUnits','normalized','PaperPosition', [0 0 1 1]);



saveas(gcf,title_Cell,'pdf');disp (['Figures from ' title_Cell ' properly saved and stored into correct directory']);clear title_Cell;
end

%% Data set used for making figures....
%% m3194_20180212
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 8;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 4;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 10;
%     HPC_Cell  = 1;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 3;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 4;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 7;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 5 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 16;
%     HPC_Cell  = 8;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);

%% m3193_20180223
%     MEC_Tetrode = 6 ;
%     MEC_Cell = 6 ; 
%     HPC_Tetrode = 2;
%     HPC_Cell  = 3;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
%     close all;
% 
%     MEC_Tetrode = 1 ;
%     MEC_Cell = 6 ; 
%     HPC_Tetrode = 3;
%     HPC_Cell  = 3;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 2 ;
%     MEC_Cell = 3 ; 
%     HPC_Tetrode = 3;
%     HPC_Cell  = 3;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 3 ;
%     MEC_Cell = 3 ; 
%     HPC_Tetrode = 7;
%     HPC_Cell  = 9;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 6 ;
%     MEC_Cell = 12 ; 
%     HPC_Tetrode = 7;
%     HPC_Cell  = 9;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 6 ;
%     MEC_Cell = 6 ; 
%     HPC_Tetrode = 7;
%     HPC_Cell  = 9;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);

%% m3193_20180226
% 
%     MEC_Tetrode = 1 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 6;
%     HPC_Cell  = 6;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 7 ;
%     MEC_Cell = 5 ; 
%     HPC_Tetrode = 2 ;
%     HPC_Cell  = 8 ;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 6 ;
%     MEC_Cell = 6 ; 
%     HPC_Tetrode = 2 ;
%     HPC_Cell  = 8 ;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 4 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 2 ;
%     HPC_Cell  = 8 ;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     close all;
%     subplot(1,2,1);
%     Tetrode = 4;Cell=1;
%     subplot(1,2,1);
%     in_UNsm_rm = make_in_struct_for_rm (OpenField,Tetrode,Cell,50,5,[Vars.rm.binSizePosCm],[Vars.rm.binSizeDir],0,'rate',0,0) ;in = in_UNsm_rm;OpenFieldRateMap = GetRateMap ( in); ProduceRM(flipud(OpenFieldRateMap.map'));
%     axis tight square;axis off;set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s'));
%     %text( max(FindExtremesOfArray([1:size(OpenFieldRateMap.map,1)])),min(FindExtremesOfArray([1:size(OpenFieldRateMap.map,2)])),['Mean rate = ' num2str( roundsd( nanmean(OpenFieldRateMap.map(:)),2) ) ' Hz']);
%     text( 0,- 2 ,[ num2str( roundsd( max(OpenFieldRateMap.map(:)),2) ) ' Hz'],'FontSize',20,'FontWeight','Bold');
% 
%     subplot(1,2,2);
%     Tetrode = 2;Cell=8;
%     in_UNsm_rm = make_in_struct_for_rm (OpenField,Tetrode,Cell,50,5,[Vars.rm.binSizePosCm],[Vars.rm.binSizeDir],0,'rate',0,0) ;in = in_UNsm_rm;OpenFieldRateMap = GetRateMap ( in); ProduceRM(flipud(OpenFieldRateMap.map'));
%     axis tight square;axis off;set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s'));
%     %text( max(FindExtremesOfArray([1:size(OpenFieldRateMap.map,1)])),min(FindExtremesOfArray([1:size(OpenFieldRateMap.map,2)])),['Mean rate = ' num2str( roundsd( nanmean(OpenFieldRateMap.map(:)),2) ) ' Hz']);
%     text( 0,- 2 ,[ num2str( roundsd( max(OpenFieldRateMap.map(:)),2) ) ' Hz'],'FontSize',20,'FontWeight','Bold');
% 
%     MEC_Tetrode = 1 ;
%     MEC_Cell = 7 ; 
%     HPC_Tetrode = 2 ;
%     HPC_Cell  = 8 ;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);
% 
%     MEC_Tetrode = 1 ;
%     MEC_Cell = 1 ; 
%     HPC_Tetrode = 2 ;
%     HPC_Cell  = 8 ;
%     close all;OutputDataForCaswellApplicatin(VRs,MEC_Tetrode , MEC_Cell ,  HPC_Tetrode , HPC_Cell , SmoothingFactor,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits ,Parameters);





end



