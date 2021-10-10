function is_codeword = nrldpc_check_codeword(cw,BGn,Z)
    
    N = length(cw);

    % find set_idx  3GPP Table 5.3.2-1,
    load('lift_size_matrix.mat','lift_size_matrix');
    [m,n] = size(lift_size_matrix);
    set_idx = -1;
    for i =1:m
        for j = 1:n
            if lift_size_matrix(i,j) == Z
                set_idx = i-1;
                break;
            end
        end
    end

    if set_idx == -1
        error('Z is not a valid lift size');
    end

    % Load shift coeeficients of the exponent matrix
    % 3GPP TS 38.212 Table 5.3.2-2/3
    if BGn == 1
         n_cw_node_cols = 68;
         n_sys_node_cols = 22;
         assert(N == n_cw_node_cols*Z);
         load('shift_coeffs_bg_1.mat','shift_coeffs_bg_1');
         P_table = shift_coeffs_bg_1(:,[1 2 set_idx+3]);
    else
         n_cw_node_cols = 52;
         n_sys_node_cols = 10;
         assert(N == n_cw_node_cols*Z);
         load('shift_coeffs_bg_2.mat','shift_coeffs_bg_2');
         P_table = shift_coeffs_bg_2(:,[1 2 set_idx+3]);
    end

    %% checksum
    n_coeff = size(P_table);
    checksum = zeros(Z,(n_cw_node_cols-n_sys_node_cols));
    cw = cw(:);
    cw = reshape(cw,Z,[]);
    for i_coeff  = 1: n_coeff

        i = P_table(i_coeff,1) +1;
        j = P_table(i_coeff,2) +1;
        p_i_j = P_table(i_coeff,3);

        checksum(:,i) = mod(checksum(:,i)+...
                                    circshift(cw(:,j),-p_i_j),2);  
    end

    if any(checksum(:))
        is_codeword = false;
    else
        is_codeword = true;
    end


end

% Test script
% BGn = 1;
% Z =4;
% cw = randi([0,1],1,68*Z);
% nrldpc_check_codeword(cw,BGn,Z)

