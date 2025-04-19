function lattice_points = generate_lattice(Width, Height, center_pix, direct_lattice_vectors, edge_buffer)
%   This function computes the coordinates of lattice points generated 
%   by two basis vectors (forming a 2D Bravais lattice), centered at 
%   a given pixel. Only points within the valid image region (excluding 
%   an edge buffer) are retained.
%
%   Inputs:
%   --------
%   Width  : Width of the image (in pixels).
%   Height : Height of the image (in pixels).
%   center_pix : [x, y] coordinates of the lattice origin (center pixel).
%   direct_lattice_vectors : A 2×2 matrix, where each row is a basis vector 
%                            [dx, dy] that defines the lattice directions.
%   edge_buffer : Number of pixels to exclude near the image edges.
%
%   Output:
%   -------
%   lattice_points : N×2 array of [x, y] coordinates of valid lattice points 
%                    within the region [edge_buffer, Width-edge_buffer] × 
%                    [edge_buffer, Height-edge_buffer].
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------

% center_pix [x y] ([Width Height])
% 
num_vectors = round(1.2 * max(Width,Height) / sqrt(sum(direct_lattice_vectors(1,:).^2)));
lower_bounds = [edge_buffer, edge_buffer];
upper_bounds = [Width - edge_buffer, Height - edge_buffer];
[xx,yy] = meshgrid(-num_vectors:num_vectors, -num_vectors:num_vectors);
xx = xx(:); yy = yy(:);
% lp = zeros(size(xx,1),2);
lp = xx.*direct_lattice_vectors(1,:)+yy.*direct_lattice_vectors(2,:)+center_pix;
lp(sum(lp > lower_bounds, 2) < 2,:) = [];
lp(sum(lp < upper_bounds, 2) < 2,:) = [];
lattice_points = lp;
end

