function s = MartlabOscilloscope(varargin)
if nargin==1;
InputChannel = varargin{1};
YLim = 12;
elseif nargin==2;
InputChannel = varargin{1};
YLim = varargin{2};
end;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2',['ai' num2str(InputChannel)],'Voltage');
lh = addlistener(s,'DataAvailable',@plotData); 
s.IsContinuous=1;
startBackground(s)
end

%stop(s)

 