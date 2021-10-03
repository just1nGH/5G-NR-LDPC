
function iLS = find_set_index_lift_size(Zc)

    if (Zc < 2 || Zc >384)
        error("Zc  is not found! ");
    end

    liftSizeMtx = [2, 4, 8, 16, 32, 64, 128, 256;...
                    3, 6, 12, 24, 48, 96, 192, 384;...
                    5, 10, 20, 40, 80, 160, 320,0;...
                    7, 14, 28, 56, 112, 224,0,0;...
                    9, 18, 36, 72, 144, 288,0,0;...
                    11, 22, 44, 88, 176, 352,0,0;...
                    13, 26, 52, 104, 208,0,0,0;...
                    15, 30, 60, 120, 240,0,0,0];

    [nRows,nCols] = size(liftSizeMtx);

    iLS = -1;
    for i =1: nRows
        for j = 1:nCols
            if liftSizeMtx(i,j) == Zc
                iLS = i-1;
                break;
            end
        end
        if iLS ~= -1
            break;
        end
    end


    if (iLS == -1)
        error("Zc  is not found! ");
    end
end