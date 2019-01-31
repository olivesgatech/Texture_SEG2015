function [PAn, MRR, MAP, AUC] = calc_stats(MX,C,K,flag)
%% Statistics Calculations 
% This function calculates different statistics for a given similarity metric 
% It will calculate the following: 
% 1- PAn: Pricision at n, where k = 1,2,... K-1; 
% 2- MAR: Mean reciprocal rank
% 3- MAP: Mean average precision
% 4- Values distribution (PDF)  
% 5- Recriver Operating Characterstics (ROC) plot 
% 9- Areas under ROC curves (AUC)


%INPUT: 
% MX: an C*K-by-C*K similarity matrix with all metric values for the
%     dataset. The values must be in the range [0,1] with 1 being a perfect match.
% C: number of classes 
% K: Number of images per class
% flag: if flag=1 (Default), the ROC&PDF plots will displayed. else it will not display the plots  

% NOTE: The matrix MX must have the similiarity index for every pair of images in the
% dataset ordered according to their classes, i.e. the first K rows of MX
% must be the results of comparing all images of class 1 with all images in
% the database. Every row of the matrix have all similarity metric values
% for that image with respect to all other images in the database. 

%OUTPUT:
% PAn: A vector of length (K-1), that has P@n n=1,2,...K-1
% MRR: Mean Reciprocal Rank 
% MAP: Mean Average Precision 
% AUC: Area under the curve 


% BY: MOTAZ AL FARRAJ 
% Email: motaz@gatech.edu

%% Validating inputs 

if nargin<3 
    error('Please provide all 3 inputs, i.e. clac_statistics(MX,N,K)'); 
end 
 
if nargin<4
    flag = 1;
end 

if size(MX,1)~=C*K || size(MX,2)~=C*K
    error('The matrix MX must be sqaure with size [N*K x N*K]'); 
    
end 
if max(MX(:))>1 || min(MX(:))<0 
    error('All metric values must be in the range 0~1'); 
end 


%% MRR,MAP,PA results  
relev = zeros(C*K,K-1); %this vector will contain all simialr images values  
nonrelev=zeros(C*K,(C-1)*K); %this vector will contain all non-simialr images values

rank_A = zeros(C*K,K-1);  %Ranks of correct images for each query image 

PA = zeros(C*K,1); 
RR = zeros(C*K,1);
AP = zeros(C*K,1);
PAn = zeros(1,K-1); 

for i=1:C*K
        A = MX(i,:); %one row of similarity matrix
        
        ok_ind = [1:K]+floor((i-1)/K)*K; %relevant images indecies 
        ok_ind(mod(i-1,K)+1) = [];% excluding the image itself in the retreival 
        A(i) = -inf; % excluding the image itself in the retreival 
        
        [sort_val, sort_ind] = sort(A,'descend'); %Sorting the results according to their metric value 
        
        
        % Finding the for all relevant images  
        for j=1:K-1
        rank_A(i,j) = find(sort_ind==ok_ind(j)); %rank of the i-th relevant image 
        end
        rank_A(i,:) = sort(rank_A(i,:));
        
        %Calculting precision 
        for k=1:K-1
        PA(i,k) = isscalar(find(ok_ind==sort_ind(k)));%Precision vector
        end 
        
        
        RR(i) = 1./rank_A(i,1); %Reciprocal rank 
        AP(i) = mean([1:K-1]./rank_A(i,:)); %Average precision 
        
        
        %collecting results of the similar and dissimilar values 
        relev(i,:)= sort_val(rank_A(i,:)); %relevant image 
        sort_val(rank_A(i,:))=[];
        nonrelev(i,:)=sort_val(1:end-1);  %non-relevant image 

end

%Averaging 
    for i=1:K-1
    PAn(i) = mean2(PA(:,1:i));
    end 
    
    MAP = mean(AP);
    MRR = mean(RR);



%% PDF for metric values 
np = (C*K); %number of PDF points 

%Plotting PDF 
x_axis = linspace(min(MX(:)),1,np); 
[val1, ind1]=hist(relev(:),x_axis);
[val2, ind2]=hist(nonrelev(:),x_axis);
val1 = val1/sum(val1);
val2 = val2/sum(val2); 


if flag ==1
    figure
    plot(ind1,val1,'Linewidth',2); 
    hold on
    plot(ind2,val2,'r','Linewidth',1)
    hold off
    axis tight
    title('Metric values distribution'); 
    legend('identical textures','non-identical textures'); 
    xlabel('Metric values') 
end 
%% Receiver operating characteristic
TPR = sort((1-cumsum(val1)));
FPR = sort((1-cumsum(val2)));
AUC = sum(0.5*(TPR(1:end-1)+TPR(2:end)).*abs(diff(FPR)))/(sum(abs(diff(FPR)))); 

if flag == 1
    figure
    plot(smooth(FPR),smooth(TPR),'LineWidth',2); 
    axis tight
    xlabel('False Positive Rate'); 
    ylabel('True Positive Rate'); 
    title('Receiver operating characteristic curve'); 
    axis([0 1 0 1]); 
end 



end 


