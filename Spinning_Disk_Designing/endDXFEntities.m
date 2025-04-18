function endDXFEntities(FID)
    % ENDSEC: End of the ENTITIES section
    % EOF:    End of the DXF file
    fprintf(FID, '0\nENDSEC\n0\nEOF\n');
end