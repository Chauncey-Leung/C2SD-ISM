%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename:       genIsmRawDataMultiLayer3D_msp.m
% Description:    Generate three-dimensional ISM raw dataset
%                 memory saving plus (msp) version 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear; clc;

%% Basic parameters, parameters can be modified
SNR = 25; % dB

filePath = 'C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\';
psf_ex = loadTifStack([filePath, 'PSF BW.tif']);
psf_ex = psf_ex ./ sum(psf_ex(:));

psf_em = loadTifStack([filePath,'PSF BW.tif']);
% psf_em = loadTifStack([filePath,'PSF BW.tif']);
psf_em = psf_em(:,:,600-127:600+128);
psf_em = psf_em ./ sum(psf_em(:));

Img = loadTifStack([filePath,'ref_beadsigma2.tif']);
Img = Img./max(Img(:)).*2000;
[height, width, depth] = size(Img);

% Generate pinhole center
offset = 1;

%% According to the PSF size, the parameters can be modified
step = 5; % The moving step is 0.5 times the PSF half-height width (PSF/2)
% step = 25;
% In order to form a uniform field for illumination, the lattice size is 
% related to the multiple of the step size.
griddis = step * 10;        
% Number of steps moved
count = ceil(griddis/step);

%% location of pinholes
pinhole_center = zeros(height, width, count, count);
peakloc = cell(count*count,1);

for ii = 1:count
    for jj = 1:count
        center_x = round(offset+(jj-1)*step: griddis :width-offset);
        center_y = round(offset+(ii-1)*step: griddis :height-offset);
        [cx,cy] = meshgrid(center_x, center_y);
        cx = cx(:); cy = cy(:);
        temp = zeros(height, width);
        for kk = 1:length(cx)
            temp(cy(kk), cx(kk)) = 1;
        end
        pinhole_center(:,:,ii, jj) = temp;
        % % % % ! remember to plot to see if the rows and columns are reversed
        [A_msh, B_msh] = meshgrid(cx, cy);
        AB = [A_msh(:), B_msh(:)];
        peakloc{(ii-1)*count+jj} = AB;
%         figure; 
%         plot(peakloc{(ii-1)*count+jj}(:,2),peakloc{(ii-1)*count+jj}(:,1),'o');
    end
end
figure;imshow( pinhole_center(:,:,1,1),[]);

% pinhole_center eg 256x256x8x8, now we need to generate 3D pinhole_ex. 
% Ideally, if the psf_ex depth is 1200, pinhole_ex needs to be 
% 256x256x1200x8x8, which takes up a lot of memory. Therefore, we only take
% the interval of 600-127:600+128 if the psf_ex depth is 600-127:600+128, 
% and set all others to 0
cut_inter_l = 600-127;
cut_inter_h = 600+128;
depth_ms = cut_inter_h - cut_inter_l + 1;
pinhole_ex = deal(zeros(height, width, depth_ms ,count, count));
for ii = 1 : count
    for jj = 1 : count
        for kk = 1 : depth_ms
            pinhole_ex(:,:, kk ,ii,jj) = conv2(pinhole_center(:, :, ii, jj), psf_ex(:,:,kk+cut_inter_l-1), 'same');
        end
        disp(num2str((ii-1)*count+jj));
    end
end 
pinhole_ex = pinhole_ex ./ max(pinhole_ex(:));

figure;imshow(pinhole_ex(:,:,128),[]);
%% Forward Propagation
% % for i = 1 : 128
% %     imwrite(uint16(65535.*pinhole_ex(:,:,i,1,1))./ max(pinhole_ex(:)),'C:\Users\1\Desktop\ill.tif',WriteMode='append')
% % end

DOF=128; % Only consider the range of depthIdx-(DOF-1) ~ depthIdx+DOF
for depthIdx = 1:depth
% for depthIdx = 572:572
% for depthIdx = 1:1
    disp(['Generating image of depth: ', num2str(depthIdx), '...']);
    filepath = strcat('C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\3D imageing\3D wo SDdenser msp\',...
        num2str(depthIdx, '%03d'), '\pinhole_ALN_raw');
    mkdir(filepath)
    WF = zeros(512, 512);
    
    % Take the image stack in the range of depthIdx-(DOF-1) ~ depthIdx+DOF
    cur_img_stack = zeros(256,256,DOF*2);
    if depthIdx < 128
        cur_img_stack(:, :, DOF-(depthIdx-1):2*DOF) = Img(:, :, 1: depthIdx + DOF);
    elseif depthIdx > 1200 -128
        cur_img_stack(:,:, 1:DOF+(depth-depthIdx)) = Img(:, :, depthIdx - (DOF-1): depth);
    else
        cur_img_stack = Img(:, :, depthIdx - (DOF - 1): depthIdx + DOF);
    end

    for ii = 1:count
        for jj = 1:count
            disp(['depth: ', num2str(depthIdx), '| seq: ', num2str((ii-1)*count+jj, '%03d')]);

            cur_pinhole_ex =  pinhole_ex(:,:,:,ii,jj);
%             if depthIdx < 128
%                 cur_pinhole_ex(:,:,1:depthIdx+128) = pinhole_ex(:,:,128-(depthIdx-1):256,ii,jj);
%             elseif depthIdx > 1200 - 128
%                 cur_pinhole_ex(:,:,depthIdx-(128-1):1200) = pinhole_ex(:,:,1:128+(1200-depthIdx),ii,jj);
%             else
%                 cur_pinhole_ex(:,:,depthIdx-(128-1):depthIdx+128) = pinhole_ex(:,:,1:256,ii,jj);
%             end

            illminPattern = cur_pinhole_ex;
            temp = illminPattern .* cur_img_stack;
            temp = conv3DFFT(temp, psf_em);
    %         sigPower = max(temp(:))^2;
    %         Calculate the approximate signal-to-noise ratio
    %         sigPower = 800^2;
    %         noisePower = sigPower*10^(-SNR/10);  % SNR
    %         temp = temp+200+sqrt(noisePower)*randn(height, width);  % Need to be commented out when no noise is added
    %         res = temp(:,:,depthIdx);
            res = temp(:,:,DOF);
            res = padarray(res,[128,128], 'both');
            imwrite(uint16(res .* 500),strcat(filepath,'\', num2str((ii-1)*count+jj, '%03d'),'.tif'));
    %       imwrite(uint16(temp(:,:,depthIdx) .* 100),strcat(filepath,'\', num2str((ii-1)*count+jj, '%03d'),'.tif'));
            WF = WF + res .* 500;
        end
    end
    WF = WF / 100;
    imwrite(uint16(WF),strcat('C:\Users\1\Desktop\3Dsimulation\cube of spherical beads\3D imageing\wf_msp\',...
        num2str(depthIdx, '%03d'), '.tif'));
end