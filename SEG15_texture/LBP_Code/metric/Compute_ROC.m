function [True_Positive_Rate,False_Positive_Rate,Area_Under_Curve] = Compute_ROC(Dist_Mat,Class,Im_per_class)

% Dist_Mat: an N*N square distance matrix with all metric values for the
% dataset. The values must be in the range [0,1] with 0 being a perfect match. 
% Class: number of classes 
% Im_per_class: Number of images per class

Sim1 = ones(size(Dist_Mat)) - Dist_Mat;
Sim=Sim1;
N = (Class*Im_per_class); 
Sim(logical(eye(size(Sim))))=-1;
[values index]=sort(Sim,2,'descend');

ret=[];
nret=[];
for j=1:N,
    
    ret=[ret;values(j,1:Im_per_class-1)];
    nret=[nret;values(j,Im_per_class:end-1)];

end

 
Num_bins=0:1/(N-1):1;
Prob_ret=hist(ret(:),Num_bins);
Prob_nret=hist(nret(:),Num_bins);

Norm_Prob_ret = Prob_ret./sum(Prob_ret);
Norm_Prob_nret = Prob_nret/sum(Prob_nret); 

True_Positive_Rate = smooth(1-(cumsum(Norm_Prob_ret)));
False_Positive_Rate = smooth(1-(cumsum(Norm_Prob_nret)));


%AUC1=abs(trapz(False_Positive_Rate,True_Positive_Rate))
Area_Under_Curve = abs(sum(True_Positive_Rate.*[abs(diff(False_Positive_Rate));0])/(sum(diff(False_Positive_Rate))));
end