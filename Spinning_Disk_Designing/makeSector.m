function centers = makeSector(r1, r2, spacing, numSpirals)
    % makeSector - Generate centers' coordinate of pinhole
    %
    % Inputs:
    %    - r1, r2: Inner and outer radius (in μs)
    %    - spacing: arc length between adjacent pinholes (in μs)
    %    - numSpirals: Number of concentric spiral arms
    %    - PoverSratio: Ratio of pinhole spacing to diameter

    % r(θ) = r1 + m * θ
    m = spacing * numSpirals / (2 * pi);
    theta_max = (r2 - r1) / m;
    dtheta = 2*pi / numSpirals;
    
    fullarc = (-r1 * sqrt(m^2 + r1^2) + r2 * sqrt(m^2 + r2^2) + ...
              m^2 * log((r2 + sqrt(m^2 + r2^2)) / (r1 + sqrt(m^2 + r1^2)))) / (2 * m);
    
    arcLengthFunc = @(theta_i) ( ...
        m .* theta_i .* sqrt(r1.^2 + m .* (m + 2 .* r1 .* theta_i + m .* theta_i.^2)) + ...
        r1 .* (-sqrt(m^2 + r1.^2) + sqrt(r1.^2 + m .* (m + 2 .* r1 .* theta_i + m .* theta_i.^2))) + ...
        m.^2 .* log((r1 + m .* theta_i + sqrt(m.^2 + (r1 + m .* theta_i).^2)) ./ ...
                    (r1 + sqrt(m^2 + r1.^2))) ) ./ (2 .* m);
    
    darc = 0;
    centers = {};

    for n = 1:numSpirals
        arcs = 0 + (n-1)*darc : spacing : fullarc;
        thetas = zeros(size(arcs));
        theta_guess = 0;
        
        for i = 1:length(arcs)
            obj_fun = @(x) arcLengthFunc(x) - arcs(i);
            theta_sol = fzero(obj_fun, [theta_guess, theta_guess + 2*pi]);
            theta_guess = theta_sol;
            thetas(i) = theta_sol;
        end
        
        
        rs = r1 + m .* thetas;

        x = rs .* cos(thetas - (n-1)*dtheta);
        y = rs .* sin(thetas - (n-1)*dtheta);
        centers{n} = [x(:), y(:)];
    end
    
    centers = vertcat(centers{:});
end
