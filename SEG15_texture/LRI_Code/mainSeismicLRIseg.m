% Date: 21 March, 2015
% -------------------------------------------------------------------------
% The main program for seismic image retrieval 
% -------------------------------------------------------------------------
 clc; clear all; close all

tic
LRI_Total=[];

load Seismic400.mat
K=3;


for im=1:400
    disp(['Image #  = ',num2str(im)]); 
    input=Seismic400(im,:,:);
    input=reshape(input,150,300);
    
%     normalizig 
    mi=min(input(:));
    ma=max(input(:));
    input=(input-mi)/(ma-mi);
    
     LRI_im = LRI(input,K);
     LRI_Total=[LRI_Total;LRI_im];

end

save(['LRI_SEG400_' num2str(K) '.mat'],'LRI_Total');
total_time=toc