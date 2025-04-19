function [pRow, pCol, offsetVectorUnwrap4] = unwrapOffsetVec(offsetVector, direct_lattice_vectors, maxStep, imgNum, fastAxis)
%   This function performs 2D unwrapping on a grid of measured offset vectors 
%   between lattice-aligned illumination positions. The offsets are assumed 
%   to have spatial discontinuities due to phase-wrapping or measurement jumps.
%   It corrects jumps in both slow and fast axes, row- and column-wise.
%
%   Inputs:
%   -------
%   offsetVector           : [N×2] array of [row, col] offset vectors.
%   direct_lattice_vectors : 2×2 array where each row is a lattice step vector.
%   maxStep                : Maximum allowed step between adjacent offsets (threshold).
%   imgNum                 : Total number of images (must be a perfect square).
%   fastAxis               : Character 'H' (horizontal) or 'V' (vertical), defining scan order.
%
%   Outputs:
%   --------
%   pRow                   : Polynomial coefficients (1st order) fitted to the average row offsets.
%   pCol                   : Polynomial coefficients (1st order) fitted to the average column offsets.
%   offsetVectorUnwrap4    : Final unwrapped offset vector matrix [N×2].
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------



% offsetVector [row col]
% direct_lattice_vectors [row1,col1; row2, col2]
N = sqrt(imgNum);
if fastAxis == 'V'
    fastIdx = 2;
    slowIdx = 1;
elseif fastAxis == 'H'
    fastIdx = 1;
    slowIdx = 2;
end

if  abs(direct_lattice_vectors(1, fastIdx)) > abs(direct_lattice_vectors(2, fastIdx))
    incFast = direct_lattice_vectors(1, :);
    incSlow = direct_lattice_vectors(2, :);
    totalFast = abs(max(incFast));
    totalSlow = abs(max(incSlow));
elseif abs(direct_lattice_vectors(1, fastIdx)) < abs(direct_lattice_vectors(2, fastIdx))
    incFast = direct_lattice_vectors(2, :);
    incSlow = direct_lattice_vectors(1, :);
    totalFast = abs(max(incFast));
    totalSlow = mabs(ax(incSlow));
end

% argmax(direct_lattice_vectors )

offsetVectorUnwrap = offsetVector;

for ii = 1 : N
    for jj = 2:N
        curIdx = N*(ii-1)+jj;
        preIdx = N*(ii-1)+jj-1;
        if abs(offsetVectorUnwrap(curIdx, slowIdx) - offsetVectorUnwrap(preIdx, slowIdx)) > maxStep
            if offsetVectorUnwrap(curIdx, slowIdx) > offsetVectorUnwrap(preIdx, slowIdx)
                while offsetVectorUnwrap(curIdx, slowIdx) - offsetVectorUnwrap(preIdx, slowIdx) > maxStep
                    offsetVectorUnwrap(curIdx, :) = offsetVectorUnwrap(curIdx, :) - incSlow;
                end
            elseif offsetVectorUnwrap(curIdx, slowIdx) < offsetVectorUnwrap(N*(ii-1)+jj-1, slowIdx)
                while offsetVectorUnwrap(curIdx, slowIdx) - offsetVectorUnwrap(preIdx, slowIdx) < -maxStep
                    offsetVectorUnwrap(curIdx, :) = offsetVectorUnwrap(curIdx, :) + incSlow;
                end
            end
        end
    end
end

offsetVectorUnwrap2 = offsetVectorUnwrap;
for ii = N + (1 : N : N * (N-1))
    for jj = 0 : N - 1
        curIdx = ii + jj;
        preIdx = ii + jj - N;
        if abs(offsetVectorUnwrap2(curIdx, slowIdx) - offsetVectorUnwrap2(preIdx, slowIdx)) > maxStep
            if offsetVectorUnwrap2(curIdx, slowIdx) > offsetVectorUnwrap2(preIdx, slowIdx)
                while offsetVectorUnwrap2(curIdx, slowIdx) - offsetVectorUnwrap2(preIdx, slowIdx) > maxStep
                    offsetVectorUnwrap2(curIdx, :) = offsetVectorUnwrap2(curIdx, :) - incSlow;
                end
            elseif offsetVectorUnwrap2(curIdx, slowIdx) < offsetVectorUnwrap2(preIdx, slowIdx)
                while offsetVectorUnwrap2(curIdx, slowIdx) - offsetVectorUnwrap2(preIdx, slowIdx) < -maxStep
                    offsetVectorUnwrap2(curIdx, :) = offsetVectorUnwrap2(curIdx, :) + incSlow;
                end
            end
        end
    end
end

