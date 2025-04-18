%% Take a look at what different spirals look like.
% % r = r1 + m \theta^k
% When k = 1, arithmetic spiral.
% When k > 1, accelerating spiral. 
% When 0 < k < 1, decelerating spiral .

r_min = 17500 - 500;
% r_min = 0;
r_max = 47500 - 500;
k = 1;
spacing = 2500; % x 10
n = 24;
m = n * spacing / 2 / pi;

theta_min = 0;
theta_max = ((r_max - r_min) / m) ^ (1 / k);

theta = (theta_min : 0.01: theta_max);
r = r_min + m .* (theta .^ k);

coord = cell(n, 1);
d_theta = 2 * pi / n;
for idx = 1 : n
   coord{idx}(:,1) = r .* cos(theta - d_theta * (idx - 1));
   coord{idx}(:,2) = r .* sin(theta - d_theta * (idx - 1));
end
figure;
title("k=" + num2str(k))
hold on;
for idx = 1 : n
    plot(coord{idx}(:,1), coord{idx}(:,2));
%     scatter(coord{idx}(:,1), coord{idx}(:,2));
end