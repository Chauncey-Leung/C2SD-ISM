% -------------------------------------------------------------------------
% Script: DMD pattern generator for multi-focus scanning imaging
%
% Output:
%   - 1-bit black/white BMP images (logical binary matrices)
%
% Author: Qianxi Liang (梁谦禧), Wei Ren (任伟)
% Date  : [2024-7-19]
% -------------------------------------------------------------------------

dmdWidth = 2716;
dmdHeight = 1600;


imageIndex = 0;


for verticalShift = 0:2 
    for horizontalShift = 0:2 
        % Create black background image
        image = zeros(dmdHeight, dmdWidth, 'uint8');

         % Generate grid of white squares with
        for i = 1 + verticalShift * 6 : 18 : dmdHeight 
            for j = 1 + horizontalShift * 6 : 18 : dmdWidth
                % Ensure the block fits within image bounds
                if i + 5 <= dmdHeight && j + 5 <= dmdWidth
                    image(i:i+5, j:j+5) = 255;
                end
            end
        end

        % Convert to binary logical image
        image = logical(image);
        saveFolderName = '6-18-6';
        if ~exist(saveFolderName, 'dir')
            mkdir(saveFolderName)
        end
        filename = sprintf([saveFolderName, '\\output_%d.bmp'], imageIndex);
        imwrite(image, filename, 'bmp');
        
        % Increment image index
        imageIndex = imageIndex + 1;
    end
end

