% % Generating a pinhole array distribution pattern with equal radial sampling

r1 = 17500 - 500;
r2 = 47500 - 500;
delt_r = 410; %r(n+1)-r(n)
spacing = 2500; %10x
% delt_r = 6;
% spacing = 250;
n = 12;
m = n*spacing/2/pi;

r = (r1 : delt_r: r2);
% % 阿基米德螺线
theta = (r - r1) / m; 
% % 
% % % theta = ((r - r1) / m) .^ 0.7;
% % % theta = ((r - r1) / m) .^ 1.3; 


%% Inspect the smallest pinhole spacing （< 2 x diameter of pinhole + \eplison）
% x = r .* cos(theta);
% y = r .* sin(theta);
% real_spacing = ((x(2:end)-x(1:end-1)).^2+(y(2:end)-y(1:end-1)).^2).^0.5;
% figure;plot(x,y);
% figure;plot(1:(length(s)-1),real_spacing);

coord = cell(n, 1);
d_theta = 2 * pi / n;
for idx = 1 : n
   coord{idx}(:,1) = r .* cos(theta - d_theta * (idx - 1));
   coord{idx}(:,2) = r .* sin(theta - d_theta * (idx - 1));
end

figure;
hold on;
for idx = 1 : n
%     plot(coord{idx}(:,1), coord{idx}(:,2));
    scatter(coord{idx}(:,1), coord{idx}(:,2));
end
