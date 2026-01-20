function LickMap = ProduceMapOfLicking(VR,Boundaries,varargin)
if numel(varargin)==0;
    FlagFigure=1;
    FieldToPlot = 'GaussMap';
elseif numel(varargin)==1;
    FlagFigure=varargin{1};
    FieldToPlot = 'GaussMap';;
elseif numel(varargin)==2;
    FlagFigure=varargin{1};
    FieldToPlot=varargin{2};  
end

VR.pos.xy_cm(FindElementsWithMultipleBoundaries( VR.pos.xy_cm(:,1) , Boundaries,'outside'),:) = NaN ;


Vars= daVarsStruct;
in = make_in_struct_for_rm (VR,1,1,Vars.pos.sampleRate,Vars.rm.smthKernPos,Vars.rm.binSizePosCm,Vars.rm.binSizeDir ,1,'rate',0,0);

%VR.Virmen.Licking.PhotoLicking.pos


LickIndices = [find(diff((VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold ))>0)]+1 ;
in.spikePosInd= LickIndices; 
in.PLOT_ON=0;

in.maxPos =  [max(Boundaries) max(VR.pos.xy_cm(:,2))];
in.minPos = [min(Boundaries)  min(VR.pos.xy_cm(:,2))];

if isnan(in.maxPos(2)) ; in.maxPos(2) =  1 ;end;
if isnan(in.minPos(2)) ; in.minPos(2) =  0 ;end;

LickMap = GetRateMap ( in);
LICKMAPFIELDS = fields(LickMap);
LICKMAPFIELDS = LICKMAPFIELDS(find(~ismember(LICKMAPFIELDS,{'binsize','Smoothing','SIGMA','SIZE','maxPos','minPos','WithinTrialCorrelation'}))) ;
for iField = 1 : numel(LICKMAPFIELDS)
eval(['LickMap.' LICKMAPFIELDS{iField} '= transpose(LickMap.' LICKMAPFIELDS{iField} '); ' ]);
end; clear LICKMAPFIELDS iField; 

if FlagFigure   
eval(['imagesc(LickMap.' FieldToPlot ');' ]);
%xlabel('pos');
set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s')');
set(gca,'YTick',[]);
colormap('jet');
end

end



%BinSpeedOscillation     = intrinsic_freq_autoCorr(in);
