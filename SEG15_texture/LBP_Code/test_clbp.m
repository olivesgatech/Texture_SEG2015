% Calculate the similarity matrix (SIM)

addpath CLBP metric
load('Seismic400.mat');
num = 400;
SIM = zeros(400);

% Different mapping strategies
type = cell(1,3);
type(1) = {'u2'};
type(2) = {'ri'};
type(3) = {'riu2'};

% Various combinations of radius and the number of sampling points
radSample=zeros(9,2);
radSample(1,:) = [1, 8];
radSample(2,:) = [2, 8];
radSample(3,:) = [2, 12];
radSample(4,:) = [2, 16];
radSample(5,:) = [3, 8];
radSample(6,:) = [3, 12];
radSample(7,:) = [3, 16];
radSample(8,:) = [3, 20];
radSample(9,:) = [3, 24];
% Here, we calculate similarity matrices with all possible combination of
% m and n

% We can also obtain only one similarity matrix with specified m and n
for m = 1:length(type)
    for n = 1:length(radSample)
        mapping=getmapping(radSample(n,2),type(m));
        for i = 1:400
            img1 = double(squeeze(Seismic400(i,:,:)));

            [CLBP_SH1,CLBP_MH1,~]=clbp(img1,radSample(n,1),radSample(n,2),mapping,'h'); %CLBP histogram in (8,1) neighborhood
                                                         %using uniform patterns
            hist1 = [CLBP_SH1, CLBP_MH1];

            for j = 1:400
                img2 = double(squeeze(Seismic400(j,:,:)));
                [CLBP_SH2,CLBP_MH2,~]=clbp(img2,radSample(n,1),radSample(n,2),mapping,'h'); %CLBP histogram in (8,1) neighborhood
                                                         %using uniform patterns
                hist2 = [CLBP_SH2, CLBP_MH2];
                SIM(i,j) = sqd(hist1, hist2);  
            end
            fprintf('%d image has been finished!\n', i);
        end
        save(strcat('SIM_', char(type(m)),'_',num2str(radSample(n,1)),'_',num2str(radSample(n,2)),'.mat'), 'SIM');
    end
end