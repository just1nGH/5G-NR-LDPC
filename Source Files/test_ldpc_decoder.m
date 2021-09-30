EbNodB = 4;
MaxItrs = 8;

iBG = 1;
Z_c = 10;

if iBG == 1
    nRows_B = 46; nCols_B = 68;
    load('LDPC_BASE_GRAPH_1.mat');
elseif iBG == 2
    nRows_B = 42; nCols_B = 52;
    load('LDPC_BASE_GRAPH_2.mat');
else
    error('BaseGraph must be 1 or 2!')
end

N = nCols_B * Z_c;
nMsgCols_B = nCols_B - nRows_B;
K = nMsgCols_B * Z_c;

Rate = K/N;  
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*Rate*EbNo));

Nbiterrs = 0; Nblkerrs = 0; Nblocks = 100; 
for i = 1: Nblocks
	%msg = randi([0 1],1,k); %generate random k-bit message
    msg = zeros(1,K); %all-zero message
	
    %Encoding 
	cword = zeros(1,N); %all-zero codeword
             
    s = 1 - 2 * cword; %BPSK bit to symbol conversion 
    r = s + sigma * randn(1,N); %AWGN channel I
    
    msg_cap = nrldpc_decoder_3(iBG,Z_c,r,MaxItrs);
    
    %Counting errors
    Nerrs = sum(msg ~= msg_cap);
    if Nerrs > 0
		Nbiterrs = Nbiterrs + Nerrs;
		Nblkerrs = Nblkerrs + 1;
    end
end

BER_sim = Nbiterrs/K/Nblocks;
FER_sim = Nblkerrs/Nblocks;

sim_res.EbNodB = EbNodB;
sim_res.bler = FER_sim;
sim_res.Nblkerrs = Nblkerrs;
sim_res.Nblocks = Nblocks;
sim_res.ber = BER_sim;
sim_res.Nbiterrs = Nbiterrs;
sim_res.Nbits = Nblocks*K;


disp('  ');
disp('  Simulation Results');
disp('----------------------');
disp(sim_res);


