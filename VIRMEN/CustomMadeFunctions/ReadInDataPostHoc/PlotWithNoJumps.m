function Data = PlotWithNoJumps (Data,max_speed,Color,LineWidth,PLOT)
Data.pos.dir = reshape(Data.pos.dir,[],1);
MaxSpeedIndices = find(Data.pos.speed>max_speed) ;%Data.pos.speed(MaxSpeedIndices) = NaN; 
FieldsToNaN =fields(Data.pos);
for iField = 1 : numel (FieldsToNaN)
if ~strcmp(FieldsToNaN{iField}, 'SurfPos')
    eval([' if length(Data.pos.' FieldsToNaN{iField} ') == length(Data.pos.speed);Data.pos.' FieldsToNaN{iField} '(MaxSpeedIndices,:,:) = NaN;end;  ' ]);
end
end;
for iTetrode = 1 : numel(Data.tetrode)
Data.tetrode(iTetrode).cut(find(ismember(Data.tetrode(iTetrode).pos_sample,[MaxSpeedIndices])))=0; % Removes spikes from cell and put them to 0...
end
if PLOT==1
if isempty(MaxSpeedIndices)
AllGoods =[1 length(Data.pos.speed)];     
    
else    
    FirstStop =  [MaxSpeedIndices(1)-1 ];
AllGoods=[1 FirstStop];
Jumps = find ( diff(MaxSpeedIndices)  >  1  )   ;
for iJump = 1 : numel(Jumps)
GoodOne = MaxSpeedIndices(Jumps(iJump))  +1;
Last  = MaxSpeedIndices(Jumps(iJump)+1)-1;
AllGoods=[AllGoods;GoodOne Last];
end
end

for iGood = 1 : size(AllGoods,1)
hold on ;
t=plot(Data.pos.xy_cm(AllGoods(iGood,1):  AllGoods(iGood,2),1),Data.pos.xy_cm(AllGoods(iGood,1):  AllGoods(iGood,2),2));
set(t,'Color',Color,'LineWidth',LineWidth);
hold off;
end
end

end

% AdditionalJoints = MaxSpeedIndices(find ( diff(MaxSpeedIndices)  >1) + 1)
% Pegboard.pos.speed(AdditionalJoints-10:AdditionalJoints+10)
% diff(find(   Pegboard.pos.speed>100  )   )
% 
% 
% find(diff(find(Pegboard.pos.speed>100)) >1)