function [H,E_H] = make_parity_check_matrix(n_BG,Zc)
% [Ref] Nguyen, Tram Thi Bao, Tuy Nguyen Tan, and Hanho Lee. 
%  "Efficient QC-LDPC encoder for 5G new radio." Electronics 8.6 (2019): 668.


    set_Idx = find_set_index_lift_size(Zc);
    
    
    %3GPP 38.212 Table 5.3.2.2(3)
    if n_BG == 1
        n_rows_bg = 46; n_cols_bg = 68;
        load('shift_coeffs_bg_1.mat','shift_coeffs_bg_1');
        shift_coeffs_table = shift_coeffs_bg_1;
    else
        n_rows_bg = 42; n_cols_bg = 52;
        load('shift_coeffs_bg_2.mat','shift_coeffs_bg_2');
        shift_coeffs_table = shift_coeffs_bg_2;
    end
    
    
    %exponent matrix
    E_H  = -1 * ones(n_rows_bg,n_cols_bg);
    H = zeros(n_rows_bg*Z, n_cols_bg*Z);
     
    % Loop all records in 
    [n_rows_exp_mtx,~] = size(shift_coeffs_table);
    for i = 1:n_rows_exp_mtx 
      % row index and column index in exponent matrix
      row_idx =   shift_coeffs_table(i,1)+1;
      col_idx =   shift_coeffs_table(i,2)+1;
      
      % The corresponding shift V
      shift_coeff = shift_coeffs_table(i,set_Idx + 3);
      
      % Exponet matrix
      E_H(row_idx,col_idx) = mod(shift_coeff,Z);
      
      % check matrix
      H(Z*(row_idx-1)+(1:Z), Z*(col_idx-1)+(1:Z)) = circshift(eye(Z),-mod(shift_coeff,Z));
      
    end


          
end

