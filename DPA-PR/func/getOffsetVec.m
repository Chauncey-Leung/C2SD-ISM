function offset_vector = getOffsetVec(img1, direct_lattice_vectors)
%   This function estimates the global shift (offset) between the center of 
%   an image and the underlying lattice pattern defined by the given direct-space
%   lattice vectors. The offset is computed by averaging localized signals at
%   expected lattice points, identifying the global peak, and performing 
%   subpixel refinement using 2D quadratic fitting.
%
%   Inputs:
%   -------
%   img1                   : 2D input image (single frame).
%   direct_lattice_vectors : 2×2 matrix where each row is a real-space 
%                            lattice vector [dx dy].
%
%   Output:
%   -------
%   offset_vector        : 1×2 vector [x_offset, y_offset] representing
%                          the subpixel offset of the lattice relative to 
%                          the image center.    
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------


    [Height,Width] = size(img1); 
    interpPoints = -1: 1: 1;
    
    img1 = medfilt2(img1);
    % Maybe it is necessary to enlarge the ws as a correction for more slanted pinholes
    ws = round(ceil(max(abs(direct_lattice_vectors(:)))) / 2) +3;
%     ws = ceil(round(mean([norm(direct_lattice_vectors(1, :), 2), ...
%                      norm(direct_lattice_vectors(2, :), 2)])) / 2);
    window = zeros(2*ws+1);
    % % Avoid edge artifacts by setting an edge buffer
    edge_buffer = 2 + ws;
    center_pix = [Width/2, Height/2] + 1;
    lattice_points = generate_lattice(Width, Height, center_pix, direct_lattice_vectors, edge_buffer); % [x ，y] (Width, Height)
% %     figure;
% %     imshow(img1,[]);
% %     hold on;
% %     plot(lattice_points(:,1),lattice_points(:,2),'o');
    for ii = 1:size(lattice_points, 1)
        loc = zeros(1, 2);
        loc(1, 2) = lattice_points(ii, 1);
        loc(1, 1) = lattice_points(ii, 2);
        temp = get_centered_subimage(img1, loc, ws);
        window = window + temp;
    end
    window2 = zeros(2*ws+1);
    window2(3:end-2, 3:end-2) = window(3:end-2, 3:end-2);
    [ymax, xmax] = find(window2 == max(window2(:)));
    if length(xmax)>1
        xmax = xmax(1); ymax = ymax(1);
    end
    if ~((xmax < ws*2) && (xmax > 2)) && ((ymax < ws*2) && (ymax > 2))
        error('Error');
    end
    temp = window(ymax(1)-1: ymax(1)+1, xmax(1)-1: xmax(1)+1);

    tempy = temp(:,2);
    [xData, yData] = prepareCurveData(interpPoints, tempy');
    ft = fittype('poly2');
    [fitresult, ~] = fit( xData, yData, ft);
    offset_vector(2) = -fitresult.p2/(2*fitresult.p1) + ymax;

    tempx = temp(2,:);
    [xData, yData] = prepareCurveData(interpPoints, tempx);
    ft = fittype('poly2');
    [fitresult, ~] = fit(xData, yData, ft);
    offset_vector(1) = -fitresult.p2/(2*fitresult.p1) + xmax;

    offset_vector = offset_vector - ws - 1 + center_pix;

%     figure()
%     imagesc(img1)
%     title(['offset-vector: (' num2str(offset_vector(1)) ',' num2str(offset_vector(2)) ')'])
%     axis image
%     axis off
%     colormap gray
%     hold on
%     quiver(lattice_points(1,1),lattice_points(1,2),offset_vector(1),offset_vector(2),'g','autoscale','off')
% %     for p = 1:length(lattice_points)
%     for p = 1:150
% %         quiver(lattice_points(p,1),lattice_points(p,2),offset_vector(1),offset_vector(2),'g','autoscale','off')
%         plot(lattice_points(p,1),lattice_points(p,2),'b+');
%         plot(lattice_points(p,1)+offset_vector(1),lattice_points(p,2)+offset_vector(2),'r+');
%     end

end

