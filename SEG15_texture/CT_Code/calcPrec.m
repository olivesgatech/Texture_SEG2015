function calcPrec(sim, imgPerClass)
% This function caclculates Precision values for P@1, P@20, and P@50
% Inputs:
% 1- sim: an NxN matrix, where N is the number of images in the database.
%   the (i,j)th element in sim corresponds to the similarity between images i
%   and j
% 2- imgPerClass is the number of images in each class
%
% For any bugs: Yazeed Alaudah (alaudah@gatech.edu)

numImages = length(sim);
numClasses = numImages/imgPerClass;

 pa1Result = zeros(numImages, numImages);
 pa20Result = zeros(numImages, numImages);
 pa50Result = zeros(numImages, numImages);

for i = 1:numImages
    [~,idxs] = sort(sim(i,:),'descend');
    pa1Result(i,idxs(2)) = 1;
    for j = 1:imgPerClass
        if j <= 20
            pa20Result(i, idxs(j+1)) = 1;
        end
        if j <= 50
            pa50Result(i, idxs(j+1)) = 1;
        end
    end
end


% construct a binary mask
mask = kron(diag(ones(numClasses,1),0), ones(imgPerClass,imgPerClass));
mask = mask - diag(ones(numImages,1),0);

% calculate results
pa1 = sum(sum(mask.*pa1Result))/numImages;
pa20 = sum(sum(mask.*pa20Result))/(20*numImages);
pa50 = sum(sum(mask.*pa50Result))/(50*numImages);

% display results
disp(['P@1 = ', num2str(pa1)]);
disp(['P@20 = ', num2str(pa20)]);
disp(['P@50 = ', num2str(pa50)]);
