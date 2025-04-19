% -------------------------------------------------------------------------
% ReconMain.m
%
% Description:
%   This script performs DPA-PR reconstruction for a multi-frame image stack
%   (e.g., from a sample like kidney tissue).
%   Output includes widefield image (WF.tif), DPA-PR reconstruction (resDPAPR.tif).
%
% Requirements:
%   - All dependent functions should be located in the `func\` directory.
%   - Fiji must be installed and accessible via `fijiPath`.
%   - Macro script 'sift_align.ijm' should be present in working directory.
%
% Author: Qianxi Liang (梁谦禧)
% Date: 2025-4-20
% -------------------------------------------------------------------------
addpath('func\');
folderPath = 'kidney_sample\rawdata';

isDeDC = 1;
%%  Optional DeDC Preprocessing
if isDeDC
    [PR_CONFIG.imgDeDC, PR_CONFIG.imgRaw] = preprocessDeDC(folderPath);
end

PR_CONFIG.isRaw = ~isDeDC;
PR_CONFIG.upfactor = 2;
PR_CONFIG.folderPath = folderPath;

%% Load and Scale Raw Images
imgStack = preprocessScale(PR_CONFIG);
imgNum = size(imgStack,3);
imgLength = size(imgStack, 1);

%% Estimate Direct Lattice Vectors
param.range = 3;
param.extent = 8;
param.reference = "Sum";
param.vec_estimate_manual = [0, 0; 0, 0];
isPreBasis = 0;
isDisplay = 1;
param.vec_estimate_manual = [78.4652, 1.2831; -1.5189, -74.1159];
[direct_lattice_vectors,corrected_basis_vectors, vec_estimate_manual] = ...
    getBasicVec(imgStack, param, isPreBasis, isDisplay);

latticeVec2 = direct_lattice_vectors;
% latticeVec2(1,1)=0;
% latticeVec2(2,2)=0;

%% Offset Vector Estimation
offsetVector = zeros(imgNum, 2);
for ii = 1:imgNum
    offsetVector(ii,:) = getOffsetVec(imgStack(:,:,ii), direct_lattice_vectors);
% offsetVector(ii,:) = getOffsetVec(imgStack(:,:,ii), latticeVec2);
end


N = sqrt(imgNum);
latticeLength = (norm(direct_lattice_vectors(1,:), 2) + norm(direct_lattice_vectors(2,:), 2)) / 2;
maxStep = 3;
% % Observe offset vector
% for ii = 1 : 64
%     grayImg = imgStack(:,:,ii);
%     grayImg = uint8(grayImg ./ max(grayImg(:)) .* 255);
%     rgbImg = cat(3, grayImg, grayImg, grayImg);
%     final_lattice = generate_lattice(imgLength, imgLength, offsetVector(ii, :), direct_lattice_vectors, 10);
%     for jj = 1 : length(final_lattice)
%     col = round(final_lattice(jj,1));
%     row = round(final_lattice(jj,2));
%     rgbImg(row, col, 1) = 255;
%     rgbImg(row, col, 2:3) = 0;
%     end
%     imwrite(rgbImg, 'res.tif', 'WriteMode', 'append', 'Compression', 'none');
% end

%% Lattice Unwrapping
[pRow, pCol, offsetVectorUnwrap] = unwrapOffsetVec(offsetVector, direct_lattice_vectors, 10, imgNum, 'V');

%% Calculate Illumination Points
% offsetVecFirst = [pRow(2) + pRow(1), pCol(2) + pCol(1)];
% illPointCenter = getIlluminPoint(direct_lattice_vectors, offsetVecFirst, imgLength);
illPointCenter = getIlluminPoint(direct_lattice_vectors, offsetVectorUnwrap(1,:), imgLength);

figure;
imshow(imgStack(:,:,1),[]);
hold on;
plot(illPointCenter(:,3),illPointCenter(:,4),'redx');
% figure; imshow(imgStack(:,:,1),[]);
% hold on;
% bg = 5000;
% tempImg = imgStack(:,:,1);
% for pointIdx = 1 : length(illPointCenter)
%     cordy = round(illPointCenter(pointIdx,4));
%     cordx = round(illPointCenter(pointIdx,3));
%     if tempImg(cordy, cordx) >bg && cordy>0 && cordx>0 && cordy<1024 && cordx<1027 
%         plot(illPointCenter(pointIdx,3),illPointCenter(pointIdx,4),'redx');
%     end
% end

figure; 
imshow(imgStack(:,:,1),[]);
hold on;
illPointCenter = getIlluminPoint(direct_lattice_vectors, [0,0], imgLength);
plot(illPointCenter(:,3),illPointCenter(:,4),'bluex');
illPointCenter = getIlluminPoint(direct_lattice_vectors, offsetVectorUnwrap(1,:), imgLength);
plot(illPointCenter(:,3),illPointCenter(:,4),'redx');


%% confocal sub-image Extraction
stepNum = 8; % raw data num: stepNum x stepNum
imgPiexlNum = sqrt(length(illPointCenter)) * stepNum;
ws = floor(latticeLength/2);
subImgNum = 5^2; % VDA elments num [modifiable] 
subDetImg = zeros(imgPiexlNum,imgPiexlNum,subImgNum);
% VDA elements pitch [modifiable]
deltaRow = pRow(1); 
deltaCol = pCol(1);
% deltaCol = pCol(1);
% deltaCol = -deltaRow;
% deltaRow = pRow(1)/2;

for imgIdx = 1 : imgNum
    slowIdx = floor((imgIdx - 1) / stepNum);
    fastIdx = mod(imgIdx-1, stepNum);
    img = imgStack(:,:,imgIdx);
    curIllPointCenter = illPointCenter;
%     curIllPointCenter(:,3:4) = illPointCenter(:,3:4) + [pRow(1) * slowIdx, pCol(1) * fastIdx] ;
    curIllPointCenter(:,3:4) = illPointCenter(:,3:4) + offsetVectorUnwrap(imgIdx,:) -  offsetVectorUnwrap(1,:);
    for pointIdx = 1 : length(illPointCenter)
        center = round([curIllPointCenter(pointIdx, 4),curIllPointCenter(pointIdx, 3)]);
        subimg = get_centered_subimage(img, center, ws);
        if size(subimg, 1) == (2 * ws + 1) ...
                && size(subimg, 2) == (2 * ws + 1)
            x = center(1) - ws : center(1) + ws;
            y = center(2) - ws : center(2) + ws;

            [Y,X] = meshgrid(y, x);

            xq = curIllPointCenter(pointIdx, 4) - 2*deltaCol: deltaCol ...
                :curIllPointCenter(pointIdx, 4) + 2*deltaCol;
            yq = curIllPointCenter(pointIdx, 3) - 2*deltaRow: deltaRow ...
                :curIllPointCenter(pointIdx, 3) + 2*deltaRow;
            [Yq,Xq] = meshgrid(yq, xq);
            resampleImg = griddata(X,Y,subimg,Xq,Yq);
            subDetImg(stepNum * curIllPointCenter(pointIdx, 2) + 1 + fastIdx, ...
                stepNum*curIllPointCenter(pointIdx, 1) + stepNum - slowIdx, :) = resampleImg(:);
        end
    end
end

subDetImg_temp = subDetImg;
subDetImg = zeros(imgLength, imgLength, subImgNum);
for imgIdx = 1 : subImgNum
     subDetImg(:,:, imgIdx) = imresize(subDetImg_temp(:,:, imgIdx), [imgLength imgLength], 'bicubic');
end

%% Alignment via Cross-Correlation 
refIdx = floor(subImgNum / 2) + 1;
refImg = subDetImg(:, :, refIdx);
hann_x = hann(size(subDetImg, 1));
hann_y = hann(size(subDetImg, 2));
hannWindow = hann_x * hann_y';
filter_sigma = 0.5;
refImg = refImg .* hannWindow;
refImg = imgaussfilt(refImg, filter_sigma);
shift = zeros(subImgNum, 2);
ismImg = zeros(size(refImg, 1), size(refImg, 2), subImgNum);
for imgIdx = 1 : subImgNum
    curImg = subDetImg(:,:, imgIdx);
    curImg = curImg .* hannWindow;
    curImg = imgaussfilt(curImg, filter_sigma);
    usfac = 100;
    [output, ~] = dftregistration(fft2(refImg), fft2(curImg), usfac);
    dy = output(3);
    dx = output(4);
%     registered_stack(:,:,i) = imtranslate(moving_img, [dx, dy], 'linear', 'FillValues', 0);
    shift(imgIdx, :) = [dx, dy];
    ismImg(:,:,imgIdx) = imtranslate(subDetImg(:,:,imgIdx), [dx, dy], ...
    'METHOD', 'cubic', 'FillValues', 0);
%     ismImg(:,:,imgIdx) = imtranslate(subDetImg(:,:,imgIdx), [dx, dy], ...
%     'METHOD', 'linear', 'FillValues', 0);
end
WF = mean(PR_CONFIG.imgRaw, 3);
WF = WF ./ max(WF(:)) .* 65535;
imwrite(uint16(WF), 'kidney_sample\WF.tif');
ISM = sum(ismImg, 3);
ISM = ISM ./ max(ISM(:)) .* 65535;
WF_sz = imresize(WF, size(ISM), 'bilinear');
if exist([folderPath, '\..\temp.tif'], 'file')
    delete([folderPath, '\..\temp.tif']);
end

%%  Call Fiji for SIFT Alignment via Macro
% Make sure the path is in English and has no spaces.
tempSavePath = [pwd, '\',folderPath, '\..\temp.tif'];
imwrite(uint16(WF_sz ./ max(WF_sz(:)) .* 65535), tempSavePath,...
    WriteMode='append');
imwrite(uint16(ISM ./ max(ISM(:)) .* 65535), tempSavePath,...
    WriteMode='append');
% imwrite(uint16(ISM ./ max(ISM(:)) .* 65535), 'kidney_sample\ISM.tif');

fijiPath = 'D:\fiji-win64\Fiji.app\ImageJ-win64.exe';  % Set your Fiji path
macroPath = 'sift_align.ijm';   % Make sure this macro exists in the same directory

% Make sure the path is in English and has no spaces.
inputDir = tempSavePath; 
outputDir = fileparts(tempSavePath);
macroArgs = sprintf('input="%s" output="%s"', inputDir, outputDir);
runFijiMacro(fijiPath, macroPath, macroArgs);  
delete(tempSavePath);