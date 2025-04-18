function addDXFEntities(FID)
    % 0:       Indicates the start of a new section (required DXF syntax)
    % SECTION: Marks the beginning of a section block
    % 2:       Group code specifying the section name
    % ENTITIES: Section containing geometric entities such as LINE, CIRCLE, etc.
    fprintf(FID, '0\nSECTION\n2\nENTITIES\n');
end