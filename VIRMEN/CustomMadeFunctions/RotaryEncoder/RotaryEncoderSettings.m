function [ vr ] = RotaryEncoderSettings( vr )
%%  Sets rotary encoder 

vr.RotaryEncoder.daqSessRotEnc = daq.createSession('ni'); % opens the session...
vr.RotaryEncoder.counterCh = vr.RotaryEncoder.daqSessRotEnc.addCounterInputChannel(['Dev' num2str(vr.NIDev)], 'ctr0', 'Position');
vr.RotaryEncoder.counterCh.EncoderType = 'X4';%it was X4 from TW...
if ~isfield(vr,'GainManipulation')
    vr.GainManipulation = [];
end
if ~isfield(vr.GainManipulation,'Value');
    %% it was = vr.GainManipulation.Value=exp(1);
    % but on 09/12/2019 changed into...
        vr.GainManipulation.Value=(1)  ;
    
end

end

