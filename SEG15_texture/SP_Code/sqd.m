function result = sqd(hist1, hist2)
% calculates squared chord distance between 2 histograms
result = sum((sqrt(hist1) - sqrt(hist2)).^2);
