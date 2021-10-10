function cword = nrldpc_encoder(ldpc_info,msg)
%------------------------------------------------------------------------
% This function implements nr ldpc encoder
% ldpc_info a object of LDPC_INFO class, holds infomations that encoders
% needed.
% msg: column message vector
% cword: the encoded sequence
% Dr J Mao 2021 Oct justin.juquan.mao@surrey.ac.uk
%------------------------------------------------------------------------

    % retrieve info from LDPC_INFO
    BGn = ldpc_info.BGn;
    K = ldpc_info.K;
    Zc = ldpc_info.Zc;
    
    % edges are connection from check nodes to variable nodes
    edges = ldpc_info.edges;
    % shift coefficients for each edge
    shifts = ldpc_info.shifts;
    % one layer corresponding a row in exponent matrix, or all connections
    % to the check node of the row
    layers = ldpc_info.layers; nLayers = size(layers,1);
    
    if BGn ==1
        nSysNodes = 22;
        nCWordNodes = 68;
    else
        nSysNodes = 10;
        nCWordNodes = 52;
    end

    % check if the input message length is valid
    assert(length(msg) == nSysNodes * Zc);

    cword = zeros(nCWordNodes*Zc,1); cword(1:K) = msg;
    cword = reshape(cword,Zc,[]);% make every column corresponding a node with size Z,
   
    %[nEdges,~] = size(edges);
    
    %% double-diagonal encoding to solve first core parity node of Zc bits
    % iLayer is also the check node idx, sove each layer obatins a partiy
    % node of Z bits
    for iLayer = 1 : 4
        
        edgeStart = layers(iLayer,1);
        nEdges = layers(iLayer,2);
        
        for iEdge = 1: nEdges
            
            edgeIdx = edgeStart + iEdge;
            vNodeIdx = edges(edgeIdx,2)+1;
            nShift = shifts(edgeIdx); % shift coefficient
            
            if vNodeIdx <= nSysNodes % only message node counts
                cword(:,nSysNodes+1) = mod(cword(:,nSysNodes+1) + ...
                                circshift(cword(:,vNodeIdx),-nShift),2); % circshift is a function shift left with positive values
            end  
            
            
           % the shift coefficeint of the parity node 1 can be found either on the second or
           % third row of the exponent matrix
            if (vNodeIdx == nSysNodes + 1)
                if iLayer == 2 || iLayer == 3 % BGn ==1 -> cNodeIdx=2, BGn==2 --> cNodeIdx=3
                    shift_coeff = nShift;
                end
            end
           
        end
        
    end
    
    % shift back to find the bit values of parity node 1
    cword(:,nSysNodes+1) = circshift(cword(:,nSysNodes+1),-(Zc - shift_coeff)); 
    
    
    % The three rest core parity check nodes
    % iLayer == 1 ==> parity_node_2 iLayer == 2 ==> parity_node_3 iLayer == 3 ==> parity_node4
    % to solve parity_node_iLayer+1  i= 1,2,3 needs the knowlege of all message nodes and all
    % precious solved parity_nodes 1:iLayer
    for iLayer = 1 : 3
        
        edgeStart = layers(iLayer,1);
        nEdges = layers(iLayer,2);
        
        for iEdge = 1: nEdges
            
            edgeIdx = edgeStart + iEdge;
            vNodeIdx = edges(edgeIdx,2)+1;
            nShift = shifts(edgeIdx); % shift coefficient
            
           if vNodeIdx <= nSysNodes + iLayer
                  cword(:,nSysNodes+iLayer+1) = mod(cword(:,nSysNodes+iLayer+1)...
                                                + circshift(cword(:,vNodeIdx),-nShift),2);       
           end
           
        end
                  
    end 
    
   
    % The extensive parity nodes
    for iLayer = 5 : nLayers
        
        edgeStart = layers(iLayer,1);
        % not considering the last edge, which is th position of the parity to be caculated
        nEdges = layers(iLayer,2)-1; 
        
        for iEdge = 1: nEdges
            
            edgeIdx = edgeStart + iEdge;
            vNodeIdx = edges(edgeIdx,2)+1;
            nShift = shifts(edgeIdx); % shift coefficient
            
            cword(:,nSysNodes+iLayer) = mod(cword(:,nSysNodes+iLayer)...
                                        + circshift(cword(:,vNodeIdx),-nShift),2);       
        end
                  
    end 
    
    
    %cword = cword(:,3:end);
    cword = cword(:);

end

%% test script
% ldpc_info = LDPC_INFO(8000,2667);
% msg = randi([0,1],ldpc_info.K,1);
% cw = nrldpc_encoder_2(ldpc_info,msg);
% nrldpc_check_codeword(cw,ldpc_info.BGn,ldpc_info.Zc)