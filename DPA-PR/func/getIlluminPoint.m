function illPointCenter = getIlluminPoint(direct_lattice_vectors, offsetVecFirst, imgLength)
%   This function calculates the positions of illumination centers across a 
%   2D image grid based on two given direct-space lattice vectors. It starts 
%   from a reference offset vector and expands the grid until it covers the 
%   image area.
%
%   Inputs:
%   -------
%   direct_lattice_vectors : 2×2 matrix containing two lattice vectors [dx dy]
%                             defining the illumination pattern.
%   offsetVecFirst         : 1×2 vector specifying the position offset for the 
%                             first illumination point (e.g., [x, y]).
%   imgLength              : Scalar defining the image width and height 
%                             (assumes square image).
%
%   Output:
%   -------
%   illPointCenter         : N×4 matrix, where each row represents an illumination 
%                             point:
%                             - columns 1-2: lattice indices (i, j)
%                             - columns 3-4: corresponding [x, y] image coordinates
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------


maxLatticeLength = ceil(max(direct_lattice_vectors(:)));
numVec = floor(imgLength / maxLatticeLength);

if find(direct_lattice_vectors(1, :)==max(direct_lattice_vectors(1, :))) == 1
    latticeVec1 = direct_lattice_vectors(1, :);
    latticeVec2 = direct_lattice_vectors(2, :);
else
    latticeVec1 = direct_lattice_vectors(2, :);
    latticeVec2 = direct_lattice_vectors(1, :);
end

startVec = offsetVecFirst;

buffer = 15;
while startVec(2) > buffer || startVec(1) > buffer
    if startVec(2) > buffer
        startVec = startVec - latticeVec2;
    end
    if startVec(1) > buffer
        startVec = startVec - latticeVec1;
    end
end

[xx,yy] = meshgrid(0:numVec, 0:numVec);
xx = xx(:); yy = yy(:);
illPointCenter = zeros(length(xx), 4);
illPointCenter(:, 1) = xx;
illPointCenter(:, 2) = yy;
illPointCenter(:,3:4) = xx .*latticeVec1 + yy .* latticeVec2 + startVec;
% todo: filter out-of-bounds points, e.g.:
% % illPointCenter(:,1) = [];
% % illPointCenter(sum(illPointCenter<0, 2), :) = [];
% % ......

end