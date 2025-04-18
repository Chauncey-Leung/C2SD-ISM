%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename:       generateSpiralMask.m
% Description:    Generate a spiral-arranged circular pinhole pattern and 
%                 export it as a DXF file for use in spinning disk design.
%
% subfunction:
%    - makeSector()           : Computes spiral pinhole positions
%    - addDXFEntities()       : Starts DXF ENTITY section
%    - addDXFCircles()        : Writes circular features to DXF
%    - endDXFEntities()       : Ends DXF ENTITY section
%
% Author:         Qianxi Liang (梁谦禧), Peking University
% Contact:        chaunceyl@stu.pku.edu.cn
%
% Copyright (c) 2025 Qianxi Liang
% Licensed under the MIT License.
% You may freely use, modify, and distribute this code with proper attribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear; clc;
% Parameter settings
rIn = 19000; % [μm]
rOut = 45000;
margin = 500;
r1 = rIn - margin;
r2 = rOut - margin;
pinholeDiameter = 50;
PoverSratio = 5;
numSpirals = 32;

% Generate pinhole center coordinate list
centers = makeSector(r1, r2, PoverSratio * pinholeDiameter, numSpirals);
radius = repmat(pinholeDiameter/2, size(centers,1), 1);

filename = ['SD_Rin_', num2str(rIn), ...
    '_Rout_', num2str(rOut), '_N_', num2str(numSpirals), '.dxf'];
FID = fopen(filename, 'w');
addDXFEntities(FID);
addDXFCircles(FID, centers, radius);

% Add inner and outer boundary of the spinning disk
addDXFCircles(FID, [0, 0; 0, 0], [25000/2; 95000/2], 'green');
endDXFEntities(FID)
fclose(FID);
fprintf('DXF file written: %s\n', filename);


