% % Simulate rotation of spinning disk

%% load coordination
% load("n24.mat");
% coord_x = coord{1}(:, 1);
% coord_y = coord{1}(:, 2);
% for idx = 2 : 24
%     coord_x = [coord_x;  coord{idx}(:, 1)];
%     coord_y = [coord_y;  coord{idx}(:, 2)];
% end
% figure; scatter(coord_x, coord_y);

%% Generation psf
lambda = 0.64;

NA = 1.49;
% PSF = @(x) (abs(2*besselj(1,(x+eps))./(x+eps))).^2;
PSF = @(x,sigma) exp(-(x+eps).^2./(2*sigma).^2);
% sigma = 2 * lambda / NA * 3500;
% sigma = 2 * lambda / NA * 2500;

%% Generation grid
stepsize = 1;
x = -4.75e4 : 10 : 4.75e4;
[xx, yy] = meshgrid(x);

% % pinhole spacing
% s = ((coord_y(4)-coord_y(3)).^2+(coord_x(4)-coord_x(3)).^2).^0.5;

result = zeros(size(xx));
r0 = (coord_x(1)^2+coord_y(1)^2)^0.5;
for spot_idx = 1 : length(coord_x)
    spot_x = coord_x(spot_idx);
    spot_y = coord_y(spot_idx);
    rho = 2 * pi * NA * sqrt((xx-spot_x).^2 + (yy-spot_y).^2) ./ lambda;
%     sigma = 2 * lambda / NA * 2500 / r0 * ((coord_x(spot_idx)^2+coord_y(spot_idx)^2)^0.5);
%     sigma = 2 * lambda / NA * 2500 * (((coord_x(spot_idx)^2+coord_y(spot_idx)^2)^0.5) / r0)^0.5;
    sigma = 2 * lambda / NA * 2500;
    result = result + PSF(rho, sigma);
    
    if mod(spot_idx,20)==0
        disp(spot_idx);
%         figure;imshow(result, []);
    end
end

Intensity = zeros(size(result));
% figure; imshow(result,[]);
% drawnow;
% F=getframe(gcf);
% I=frame2im(F);
% [I,map]=rgb2ind(I,256);
% imwrite(I, map, 'C:\Users\1\Desktop\12rot.gif', 'gif', 'Loopcount', inf, 'DelayTime', 0.05)
for d_theta = 0 : 0.1 : 29.9
    Intensity = Intensity + imrotate(result, d_theta, 'bilinear','crop');
%     result_rot = imrotate(result, d_theta, 'bilinear','crop');
    if mod(d_theta,10)==0
        disp(d_theta);
    end
%     imshow(result_rot, []);
%     drawnow;
%     F=getframe(gcf);
%     I=frame2im(F);
%     [I,map]=rgb2ind(I,256);
%     imwrite(I, map, 'C:\Users\1\Desktop\12rot.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
end


figure;imshow(Intensity,[]);
% % 
% % % tfform = rigidtform2d(30,[0 0]);
% % 
% % % d_theta = 30;
% % % tfform = affine2d([cosd(d_theta),-sind(d_theta),0; ...
% % %                    sind(d_theta), cosd(d_theta),0; ...
% % %                    0,0,1]);
% % % Rfixed = imref2d(size(result));
% % % result_rot = imwarp(result, tfform, 'OutputView',Rfixed);
% % 
% % figure;imshow(result_rot, []);
% % figure;imshow(abs(result-result_rot), []);