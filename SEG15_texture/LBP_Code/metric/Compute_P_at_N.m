function [Precision] = Compute_P_at_N(Dist_Mat,Class,Im_per_class)

% Dist_Mat: an N*N square distance matrix with all metric values for the
% dataset. The values must be in the range [0,1] with 0 being a perfect match. 
% Class: number of classes 
% Im_per_class: Number of images per class


Dist_Mat(logical(eye(size(Dist_Mat))))=inf;
[values index]=sort(Dist_Mat,2);
for i=2:Class,
    index((i-1)*Im_per_class+1:i*Im_per_class,:)=index((i-1)*Im_per_class+1:i*Im_per_class,:)-(i-1)*Im_per_class;
end

for i=1:Im_per_class-1;
    a=index(:,1:i);
    p(i) = 0;
    for j=1:Im_per_class*Class,   
    p(i)=p(i)+floor(length(find(a(j,i)>=0 & a(j,i)<=Im_per_class)));    
    end
    
    Precision(i)=p(i)/(Im_per_class*Class);
end
end