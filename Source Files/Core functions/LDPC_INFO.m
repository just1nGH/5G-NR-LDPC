classdef LDPC_INFO < handle
    %LDPC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        A; % informtion bit length
        M; % codeword length
        BGn; % base graph no
        Zc;  % shift size
        set_idx; % set index from 0-7
        K; % systemtic bits length in base graph 
        N;
        n_F; % number of fillers
        edges;  % shift connections from check nodes to variable nodes   
        shifts; % shifts for each correponding edge
        layers; %  each layer is defined by edges which  the corresponding check node and  varible nodes) 
                   %specified by start edge index and number of edges
    end
    
    methods
        
        function obj = LDPC_INFO(codeword_len,info_len)
                       
            obj.A = info_len;
            obj.M = codeword_len;
            % set obj.Gn;
            set_base_graph(obj);
            
            % obj.Zc & obj.set_idx
            set_lift_size(obj);
            
            % obj.K
            if obj.BGn == 1
                obj.K = obj.Zc * 22;
                obj.N = obj.Zc * 68;
            else
                obj.K = obj.Zc * 10;
                obj.N = obj.Zc * 52;
            end
            
            % obj.n_F
            obj. n_F = obj.K -obj.A;
            
            % obj.P_table
            load_shift_coeff_table(obj);
            
            %
            setup_layers(obj);
        end
        function obj = set_base_graph(obj)
            R = obj.A/obj.M;
              % determine base Graph 
            % 3GPP 38.212 7.2.2 LDPC base graph selection
            if( obj.A <= 292 || (obj.A <= 3824 && R <= 0.67) || obj.A <= 0.25)
                obj.BGn = 2;
                if(obj.A > 3840)
                    error('Segementation is not supported, info bitslength must be not larger than 8448 for BGn =2!');
                end
            else
                obj.BGn = 1;
                if (obj.A > 8448)
                    error('Segementation is not supported, info bitslength must be not larger than 3840 for BGn =2!');
                end
            end
  
        end
        function obj = set_lift_size(obj)
 
            %% determine kb 3GPP 38.212 section 5.2.2
            if obj.BGn == 1
                Kb = 22;
            else
                if  obj.A > 640
                    Kb = 10;
                elseif obj.A > 560
                    Kb = 9;
                elseif obj.A > 192
                    Kb = 8;
                else 
                    Kb = 6;
                end
            end
            
            %% determine lifting size Zc 3GPP Table 5.3.2-1,
            load('lift_size_matrix.mat','lift_size_matrix'); % obtain lift_matrix_size
            obj.Zc = max(max(lift_size_matrix)); 
            obj.set_idx = 0;
            [m,n] = size(lift_size_matrix);

            for i = 1:m
                for j = 1:n
                    candi_Z = lift_size_matrix(i,j);
                    if ( candi_Z*Kb == obj.A)
                        obj.Zc = candi_Z;
                        obj.set_idx = i-1;
                        break;
                    elseif (candi_Z * Kb > obj.A)
                        if candi_Z < obj.Zc
                            obj.Zc = candi_Z;
                            obj.set_idx = i-1;
                        end
                    end
                end
            end
        end
        function obj = load_shift_coeff_table(obj)
             % This function loads 3GPP TS 38.212 Table 5.3.2-2/3: LDPC base graph
             % The first two columns give the row and column index of the coeffcients in
             % the exponent parity matrx.
             % the 3rd -10th colums give the shift coefficeints to set index 0-7
             % respactively.

                 if obj.BGn == 1
                        load('shift_coeffs_bg_1.mat','shift_coeffs_bg_1');
                        P_table = shift_coeffs_bg_1(:,[1,2,obj.set_idx+3]);
                    elseif obj.BGn == 2
                        load('shift_coeffs_bg_2.mat','shift_coeffs_bg_2');
                        P_table = shift_coeffs_bg_2(:,[1,2,obj.set_idx+3]);
                    else
                        error('BaseGraph must be 1 or 2!')
                 end

                 %P_table = mod(P_table, obj.Zc);
                 obj.edges = P_table(:,[1 2]);
                 obj.shifts = mod(P_table(:,3),obj.Zc); 
        end
        function obj = setup_layers(obj)
            nEdges = size(obj.edges,1);
            
            % Setup Layers, each layer is defined 
             % by edges specified by start edge index and number of edges
             if obj.BGn ==1
                obj.layers = zeros(46,2); % 68 -22
             else
                obj.layers = zeros(42,2); % 52 - 10
             end
             jLayer = 0;
             iEdge = 0;
             while iEdge < nEdges

                obj.layers(jLayer+1,1) = iEdge;  
                obj.layers(jLayer+1,2) = 0;

                while obj.edges(iEdge+1) == jLayer
                    obj.layers(jLayer+1,2) = obj.layers(jLayer+1,2) +1;

                    iEdge = iEdge + 1;

                    if iEdge == nEdges
                        break;
                    end
                end

                jLayer = jLayer+1;

             end
        end
                   
    end
end

