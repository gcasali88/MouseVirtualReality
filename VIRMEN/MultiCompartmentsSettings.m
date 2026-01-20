Compartments = struct;

%% Settings for the floor...
Compartments.Shared.Floor.width = 600;
Compartments.Shared.Floor.height = 300;
Compartments.Shared.Floor.elevation = -20;
Compartments.Shared.Floor.rotation = 0;
Compartments.Shared.Floor.Locations.X = 0;
Compartments.Shared.Floor.Locations.Y = 175;
Compartments.Shared.Floor.Tiling.Vertical = 15;
Compartments.Shared.Floor.Tiling.Horizontal= 15;
Compartments.Shared.Floor.EdgeRadius= NaN;
%% Settings for the ceiling...
Compartments.Shared.Ceiling.width = 600;
Compartments.Shared.Ceiling.height = 300;
Compartments.Shared.Ceiling.elevation = 100;
Compartments.Shared.Ceiling.rotation = 0;
Compartments.Shared.Ceiling.Locations.X = 0;
Compartments.Shared.Ceiling.Locations.Y = 200;
Compartments.Shared.Ceiling.Tiling.Vertical = 1;
Compartments.Shared.Ceiling.Tiling.Horizontal= 1;
Compartments.Shared.Ceiling.EdgeRadius= NaN;
%% Settings for the side walls...
Compartments.Shared.SideWalls.bottom = Compartments.Shared.Floor.elevation;
Compartments.Shared.SideWalls.top = 100;
Compartments.Shared.SideWalls.Left.Locations.First.X = -300;
Compartments.Shared.SideWalls.Left.Locations.First.Y = 0;
Compartments.Shared.SideWalls.Left.Locations.Second.X = -300;
Compartments.Shared.SideWalls.Left.Locations.Second.Y = 350;
Compartments.Shared.SideWalls.Right.Locations.First.X = 300;
Compartments.Shared.SideWalls.Right.Locations.First.Y = 0;
Compartments.Shared.SideWalls.Right.Locations.Second.X = 300;
Compartments.Shared.SideWalls.Right.Locations.Second.Y = 350;
%% Settings for the frontal wall...
Compartments.Shared.FrontalWall.bottom = -20;
Compartments.Shared.FrontalWall.bottom = 100;
Compartments.Shared.FrontalWall.Locations.First.X = -300;
Compartments.Shared.FrontalWall.Locations.First.Y = 350;
Compartments.Shared.FrontalWall.Locations.Second.X = 300;
Compartments.Shared.FrontalWall.Locations.Second.Y = 350;

%% Settings for the end of the pipe...
Compartments.Shared.EndPipe.Pipe.Tiling.Vertical= 3;
Compartments.Shared.EndPipe.Pipe.Tiling.Horizontal= 30;
Compartments.Shared.EndPipe.Pipe.EdgeRadius= NaN;
Compartments.Shared.EndPipe.Pipe.radius= 15;
Compartments.Shared.EndPipe.Pipe.elevation1= 0;
Compartments.Shared.EndPipe.Pipe.elevation2= 0;
Compartments.Shared.EndPipe.Pipe.Locations.First.X = 0;
Compartments.Shared.EndPipe.Pipe.Locations.First.Y = 300;
Compartments.Shared.EndPipe.Pipe.Locations.Second.X = 0;
Compartments.Shared.EndPipe.Pipe.Locations.Second.Y = 350;
%       pipe texture....
Compartments.Shared.EndPipe.Pipe.Texture.Shape.Locations.First.X = 0.2  ;
Compartments.Shared.EndPipe.Pipe.Texture.Shape.Locations.First.Y = 0.2  ;
Compartments.Shared.EndPipe.Pipe.Texture.Shape.Locations.Second.X = 0.8  ;
Compartments.Shared.EndPipe.Pipe.Texture.Shape.Locations.Second.Y = 0.8  ;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.R = 0.8;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.G = 0.8;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.B = 0.8;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.Alpha = NaN;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.Locations.First.X = 0.1;
Compartments.Shared.EndPipe.Pipe.Texture.OutsideShape.Locations.First.Y = 0.5;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.R = 0.31373;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.G = 0.31373;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.B = 0.31373;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.Alpha = NaN;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.Locations.First.X = 0.5;
Compartments.Shared.EndPipe.Pipe.Texture.InsideShape.Locations.First.Y = 0.5;
%% Settings for the wall at the end of the pipe...
Compartments.Shared.EndPipe.Wall.Tiling.Vertical= 1;
Compartments.Shared.EndPipe.Wall.Tiling.Horizontal= 1;
Compartments.Shared.EndPipe.Wall.EdgeRadius= NaN;
Compartments.Shared.EndPipe.Wall.bottom = -15;
Compartments.Shared.EndPipe.Wall.top = 15;
Compartments.Shared.EndPipe.Wall.Locations.First.X = -15;
Compartments.Shared.EndPipe.Wall.Locations.First.Y = 340;
Compartments.Shared.EndPipe.Wall.Locations.Second.X = 15;
Compartments.Shared.EndPipe.Wall.Locations.Second.Y = 340;
%       wall texture....
Compartments.Shared.EndPipe.Wall.Texture.CircularShape.points = 100;
Compartments.Shared.EndPipe.Wall.Texture.CircularShape.radius = .5;
Compartments.Shared.EndPipe.Wall.Texture.CircularShape.rotation = 0;
Compartments.Shared.EndPipe.Wall.Texture.CircularShape.Locations.First.X = 0.5;
Compartments.Shared.EndPipe.Wall.Texture.CircularShape.Locations.First.Y = 0.5;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.Locations.First.X = 0.5;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.Locations.First.Y = 0.5;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.R = 0;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.G = 0;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.B = 0;
Compartments.Shared.EndPipe.Wall.Texture.InsideShape.Alpha = NaN;




