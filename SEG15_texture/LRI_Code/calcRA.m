function RA = calcRA(sim, imgPerClass)
% This function caclculates Retreival Accuracy (i.e. the % of correctly
% retreived images.
% Inputs:
% 1- sim: an NxN matrix, where N is the number of images in the database. 
%   the (i,j)th element in sim corresponds to the similarity between images i
%   and j
% 2- imgPerClass is the number of images in each class
% 
% For any bugs: Yazeed Alaudah (alaudah@gatech.edu)
% sim = distance_sqd_norm;
numImages = length(sim);
% imgPerClass = 1000;
numClasses = numImages/imgPerClass;
binaryResults = zeros(numImages, numImages);
for i = 1:numImages
    [~,idxs] = sort(sim(i,:),'descend');
    for j = 1:imgPerClass
        binaryResults(i, idxs(j)) = 1;
    end
end

% construct a binary mask
mask = kron(diag(ones(numClasses,1),0), ones(imgPerClass,imgPerClass));
mask = mask - diag(ones(numImages,1),0);

% binary multiplication
correctlyClassified = sum(sum(mask.*binaryResults));
totalNumber = (imgPerClass-1)*numImages;
classRate = (correctlyClassified/totalNumber)*100;
RA=classRate;
% disp(['RA = ', num2str(classRate), '%']);