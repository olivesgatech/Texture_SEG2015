function MRR = calcMRR(SIM, imgPerClass)
% This function returns the mean reciprocal value of a similarity matrix.
%
% Inputs:
% 1- sim: an NxN matrix, where N is the number of images in the database. 
%   the (i,j)th element in sim corresponds to the similarity between images i
%   and j. The images should be ordered by class. I.e. the first <imgPerClass> rows
%   and columns should belong to class 1, and so on.. 
% 	The values should be between 0 and 1, with 1 being identical.
% 2- imgPerClass is the number of images in each class
% 
% For any bugs: Yazeed Alaudah (alaudah@gatech.edu)

numImages = length(SIM);
numClasses = numImages/imgPerClass;
mrri = zeros(numImages,1);

for i = 1:numImages 
    SIM(i,i) = 0; % take away the image itself
    [~,idxs] = sort(SIM(i,:),'descend');
    
    rank = 1;
    relevVector = zeros(1,numClasses);
    relevVector(floor((i-1)/imgPerClass)+1)=1;
    relevVector = kron(relevVector, ones(1,imgPerClass));
    while relevVector(idxs(rank)) ~= 1
        rank = rank+1; 
    end
    mrri(i) = 1/rank;
end

   
mrr = mean(mrri);
disp(['MRR = ', num2str(mrr)]);