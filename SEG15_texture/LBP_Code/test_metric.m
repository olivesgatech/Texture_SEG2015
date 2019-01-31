% Calculate the metrics of image retrieval
addpath CLBP metric
load SIM_ri_3_24.mat

SIM = 10./(10+SIM);
classNum = 4;
imgNum = 100;
calcRA(SIM, imgNum);
calcPrec(SIM, imgNum);
calcMRR(SIM, imgNum);
[~, MRR, MAP, AUC]=calc_stats(SIM, classNum, imgNum, 0)