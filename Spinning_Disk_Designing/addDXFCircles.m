function addDXFCircles(FID, centers, radius, color, layname)
    % addDXFCircles - Write circle entities to a DXF file
    %
    % Inputs:
    %   FID      - File identifier (from fopen)
    %   centers  - Array of [x, y] coordinates of circle centers
    %   radius   - Array of circle radii
    %   color    - (optional) Color name (e.g., 'red', 'green') [default: 'white']
    %   layname  - (optional) Layer name [default: 'layer1']
    %
    if nargin==3
        color = 'white';
        layname = 'layer1';
    end
    if nargin == 4
        layname = 'layer1';
    end
    % Map color name to DXF color code
    switch color
        case 'red'
           colorId = 1;
        case 'yellow'
           colorId = 2;
        case 'green'
           colorId = 3;
        case 'cyan'
           colorId = 4;
        case 'blue'
           colorId = 5;
        case 'magenta'
           colorId = 6;
        case 'white'
           colorId = 7;
        case 'black'
           colorId = 7;
        otherwise
           error('Illegal color value.');
    end 

     % Write CIRCLE entities
    for i = 1:size(centers,1)
        % 0:         Start of a new entity
        % CIRCLE:    Entity type
        % 8:         Layer name
        % 62:        Color code
        fprintf(FID, '0\nCIRCLE\n8\n%s\n62\n%d\n', layname, colorId);
        % 10:   Center X
        % 20:   Center Y
        % 30:   Center Z (always 0 for 2D)
        % 40:   Radius
        fprintf(FID, '10\n%f\n20\n%f\n30\n0.0\n', centers(i,1), centers(i,2));  
        fprintf(FID, '40\n%f\n', radius(i));              
    end

end
