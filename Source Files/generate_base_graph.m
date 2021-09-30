
function [baseGraph] = generate_base_graph(nBaseGraph,Zc)
%-------------------------------------------------------------------------
% This function generates LDPC base graph given base graph no (nBaseGraph) 
% and lifting size (Z_c)
% Author : Juquan Mao
% 2021 Aug
%-------------------------------------------------------------------------------------
    %Find set index based on Zc
    iLS = find_set_index_lift_size(Zc);

    %For LDPC base graph 1, a matrix of H BG has 46 rows with row indices 
    %i = 0,1, 2,..., 45 and 68 columns with column indices j = 0,1, 2,..., 67 . 
    %For LDPC base graph 2, a matrix of H BG has 42 rows with row indices 
    %i = 0,1,2,..., 41 and 52 columns with column indices j = 0,1,2,..., 51 .
    
    if nBaseGraph == 1
        nRowsBG = 46; nColsBG = 68;
        load('LDPC_BASE_GRAPH_1.mat');
    elseif nBaseGraph == 2
        nRowsBG = 42; nColsBG = 52;
        load('LDPC_BASE_GRAPH_2.mat');
    else
        error('BaseGraph must be 1 or 2!')
    end
    
    
    % Initiate naseGraph with all -1;
    baseGraph = -1 * ones(nRowsBG,nColsBG);

    % Loop all records in 3GPP 38.212 Table 5.3.2.2(3)
    [nRows,~] = size(ldpcBaseGrphaTable);
    for i = 1:nRows
      baseGraph(ldpcBaseGrphaTable(i,1)+1, ldpcBaseGrphaTable(i,2)+1) =...
                                        mod(ldpcBaseGrphaTable(i,iLS + 3),Zc);
    end

end

% Find set index based on Zc by looking up the table: 3GPP 38.212 Table 5.3.2.1 
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
