%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename:       genImg.m
% Description:    Generate image using Objective function and PSF based on
%                 img(r) = obj(r) \conv2 psf(r).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objPath = 'C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\ref_beadsigma2.tif';
psfPath = 'C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\PSF BW.tif';
imgPath = 'C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\img_wf2.tif';

objInfo = imfinfo(objPath);
objWidth = objInfo(1).Width;
objHeight = objInfo(1).Height;
stack_depth = length(objInfo);
image_stack = zeros(objHeight, objWidth, stack_depth);
for depthIdx = 1 : stack_depth
    image_stack(:,:, depthIdx) = double(imread(objPath, depthIdx));
end
image_stack = image_stack / sum(image_stack(:));


psfInfo = imfinfo(psfPath);
psfWidth = psfInfo(1).Width;
psfHeight = psfInfo(1).Height;
stack_depth = length(psfInfo);
psf = zeros(psfHeight, psfWidth, stack_depth);
for depthIdx = 1 : stack_depth
    psf(:,:, depthIdx) = double(imread(psfPath, depthIdx));
end
% Normalize the PSF (make sure the total energy of the PSF is 1)
psf = psf / sum(psf(:));

% 'same' ensures that the output and input stack sizes are the same
% output_stack = convn(image_stack, psf, 'same');

% fft_image_stack = fftshift(fftn(image_stack));
% fft_psf = fftshift(fftn(psf));
fft_image_stack = fftn(image_stack);
fft_psf = fftn(psf);
fft_convolved = fft_image_stack .* fft_psf;
convolved_stack =  ifftshift(ifftn(fft_convolved));

convolved_stack = convolved_stack ./ max(convolved_stack(:)) .*65535;

for depthIdx = 1 : stack_depth
    imwrite(uint16(convolved_stack(:,:, depthIdx)),...
        imgPath, WriteMode='append');
end

