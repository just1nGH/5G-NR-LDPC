function decBits = nrldpc_decoder(iBG,Z_c,r,MaxItrs)
%------------------------------------------------------------------------
% This function implements nr ldpc decoder
% iBG: 1- base graph 1, 2: base graph 2
% Z_c: shifiting size
% r: message vector, length = (#rows(baseGraph))*Z_c
% MaxItrs: number of iterations
% decBits: decoded hard bits, length = (#cols(baseGraph)-#rows(baseGraph))* Z_c
% Juquan Mao 2021 Aug
% Ref : https://nptel.ac.in/courses/108/106/108106137/
%------------------------------------------------------------------------
    nMaxCols = 20;
    
    % Load 3GPP TS 38.212 Table 5.3.2-2/3: LDPC base graph
    [ldpcBGTable,nRows_B,nCols_B] = load_basegraph_table(iBG);
    iLS = find_set_index_lift_size(Z_c); 
    
    % Only keep necessary columns of the table 
    % #row #col BG vale
    % -------------------
    ldpcBGTable = ldpcBGTable(:,[1 2 iLS+3]);
    ldpcBGTable(:,3) = mod(ldpcBGTable(:,3),Z_c);
    
    % retrieve number of none(-1) elements in the base graph 
    [nRows,~] = size(ldpcBGTable);
    R = zeros(nRows,Z_c);
    tReg = zeros(Z_c, nMaxCols);
    L = r;
    itr = 0;
    while itr < MaxItrs
        
        iRow = 1;  
        iLayer = 1;
        nTReg = 0;

        while iRow <= nRows

            i = ldpcBGTable(iRow,1)+1;

            if (i == iLayer)

                % reduction
                j = ldpcBGTable(iRow,2)+1;
                pos = (j-1)*Z_c + (1:Z_c);
                L(pos) = L(pos) - R(iRow,:);

                % Registering
                nTReg = nTReg +1;
                tReg(:,nTReg) = circshift(L(pos), -ldpcBGTable(iRow,3));

                iRow = iRow + 1;
            else
                % row operation: minsum on treg
                tReg_hat = row_operation(tReg(:,1:nTReg));

                % column operation and L update
                for  iTreg = 1:nTReg 
                    curRow = iRow-nTReg + iTreg -1;
                    j = ldpcBGTable(curRow,2)+1;

                    % column operation
                    nShift = Z_c - ldpcBGTable(iRow,3);
                    R(curRow,:) =  circshift(tReg_hat(:,iTreg), -nShift);

                    % update L: addition
                    pos = (j-1)*Z_c + (1:Z_c);
                    L(pos) = L(pos) + R(curRow,:);

                end

                nTReg = 0;
                iLayer = iLayer +1;
            end

        end
        itr = itr + 1;
    end
    
    %decision
    K = (nCols_B - nRows_B) * Z_c;
    decBits = L(1:K) < 0; 
    
end

function tReg_hat = row_operation(tReg)

    [nRows,~] =size(tReg);

    for iRow = 1: nRows
        [min1,idx] = min(abs(tReg(iRow,:)));
        min2 = min(abs(tReg(iRow,[1:idx-1 idx+1:end]))); %second minimum
        S = sign(tReg(iRow,:));
        parity = prod(S);
        tReg(iRow,:) = min1; %absolute value for all
        tReg(iRow,idx) = min2; %absolute value for min1 position
        tReg(iRow,:) = parity*S.*tReg(iRow,:); %assign signs
    end

    tReg_hat = tReg;
end
