README FILE for SEG2015 submission: CurveDis code

CurveDis.m calculate the squared chord distance between the curvelet wedges of two different images. 
The value returned is a distance value, (i.e. from 0 onwards) with zero distance indicating identical images. 

In order to convert this to a similarity value [0-1], any monotonically decreasing function that outputs 1 with a zero input will work (for the sake of running the other codes calcMRR.m ..etc)

For example: 
SIM = 1./ (1 + DIS); 


Please read the comments inside each file for dependences and other details. 