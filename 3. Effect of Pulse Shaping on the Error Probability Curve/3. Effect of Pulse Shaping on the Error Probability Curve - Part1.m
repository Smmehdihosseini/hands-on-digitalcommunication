% 3. Effect of Pulse Shaping on the Error Probability Curve - Part1
% Author: Seyed Mohammad Mehdi Hosseini (Smmehdihosseini@gmail.com)

clear;%close all;clc;

num_bits=1000;
M=2; 
k=log2(M);
N=4;
db_snr=-30:30;
num_symbols = 8;
sam_per_sym = N;
beta_gauss = 0.3;
h_filter_guss = gaussdesign(beta_gauss,num_symbols,sam_per_sym);
beta_cosine=0.25;
h_filter_rrc = rcosdesign(beta_cosine,num_symbols,sam_per_sym);
ber_snr_guss=zeros(1,length(db_snr)); ber_snr_rrc=zeros(1,length(db_snr));

for iteration_snr=1:length(db_snr)
err_total_guss=0; err_total_rrc=0; iteration=0;
while iteration<1000
iteration=iteration+1;
bi=randi([0 1],1,num_bits);
symbols1=2*bi-1;
symbols=repmat(symbols1,N,1);
bpsk_symbol=reshape(symbols,[1,N*length(symbols1)]);
sym_hg1=conv(bpsk_symbol,h_filter_guss);
E_sym_hg1=(sym_hg1* sym_hg1')/length(sym_hg1);
bpsk_guss=sym_hg1./sqrt(E_sym_hg1);
symbol_rrc1=conv(bpsk_symbol,h_filter_rrc);
E_sym_rrc1=(symbol_rrc1* symbol_rrc1')/length(symbol_rrc1);
bpsk_rrc=symbol_rrc1./sqrt(E_sym_rrc1);
symbols_rect1=bpsk_symbol;
E_sym_rect1=sum(symbols_rect1.^2)/length(symbols_rect1);
bpsk_rect=symbols_rect1./sqrt(E_sym_rect1);
n0=(10^(-(db_snr(iteration_snr)/10)))*(k/N);
noise_guss=sqrt(n0)*randn(1,length(bpsk_guss));
noise_rrc=sqrt(n0)*randn(1,length(bpsk_rrc));
recx_guss=bpsk_guss+noise_guss;
recx_rrc =bpsk_rrc +noise_rrc ;
recx1_guss=conv(recx_guss,h_filter_guss);
half_dif_g=(length(recx1_guss)-length(bpsk_symbol))/2;
rx2_guss=recx1_guss(half_dif_g+1:( length(recx1_guss)-half_dif_g));
recx_guss=downsample(rx2_guss,N);
rx1_rrc=conv(recx_rrc,h_filter_rrc);
half_dif_rrc=(length(rx1_rrc)-length(bpsk_symbol))/2;
rx2_rrc=rx1_rrc(half_dif_rrc+1:( length(rx1_rrc)-half_dif_rrc));
recx_rrc=downsample(rx2_rrc,N);
bi_hat_guss=recx_guss>0;
num_err_guss=sum(xor(bi,bi_hat_guss));
err_total_guss=err_total_guss+num_err_guss;
bi_hat_rrc=recx_rrc>0;
num_err_rrc=sum(xor(bi,bi_hat_rrc));
err_total_rrc=err_total_rrc+num_err_rrc;
end
ber_snr_guss(iteration_snr)=err_total_guss/(iteration*num_bits);
ber_snr_rrc(iteration_snr)=err_total_rrc/(iteration*num_bits); 
end
semilogy(db_snr,ber_snr_guss,'g-*');hold on;grid on;
semilogy(db_snr,ber_snr_rrc,'b-o');hold on;grid on;
xlabel('SNR(dB)');
ylabel('BER');
title('Err for N=1');


