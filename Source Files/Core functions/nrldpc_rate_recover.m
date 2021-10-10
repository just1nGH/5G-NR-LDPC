function [softBitsOut] = nrldpc_rate_recover(ldpc_info,softBitsIn)

    Zc = ldpc_info.Zc;
    BGn = ldpc_info.BGn;
    K = ldpc_info.K;
    nFillers = ldpc_info.n_F;
    
    if BGn ==1 
        N = 68*Zc;
    else
        N = 52*Zc;
    end
    
    nRingBits = N-2*Zc -nFillers;
    rxBufferRing = zeros(nRingBits,1);
    
    % fill the ring
    i = 0; j = 0;
    
    while i < length(softBitsIn)     
        rxBufferRing(mod(i,nRingBits)+1) = rxBufferRing(mod(i,nRingBits)+1) + softBitsIn(j+1);
        i = i+1; j = j+1;
    end
    
    % Add fillers
    softBitsOut = zeros(N,1);
    softBitsOut([2*Zc+1:K-nFillers,K+1:end]) = rxBufferRing;
    softBitsOut(K-nFillers+1:K) = inf;
    
       
end

