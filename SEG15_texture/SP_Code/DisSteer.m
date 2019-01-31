function [KLD SQD] = DisSteer(img1,img2)
%------------------------------------------%
% This Function claulcates the distiance between img1 and img2 by steerable
% pyramids band-to-band histogram comparison using two distance measures 
%(Kullback-Leibler divergence & squared chord). 
%
% % INPUT: 
% -img1: first image 
% -img2: second image 
% 
% % OUTPUT: 
% -KLD: Average Kullback-Leibler distance for all bands  
% -SQD: Average squared chord distance for all bands  
%-------------------------------------------%

level =  floor(log2(min(size(img1)))) - 2; 
or = 8; 
T1 = steer_pyr(img1,level,or);
T2 = steer_pyr(img2,level,or);
KLD = 0; 
SQD = 0; 
for i=1:length(T1)
    tmp = abs(T1{i}); 
    h1 = hist(tmp(:),10); 
    
    tmp = abs(T2{i}); 
    h2 = hist(tmp(:),10); 
    
    SQD = SQD+sqd(h1,h2); 
    KLD = KLD+Compute_KLD(h1,h2,'sym'); 
end 

SQD = SQD/length(T1); 
KLD = KLD/length(T1); 


end 