offsetVectorUnwrap3 = offsetVectorUnwrap2;
for ii = N + (1 : N : N * (N-1))
    for jj = 0 : N - 1
        curIdx = ii + jj;
        preIdx = ii + jj - N;
        if abs(offsetVectorUnwrap3(curIdx, fastIdx) - offsetVectorUnwrap3(preIdx, fastIdx)) > maxStep
            if offsetVectorUnwrap3(curIdx, fastIdx) > offsetVectorUnwrap3(preIdx, fastIdx)
                while offsetVectorUnwrap3(curIdx, fastIdx) - offsetVectorUnwrap3(preIdx, fastIdx) > maxStep
                    offsetVectorUnwrap3(curIdx, :) = offsetVectorUnwrap3(curIdx, :) - incFast;
                end
            elseif offsetVectorUnwrap3(curIdx, fastIdx) < offsetVectorUnwrap3(preIdx, fastIdx)
                while offsetVectorUnwrap3(curIdx, fastIdx) - offsetVectorUnwrap3(preIdx, fastIdx) < -maxStep
                    offsetVectorUnwrap3(curIdx, :) = offsetVectorUnwrap3(curIdx, :) + incFast;
                end
            end
        end
    end
end
% visoffsetVectorUnwrap2 = reshape(offsetVectorUnwrap2(:,2), [N,N]);

offsetVectorUnwrap4 = offsetVectorUnwrap3;
for ii = 1 : N
    for jj = 2:N
        curIdx = N*(ii-1)+jj;
        preIdx = N*(ii-1)+jj-1;
        if abs(offsetVectorUnwrap4(curIdx, fastIdx) - offsetVectorUnwrap4(preIdx, fastIdx)) > maxStep
            if offsetVectorUnwrap4(curIdx, fastIdx) > offsetVectorUnwrap4(preIdx, fastIdx)
                while offsetVectorUnwrap4(curIdx, fastIdx) - offsetVectorUnwrap4(preIdx, fastIdx) > maxStep
                    offsetVectorUnwrap4(curIdx, :) = offsetVectorUnwrap4(curIdx, :) - incFast;
                end
            elseif offsetVectorUnwrap4(curIdx, fastIdx) < offsetVectorUnwrap4(N*(ii-1)+jj-1, fastIdx)
                while offsetVectorUnwrap4(curIdx, fastIdx) - offsetVectorUnwrap4(preIdx, fastIdx) < -maxStep
                    offsetVectorUnwrap4(curIdx, :) = offsetVectorUnwrap4(curIdx, :) + incFast;
                end
            end
        end
    end
end
% visoffsetVectorUnwrap2 = reshape(offsetVectorUnwrap4(:,2), [N,N]);
fastDirOffset = reshape(offsetVectorUnwrap4(:,fastIdx), [N, N])';
slowDirOffset = reshape(offsetVectorUnwrap4(:,slowIdx), [N, N]);
avgFastDirOffset = mean(fastDirOffset, 1);
avgSlowDirOffset = mean(slowDirOffset, 1);
% avgFastDirOffset = [avgFastDirOffset, ...
%     avgFastDirOffset(1) + sign(avgFastDirOffset(2)-avgFastDirOffset(1))*totalFast];
% avgSlowDirOffset = [avgSlowDirOffset, ...
%     avgSlowDirOffset(1) + sign(avgSlowDirOffset(2)-avgSlowDirOffset(1))*totalSlow];
stdFastDirOffset = std(fastDirOffset, 1);
stdSlowDirOffset = std(slowDirOffset, 1);

pFast = polyfit(1:N, avgFastDirOffset, 1);
pSlow = polyfit(1:N, avgSlowDirOffset, 1);

if fastAxis == 'V'
    pCol = pFast;
    pRow = pSlow;
elseif fastAxis == 'H'
    pCol = pSlow;
    pRow = pFast;
end

% % residuFast = 1 / 8 * (totalFast - abs(pFast(1) * 8));
% % residuSlow = 1 / 8 * (totalSlow - abs(pSlow(1) * 8));


fitLine = polyval(pFast, 1:N);
figure;
% errorbar(1:N, avgFastDirOffset, stdFastDirOffset, 'o');
plot(1:N, avgFastDirOffset, 'o', 'MarkerFaceColor', 'r');
hold on;
plot(1:N, fitLine, '-b');
title('Linear Fit to avgFastDirOffset');
xlabel('Index');
ylabel('Value');
legend('Original Data', 'Fitted Line');
hold off;

fitLine = polyval(pSlow, 1:N);
figure;
plot(1:N, avgSlowDirOffset, 'o', 'MarkerFaceColor', 'r');
hold on;
plot(1:N, fitLine, '-b');
title('Linear Fit to avgFastDirOffset');
xlabel('Index');
ylabel('Value');
legend('Original Data', 'Fitted Line');
hold off;

end