 clc; close all;clear all

MaxK=3;
Hist_size=(MaxK*2+1);
selc=1:Hist_size*8;
Features_LRIA=[];
load ('LRI_SEG400_3.mat');

Features_LRIA=LRI_Total;

tic
[Rows,Cols] = size(Features_LRIA);
distance_kld = zeros(Rows,Rows);
distance_sqd = zeros(Rows,Rows);

for i=1:Rows
     H1 = Features_LRIA(i,:) ./sum(Features_LRIA(i,:));
    for j=1:Rows
             H2 = Features_LRIA(j,:) ./sum(Features_LRIA(j,:));
            d11 = sum(H1.*log2((H1+eps)./(H2+eps)));
            d22 = sum(H2.*log2((H2+eps)./(H1+eps)));
            distance_kld(i,j) = (d11+d22)/2;
            distance_sqd(i,j) = sum((sqrt(H1(:)) - sqrt(H2(:))).^2);     
    end   
end
toc

C = 4; 
imagePerClass = size(distance_kld,1)/C;
% normalize kld distances
maxD  = max(distance_kld);
normMatrix = repmat(maxD',[1 size(Features_LRIA,1)]);
distance_kld_norm = distance_kld ./ normMatrix;
distance_kld_norm = ones(size(distance_kld)) - distance_kld_norm;

[PAn_KLD, MRR_KLD, MAP_KLD, AUC_KLD] = calc_stats(distance_kld_norm,C,imagePerClass);

% normalize sqd distances
maxD  = max(distance_sqd);
normMatrix = repmat(maxD',[1 size(Features_LRIA,1)]);
distance_sqd_norm = distance_sqd ./ normMatrix;
distance_sqd_norm = ones(size(distance_sqd)) - distance_sqd_norm;


[Precision,a]=Compute_P_at_N1(distance_kld_norm,C,imagePerClass);




RA_KLD=calcRA(distance_kld_norm,imagePerClass);



[PAn_SQD, MRR_SQD, MAP_SQD, AUC_SQD] = calc_stats(distance_sqd_norm,C,imagePerClass);
RA_SQD=calcRA(distance_sqd_norm,imagePerClass);

disp('===========KLD Precission==============');

 for k=1:imagePerClass-1%K-1
 disp(['Precison @',num2str(k),' = ',num2str(Precision(k),'%0.4f')]); 
 end 


disp('============================================ RESULT============================================');
disp(['Mean Average Precison (MAP) KLD = ',num2str(MAP_KLD,'%0.5f') '   SQD = ',num2str(MAP_SQD,'%0.5f')]); 
disp(['Mean Reciprocal Rank  (MRR) KLD = ',num2str(MRR_KLD,'%0.5f') '   SQD = ',num2str(MRR_SQD,'%0.5f')]); 
disp(['Retrieval Accuracy    (RA)  KLD = ',num2str(RA_KLD,'%0.5f') '    SQD = ',num2str(RA_SQD,'%0.5f')]);
disp(['Area under ROC        (AUC) KLD = ',num2str(AUC_KLD,'%0.5f') '   SQD = ',num2str(AUC_SQD,'%0.5f')]); 

close all;
