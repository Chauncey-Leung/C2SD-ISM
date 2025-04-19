function si = get_centered_subimage(img1,center_point, ws)
%   This function extracts a (2*ws+1)-by-(2*ws+1) square subregion from the 
%   input image `img1`, centered around the given pixel location `center_point`.
%   Boundary conditions are automatically handled by clipping to the image edges.
%
%   Inputs:
%   -------
%   img1         : 2D input image (grayscale or single channel).
%   center_point : [row, col] or [y, x] coordinates of the center pixel.
%   ws           : Half-width of the desired subimage (window size).
%
%   Output:
%   -------
%   si           : Cropped sub-image of size up to (2*ws+1) × (2*ws+1). 
%                  If the region extends beyond image boundaries, it is clipped.
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------

    center_point2 = round(center_point);
    si = img1(max(center_point2(1)-ws,1):min(center_point2(1)+ws,size(img1,1)), ...
        max(center_point2(2)-ws,1):min(center_point2(2)+ws,size(img1,2)));
end