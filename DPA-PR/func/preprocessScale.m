function Img = preprocessScale(PR_CONFIG)
%   This function performs spatial upsampling and zero-padding to square shape
%   for an input image stack. The input can be either raw images or DeDC-
%   preprocessed images, depending on the configuration flag. The output 
%   images are all resized and centered into a square canvas.
%
%   Inputs:
%   -------
%   PR_CONFIG : Struct with the following fields:
%       - isRaw    : Boolean flag. If true, use PR_CONFIG.imgRaw.
%                   If false, use PR_CONFIG.imgDeDC.
%       - upfactor : Upsampling factor (2, 4, or 8).
%       - imgRaw   : Raw image stack (Height × Width × N).
%       - imgDeDC  : Preprocessed image stack after DeDC (optional).
%
%   Output:
%   -------
%   Img : 3D image stack (MaxLength × MaxLength × N), where each image has been
%         upsampled and padded to square.
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------


    isRaw = PR_CONFIG.isRaw;
    upfactor = PR_CONFIG.upfactor;

    if isRaw
        Width = size(PR_CONFIG.imgRaw, 1) * upfactor;
        Height = size(PR_CONFIG.imgRaw, 2) * upfactor;
        imgNum = size(PR_CONFIG.imgRaw, 3);
        MaxLength = max(Height, Width);
        Img = zeros(MaxLength, MaxLength, imgNum);
        Img1 = PR_CONFIG.imgRaw;
    else
        Width = size(PR_CONFIG.imgDeDC, 1) * upfactor;
        Height = size(PR_CONFIG.imgDeDC, 2) * upfactor;
        imgNum = size(PR_CONFIG.imgDeDC, 3);
        MaxLength = max(Height, Width);
        Img = zeros(MaxLength, MaxLength, imgNum);
        Img1 = PR_CONFIG.imgDeDC;
    end

    for imgIndex = 1 : imgNum
        temp = Img1(:, :, imgIndex);
        if upfactor == 2
            temp = imresize(temp, 2, 'bilinear');
        elseif upfactor == 4
            temp = imresize(temp, 2, 'bilinear');
            temp = imresize(temp, 2, 'bilinear');
        elseif upfactor == 8
            temp = imresize(temp, 2, 'bilinear');
            temp = imresize(temp, 2, 'bilinear'); 
            temp = imresize(temp, 2, 'bilinear'); 
        end
        if Width > Height
            temp = padarray(temp, [(Width-Height)/2,0], 'both');
            MinH = (Width-Height)/2;
            MaxH = Width - (Width - Height)/2;
            MinW = 0;
            MaxW = Width;
        elseif Width < Height
            temp = padarray(temp, [0,(Height-Width)/2], 'both');
            MinH = 0;
            MaxH = Height;
            MinW = (Height - Width)/2;
            MaxW = Height - (Height - Width)/2;
        else
            MinH = 0;
            MaxH = Height;
            MinW = 0;
            MaxW = Width;
        end
        Img(:,:,imgIndex) = temp;
    end
end