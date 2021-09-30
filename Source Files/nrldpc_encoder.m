function cword = nrldpc_encoder(iBG,Z_c,msg)
%------------------------------------------------------------------------
% This function implements nr ldpc encoder
% iBG: 1- base graph 1, 2: base graph 2
% Z_c: shifiting size
% msg: message vector, length = (#cols(baseGraph)-#rows(baseGraph))*Z_c
% cword: codeword vector, length = #cols(baseGraph)* Z_c
% Juquan Mao 2021 Aug
% Ref : https://nptel.ac.in/courses/108/106/108106137/
% Note: This appoach doesn't create a matrix B of size (N-K)/Z_c by N/Z_c, instead, it
% just use those element of B with postive or zero values. In fact it
% directly use the table provided in 3GPP. save memory
%------------------------------------------------------------------------
 
    %Load 3GPP TS 38.212 Table 5.3.2-2/3: LDPC base graph
    [ldpcBGTable,nRows_B,nCols_B] = load_basegraph_table(iBG);
    iLS = find_set_index_lift_size(Z_c);
    
    % keep necessary columns; 
    % #row #col BG vale
    % -------------------
    ldpcBGTable = ldpcBGTable(:,[1 2 iLS+3]);
    ldpcBGTable(:,3) = mod(ldpcBGTable(:,3),Z_c);
    
    N = nCols_B * Z_c;
    nMsgCols_B = nCols_B - nRows_B;
    K = nMsgCols_B * Z_c;

    cword = zeros(1,N);
    cword(1:K) = msg;

    [nRows,~] = size(ldpcBaseGrphaTable);
    
    %% double-diagonal encoding
    for iRow = 1 : nRows
        
        i = ldpcBGTable(iRow,1)+1;
        j = ldpcBGTable(iRow,2)+1;
        
        if i > 4
            break;
        end
        
        if j <= nMsgCols_B 
            rows = K+(1:Z_c);
            cols = (j-1)*Z_c+ (1:Z_c);
            cword(rows) = mod(cword(rows) + ...
                            circshift(cword(cols),-ldpcBGTable(iRow,3)),2);
        end
        
        if (j == nMsgCols_B +1)
            if i == 2 || i == 3
                nShift_p1 = Z_c - ldpcBGTable(iRow,3);
            end
        end

    end

    % Find P1
    cword(rows) = circshift(cword(rows),-nShift_p1); %p1

    for iRow = 1 : nRows
        
        i = ldpcBGTable(iRow,1)+1;
        j = ldpcBGTable(iRow,2)+1;
        
        if i <= 3 % P2-P4  
            rows = K + i*Z_c +(1:Z_c);
            if j <= nMsgCols_B + i
                  cols = (j-1)*Z_c+ (1:Z_c);
                  cword(rows) = mod(cword(rows)...
                         + circshift(cword(cols),-ldpcBGTable(iRow,3)),2);       
            end
        elseif i >=5 % P5 onward
            rows = K + (i-1)*Z_c + (1:Z_c);
            if j <= nMsgCols_B + 4
                cols = (j-1)*Z_c + (1:Z_c);
                cword(rows) = mod(cword(rows)...
                          + circshift(cword(cols),-ldpcBGTable(iRow,3)),2);
            end
        end   
    end
   
end

%% test script
% Z_c =20;
% nBG = 1
% if nBG == 1
%  m = 46; n = 68;
% elseif nBG ==2
%   m = 42; n = 52;  
% end
% msg = randi([0,1],1,(n-m)*Z_c);
% cw = nrldpc_encoder(nBG,Z_c,msg);
% B = generate_base_graph(nBG,Z_c);
% checkcodeword(B,Z_c,cw)