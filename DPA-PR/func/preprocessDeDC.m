function [imgPre, imgRaw] = preprocessDeDC(filepath)
%   This function loads a stack of grayscale images from a specified folder,
%   performs Fourier transform along the temporal dimension,
%   removes the DC component (mean frame), and reconstructs the signal 
%   using inverse FFT. This suppresses static background or low-frequency
%   illumination artifacts across frames.
%
%   Inputs:
%   -------
%   filepath : String specifying the folder containing input image files.
%              All files in the folder are assumed to be images of the same size.
%
%   Outputs:
%   --------
%   imgPre   : Preprocessed image stack with DC component removed (Height × Width × N)
%   imgRaw   : Original raw image stack (Height × Width × N)
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------


    filepathread = [filepath, '\'];
    fileinfo = dir(filepathread);

    n = length(fileinfo) - 2;
    for idx = 3:length(fileinfo)
        temp = double(imread(strcat(filepathread, fileinfo(idx).name)));
        if idx == 3
            [height, width] = size(temp);
            imgRaw = zeros(height, width, n);
        end
        imgRaw(:,:,idx-2) = temp;
    end
    
    fft_img = fft(imgRaw,[],3);
    fft_img(:,:,1) = zeros(height, width);
    imgPre = ifft(fft_img,[],3);
    imgPre(imgPre<0) = 0;
    imgPre = abs(imgPre);

end