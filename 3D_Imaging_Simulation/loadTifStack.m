function tifStack = loadTifStack(tifPath)

    tifInfo = imfinfo(tifPath);
    tifWidth = tifInfo(1).Width;
    tifHeight = tifInfo(1).Height;
    tifDepth = length(tifInfo);
    
    tifStack = zeros(tifHeight, tifWidth, tifDepth);
    for depthIdx = 1 : tifDepth
        tifStack(:,:, depthIdx) = double(imread(tifPath, depthIdx));
    end

end