function [ vr ] = TransportToStart( vr )
%Detects when mouse is at end of track and then transports back to start

if vr.position(2) >= vr.trackLength 
    vr.position(2) = 0;
end

end

