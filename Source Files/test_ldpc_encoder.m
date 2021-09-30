%% test script
 liftSizeMtx = [2, 4, 8, 16, 32, 64, 128, 256;...
                    3, 6, 12, 24, 48, 96, 192, 384;...
                    5, 10, 20, 40, 80, 160, 320,0;...
                    7, 14, 28, 56, 112, 224,0,0;...
                    9, 18, 36, 72, 144, 288,0,0;...
                    11, 22, 44, 88, 176, 352,0,0;...
                    13, 26, 52, 104, 208,0,0,0;...
                    15, 30, 60, 120, 240,0,0,0];

 %liftSizeMtx = 10;
 [r,c] = size(liftSizeMtx);
 
 for i = 1:r
     for j = 1:c
         
         if liftSizeMtx(i,j)
            Z_c = liftSizeMtx(i,j);
            B = generate_base_graph(1,Z_c);
            [m,n] = size(B);
            msg = randi([0,1],1,(n-m)*Z_c);
            cw = nrldpc_encoder_2(B,Z_c,msg);
            cw2 = nrldpc_encoder_3(1,Z_c,msg);
            if (~checkcodeword(B,Z_c,cw))
                disp('error:');
                disp([1,Z_c]);
            end
            if (~checkcodeword(B,Z_c,cw2))
                disp('error:');
                disp([1,Z_c]);
            end
%             B = generate_base_graph(2,Z_c);
%             [m,n] = size(B);
%             msg = randi([0,1],1,(n-m)*Z_c);
%             cw = nrldpc_encoder_3(2,Z_c,msg);
%             if (~checkcodeword(B,Z_c,cw))
%                 disp('error:');
%                 disp([2,Z_c]);
%             end
         end
     end
 end

