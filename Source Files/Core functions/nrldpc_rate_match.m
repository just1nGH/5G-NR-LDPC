function [bitsOut] = nrldpc_rate_match(ldpc_info,bitsIn, nBitsOut)

    Zc = ldpc_info.Zc;
    BGn = ldpc_info.BGn;
    K = ldpc_info.K;
    nFillers = ldpc_info.n_F;

    if BGn ==1 
        assert(length(bitsIn) == 68*Zc);
    else
        assert(length(bitsIn) == 52*Zc);
    end
    
    txBufferRing = bitsIn;
    
    % shortening = remove fillers bit
    fillerIdx=K-nFillers: K-1;
    txBufferRing(fillerIdx+1) = [];
    
    
    % puncturing
    % remove the first 2*Z
    txBufferRing(1:2*Zc) = [];
    nTxBufferRing = length(txBufferRing);
    bitsOut = zeros(nBitsOut,1);
    j = 0; i = 0;
    while j < nBitsOut
         bitsOut(j+1) = txBufferRing(mod(i,nTxBufferRing)+1);
         j = j+1; i = i+1;
    end


end

