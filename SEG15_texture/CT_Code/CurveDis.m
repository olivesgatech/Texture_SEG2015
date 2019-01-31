function dis = CurveDis(img1, img2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CurveDis calculates the distance between two images based on their 
% squared chord distance of their curvelet coefficients. 
% It may be a good idea to review the defualt parameters for specific
% datasets.
% 
% The code requires MATLAB R20014b or newer to work. It also requires the
% curvelet toolbox (http://www.curvelet.org/software.html) to be installed.
%  
% Inputs: 
% - img1, img2 : two grayscale images of the same size.
%
% Output:
% - dis : distance between the two. Zero is identical.
%
% Code By: Yazeed Alaudah (alaudah@gatech.edu)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default Parameters:
%-----------------------------
normMethod = 'count' ; % normalization method of the histogram 
binMethod  = 'auto'; % bin method for the histogram
%-----------------------------

% Images must be double! 
img1 = double(img1);
img2 = double(img2);

if ( numel(size(img1))>2 || numel(size(img2))>2 )
    error('Images in CurveDis must by grayscale, i.e. only two dimensional');
end

if (size(img1,1) ~= size(img2,1) || size(img1,2) ~= size(img2,2))
    error('Image sizes in CurveDis.m must be the same');
end

[N1, N2] = size(img1);
numScales = ceil(log2( min(N1,N2)) - 3);
numOrient = ones(numScales,1); 

weights = ones(1,numScales);
if numScales >= 4 
    weights(numScales) = 0;
end
 
% indexing of number of scales starts from ZERO
for j = 1:numScales-2 % since 1st and last scales have only 1 'orientation'
    numOrient(j+1) = 16*2^(ceil((j-1)/2));
end

numOrient = round(numOrient/2); % since we only use half the spectrum if its real.

img1 = (img1 - mean2(img1)) ./ std2(img1);
img2 = (img2 - mean2(img2)) ./ std2(img2);

c1  = fdct_wrapping(img1,1);
c2  = fdct_wrapping(img2,1);

scaleDis = zeros(numScales,1);
for j = 1:numScales
    h1s = cell(numOrient(j),1);
    h2s = cell(numOrient(j),1);
    edges = cell(numOrient(j),1); 
    distOverOrients = zeros(numOrient(j),1);
    
    for k = 1:numOrient(j)
    [~,edges{k}] = histcounts(c1{j}{k}+c2{j}{k},'BinMethod', binMethod); 
    [h1s{k}] = histcounts(c1{j}{k},edges{k},'Normalization',normMethod);
    [h2s{k}] = histcounts(c2{j}{k},edges{k},'Normalization',normMethod);
    
    % squared chord distance
    distOverOrients(k) = sum((sqrt(h1s{k}) - sqrt(h2s{k})).^2);
    % KLD 
    %distOverOrients(k) = Compute_KLD(h1s{k},h2s{k},'js');
    end
    
    scaleDis(j) = sum(distOverOrients);
    
end

dis = weights*scaleDis;
end
