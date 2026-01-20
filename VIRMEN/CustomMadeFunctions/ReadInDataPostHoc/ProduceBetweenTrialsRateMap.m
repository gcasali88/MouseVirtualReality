function ret =  ProduceBetweenTrialsRateMap(VR,Tetrode,Cell)
    Vars = daVarsStruct;
    NumOfTrials = max(VR.pos.Trial) ; 
    VR_Mobile = VR ; 
    VR_Mobile.pos.xy_cm(   find(VR_Mobile.pos.speed < Vars.pos.minSpeed),:) = NaN;
  
    GreatRateMap = [];
    
for iTrial = 1 : max(VR.pos.Trial) ;
    
    tmpTrial = VR_Mobile;
    TmpToDelete = find(VR.pos.Trial ~= iTrial) ; 
    %tmpTrial.pos.xy_cm(:,2) = 1 ; 
    tmpTrial.pos.xy_cm(TmpToDelete,:) = NaN ; 
        
    in_UNsm_rm = make_in_struct_for_rm (tmpTrial,Tetrode,Cell,50,5,[Vars.rm.binSizePosCm],[Vars.rm.binSizeDir],0,'rate',0,0) ; 
    
    in = in_UNsm_rm;RateMap = GetRateMap ( in); 
    if size(RateMap.map',2) == size(GreatRateMap,2) & iTrial>1
    GreatRateMap = [GreatRateMap; RateMap.map'];
    elseif iTrial == 1;
    GreatRateMap = [GreatRateMap; RateMap.map'];
    end
end
    clear in ;
    in.bins = [1:size(GreatRateMap,2)] ; 
    in.meanFreqPerBin = nanmean(GreatRateMap,1) ; 
    in.semFreqPerBin = StError(GreatRateMap,1) ; 
    in.linecolor = [1 0 0 ] ;
    ret = XYSemArea(in) ; 
    
    
    
    axis tight square;
    set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s')')
    xlabel('pos (cm)'); ylabel('FR (Hz)');
    %ylim([0 max(RateMap.map)]);
    title([ 'VR Rate map' ]);
    YTicks = [  ceil(max(in.meanFreqPerBin + in.semFreqPerBin))  ] ;if YTicks == 0;YTicks = 1; end;
    %if YTicks < 1
    %set(gca,'YTick',[1],'YLim',[0 1])   
    %else
    set(gca,'YTick',[0 YTicks],'YLim',[0 YTicks])
    
    
    
    
    
    
%     plot(RateMap.map,SpikeColor,'LineWidth',2);
%     axis tight square;
%     set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s')')
%     xlabel('pos (cm)'); ylabel('FR (Hz)');
%     %ylim([0 max(RateMap.map)]);
%     title([ 'VR Rate map' ]);
%     YTicks = [  (ceil(max(RateMap.map)))+1   ] ;
%     %if YTicks < 1
%     %set(gca,'YTick',[1],'YLim',[0 1])   
%     %else
%     set(gca,'YTick',[YTicks],'YLim',[0 YTicks])
    %end


end
