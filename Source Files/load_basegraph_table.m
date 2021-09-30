function [ldpcBGTable,nRows_B,nCols_B] = load_basegraph_table(iBG)
 % This function oad 3GPP TS 38.212 Table 5.3.2-2/3: LDPC base graph
    if iBG == 1
        nRows_B = 46; nCols_B = 68;
        load('LDPC_BASE_GRAPH_1.mat');
    elseif iBG == 2
        nRows_B = 42; nCols_B = 52;
        load('LDPC_BASE_GRAPH_2.mat');
    else
        error('BaseGraph must be 1 or 2!')
    end
    ldpcBGTable = ldpcBaseGrphaTable;

end

