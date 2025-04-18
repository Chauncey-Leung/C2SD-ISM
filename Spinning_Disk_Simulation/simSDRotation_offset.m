% % Simulate rotation of spinning disk with offset

%% load coordination
load("stimulate.mat");

result_offset = zeros(size(result));
result_offset = result; % no offset
% % result_offset(:,1:end-5) = result(:,6:end); % offset 50 um
% % result_offset(:,1:end-50) = result(:,51:end); % offset 500 um

% % figure;imshow(result_offset, []);
% % figure;imshow(result,[]);
% % figure;imshow(abs(result_offset-result),[]);

Intensity = zeros(size(result));
idx = 0;
for d_theta = 0.1 : 0.1 : 360
    idx = idx + 1;
    Intensity = Intensity + imrotate(result_offset, d_theta, 'bilinear','crop');
    if mod(idx,10)==0
        disp("summimg:... " + num2str(d_theta) + " / 360");
        imwrite(uint16(imresize(Intensity,[1024,1024])),strcat('E:\sim_spinningDisk\sprial_sim\',num2str(idx/10,'%03d'),'.tif'),"tif");
    end
end
