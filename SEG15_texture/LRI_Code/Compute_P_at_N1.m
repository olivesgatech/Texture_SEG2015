function [Precision,a] = Compute_P_at_N1(Dist_Mat,Class,Im_per_class)

% Dist_Mat: an N*N square distance matrix with all metric values for the
% dataset. The values must be in the range [0,1] with 0 being a perfect match. 
% Class: number of classes 
% Im_per_class: Number of images per class


Dist_Mat(logical(eye(size(Dist_Mat))))=-inf;
[values index]=sort(Dist_Mat,2,'descend');
for i=2:Class,
    index((i-1)*Im_per_class+1:i*Im_per_class,:)=index((i-1)*Im_per_class+1:i*Im_per_class,:)-(i-1)*Im_per_class;
end

for i=1:Im_per_class-1;
    
     a=index(:,1:i); % Upto Nth Index
%      a=index(:,i); % Nth Index
    
    p(i) = 0;  
    p(i)=p(i)+floor(length(find(a>0 & a<=Im_per_class)));    

    
    Precision(i)=p(i)/length(a(:));
end
a=index;
end