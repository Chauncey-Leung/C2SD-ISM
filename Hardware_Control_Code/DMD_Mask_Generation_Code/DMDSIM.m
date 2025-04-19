% -------------------------------------------------------------------------
% Script: DMD pattern generator for structure illimination imaging
%
% Output:
%   - 1-bit black/white BMP images (logical binary matrices)
%
% Author: Qianxi Liang (梁谦禧), Wei Ren (任伟)
% Date  : [2024-7-19]
% -------------------------------------------------------------------------

dmdWidth = 2716;
dmdHeight = 1600;

% Stripe width (in pixels)
stripe_width = 4;

% Expand the canvas size to accommodate rotation without cropping edges
diagonal = sqrt(dmdWidth^2 + dmdHeight^2);
expanded_width = ceil(diagonal) + 2 * stripe_width;
expanded_height = ceil(diagonal) + 2 * stripe_width;

% Generate expanded coordinate grid
[x, y] = meshgrid(1:expanded_width, 1:expanded_height);

% Create alternating black and white stripes along X-axis
binary_pattern = mod(floor(x / stripe_width), 2);

% Compute cropping offset to extract the original DMD size
x_center = round((expanded_width - dmdWidth) / 2);
y_center = round((expanded_height - dmdHeight) / 2);


images = cell(3, 3);

for shift = 0:2
    for rotation = 0:2
        shifted_pattern = circshift(binary_pattern, [0, 2 * shift]);
        rotated_pattern = imrotate(shifted_pattern, 120 * rotation, 'bilinear', 'crop');
        rotated_pattern = rotated_pattern > 0.5;
        cropped_pattern = rotated_pattern(y_center + (1:dmdHeight), x_center + (1:dmdWidth));
        images{shift+1, rotation+1} = cropped_pattern;
        

        logical_pattern = logical(cropped_pattern);
        saveFolderName = '4-4';
        if ~exist(saveFolderName, 'dir')
            mkdir(saveFolderName)
        end
        filename = sprintf([saveFolderName, ...
            '\\binary_stripes_rotation_%d_shift_%d.bmp'], ...
            120 * rotation, 2 * shift);
        imwrite(logical_pattern, filename, 'bmp');
        
%         figure;
%         imshow(cropped_pattern, []);
%         colormap(gray);
%         colorbar;
%         title(sprintf('Shift %d pixels, Rotation %d degrees', 2 * shift, 120 * rotation));
    end
end
