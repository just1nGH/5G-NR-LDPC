function decBits = nrldpc_decoder(ldpc_info,softBitsIn,maxIters)
    
    % retrieve information from LDPC_INFO
    A =  ldpc_info.A;
    Zc = ldpc_info.Zc;
    BGn = ldpc_info.BGn;
    edges = ldpc_info.edges; nTotalEdges = size(edges,1);
    shifts = ldpc_info.shifts;
    layers = ldpc_info.layers; nLayers = size(layers,1);
    LLR = reshape(softBitsIn, Zc,[]);
    CtoVMsgs = zeros(Zc,nTotalEdges);
    if BGn ==1
        nEffLayers = ceil((ldpc_info.M +ldpc_info.n_F)/Zc) - 20;
    else
        nEffLayers = ceil((ldpc_info.M +ldpc_info.n_F)/Zc) - 8;
    end
    
    
    for iIter = 1: maxIters

        for iLayer = 1 : nEffLayers
            % locate the edges of the current layer
            startEdgeIdx =  layers(iLayer,1);
            nEdges = layers(iLayer,2);

            % message passing from variable nodes to the check node of the layer
            VtoCMsgs = zeros(Zc,nEdges);
            for iEdge = 1: nEdges
                
                edgeIdx = startEdgeIdx+iEdge;
                vNodeIdx = edges(edgeIdx,2)+1;
                msg = LLR(:,vNodeIdx)- CtoVMsgs(:,edgeIdx);
                VtoCMsgs(:,iEdge) = circshift(msg,-shifts(edgeIdx));
            end

            % message passing from the C node to the connected varaible nodes
            % min sum approimation: VtoCMsgs
            minSumMsgs = check_node_operation(VtoCMsgs);
            for iEdge = 1: nEdges
                
               edgeIdx = startEdgeIdx+iEdge;
               vNodeIdx = edges(edgeIdx,2)+1;
               
               oldMsg = CtoVMsgs(:,edgeIdx);
               newMsg= circshift(minSumMsgs(:,iEdge),-(Zc-shifts(edgeIdx)));
               CtoVMsgs(:,edgeIdx) = newMsg;
               LLR(:,vNodeIdx) = LLR(:,vNodeIdx)+ newMsg - oldMsg;
               
            end

        end
    end
  decBits = LLR(:)< 0;  
  decBits = decBits(1:A);
end


function msgOut = check_node_operation(msgIn)
    [Zc,~] = size(msgIn);
    msgOut = zeros(size(msgIn));
    for ZcIdx = 1: Zc
        
        % minimum
        [min1,min1_idx] = min(abs(msgIn(ZcIdx,:)));
        
        %second minimum
        min2 = min(abs(msgIn(ZcIdx,[1:min1_idx-1 min1_idx+1:end]))); 
        
        % sign
        S = 2*(msgIn(ZcIdx,:)>=0)-1;
        parity = prod(S);
        
        
        %offset min-sum Decoding
        min1 = max(min1-0.5,0);
        min2 = max(min2-0.5,0);
        
        % LLR update, min(abs()) approximation
        msgOut(ZcIdx,:) = min1; %absolute value for all
        msgOut(ZcIdx,min1_idx) = min2; %absolute value for min1 position
        
        %add sign
        msgOut(ZcIdx,:)= parity*S.*msgOut(ZcIdx,:); %assign signs, 
    end

end

