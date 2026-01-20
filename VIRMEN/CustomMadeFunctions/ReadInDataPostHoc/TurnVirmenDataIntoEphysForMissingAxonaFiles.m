function FixedVR = TurnVirmenDataIntoEphysForMissingAxonaFiles(VR, MissingSession)
Vars = daVarsStruct;
FixedVR = VR;
VRsSessions = fields(VR.Virmen);
eval(['VRSessionToAdd = VR.Virmen.' VRsSessions{MissingSession} '; ' ])
PosFields = fields(VR.pos) ;
PosFields = PosFields(~ismember(PosFields,{'header' ,'trial_duration' 'jumpyPercent'}));
LengthOfMissingSession = round(VRSessionToAdd.pos.ts(end)) ; %% In seconds.
PosSamplingRate = 50; %% Sampling rate (Hz);
if MissingSession
    LengthOfPresentSession = VR.pos.trial_duration(MissingSession-1 ) * PosSamplingRate ; 
else
    LengthOfPresentSession = 0 ;
end
NDataToAdd = LengthOfMissingSession*PosSamplingRate ;
FixedVR.Ephys.trial_duration(MissingSession) = LengthOfMissingSession;
FixedVR.pos.trial_duration(MissingSession) = LengthOfMissingSession;

FixedVR.flnmroot{MissingSession+1} =  VRsSessions{MissingSession} ;


for iField = 1 : numel(PosFields)
eval(['FixedVR.Ephys.' PosFields{iField}  '([LengthOfPresentSession+1:LengthOfPresentSession+NDataToAdd],1:size(FixedVR.Ephys.' PosFields{iField}  ',2)) = NaN(NDataToAdd,size(FixedVR.Ephys.' PosFields{iField}  ',2)) ; ' ] );
end
    FixedVR.Ephys.ts(LengthOfPresentSession+1:LengthOfPresentSession+NDataToAdd,1) = FixedVR.Ephys.ts(LengthOfPresentSession,1) + linspace(1/Vars.pos.sampleRate,FixedVR.Ephys.trial_duration(MissingSession), NDataToAdd);


end