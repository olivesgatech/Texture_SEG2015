function [decomp] = steer_pyr(img,level,or)
[pyr,pind]=buildSCFpyr(img,level,or-1);

decomp{1} = pyrBand(pyr, pind,1); 
c = 2; 
for i=2:1:size(pind,1)-1
decomp{c} = pyrBand(pyr, pind,i);
c = c+1; 
end

decomp{c} = pyrBand(pyr, pind,level*or+2); 

end