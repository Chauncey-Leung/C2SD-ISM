% % Exploring the pinhole array pattern with square lattice distribution

r_min = 17500 - 500;
r_max = 47500 - 500;
% delta_r = 6;
% spacing = 250;

% delta_r = 410;
% spacing = 2500;
spacing = 1500;

idx = 0;
limit = ceil(r_max / spacing) * spacing;
for x = -limit : spacing : limit
    for y = -limit : spacing : limit
        if (abs(x) <= r_max && abs(x) >= r_min && abs(y) <= r_max) ||...
                (abs(x) < r_min && abs(y) <= r_max && abs(y) >= r_min)
            idx = idx + 1;
            coord_x(idx) = x;
            coord_y(idx) = y;
        end
    end
end
figure; scatter(coord_x, coord_y);

r = (coord_x.^2 + coord_y.^2).^0.5;
r_sort = sort(r); 
% figure; plot(1:length(r_sort), r_sort);
figure; scatter(1:length(r_sort), r_sort);