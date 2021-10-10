function G = make_gen_matrix(H)
% https://stackoverflow.com/questions/43887951/how-to-determine-ldpc-generator-matrix-form-parity-check-matrix-802-16e

    m = size(H, 1);
    n = size(H, 2);
    k = n - m;
    
    A = H(1:m, 1:k);
    B = H(1:m, k+1:n);
    
    F = transpose(A) * inv(transpose(B)); 
   
    G = [eye(k),mod(F,2)];
   
end

