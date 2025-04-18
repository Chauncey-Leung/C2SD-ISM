function img3D = conv3DFFT(obj3D, psf3D)

fft_obj3D = fftn(obj3D);
fft_psf3D = fftn(psf3D);
fft_convolved = fft_obj3D .* fft_psf3D;
img3D =  ifftshift(ifftn(fft_convolved));
img3D = real(img3D);

end