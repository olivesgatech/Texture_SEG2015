function test_clbp(inImg,outFile,option)
%% Test salt dome detection using LBP/CLBP in curvelet domain

%% Load data
%imgc=imread('..\\..\\data\\SaltDomeImages\\3.jpg');
imgc=imread(inImg);
img=double(rgb2gray(imgc));
[Nr,Nc]=size(img);
%figure; imshow(img,[]);

% Apply curvelet transform
C=fdct_wrapping(img,1,1,4,8);
Ns=length(C);
%option=1; % 0: noCLBP; 1: CLBP_SH; 2: CLBP_MH; 3: CLBP_SH/MH
if option==0
    C_H=cell(1,Ns); 
else
    CLBP_SH=cell(1,Ns);
    CLBP_MH=cell(1,Ns);
    CLBP_SMH=cell(1,Ns);
end
    
%% Process subbands at each scale %%% coarest not included %%%
for j=2:Ns
    % Add directional subbands together (to avoid too many feature vectors)
    tmp=zeros(Nr,Nc,'single');
    for i=1:0.5*length(C{j}) %%% temporarily half subbands %%%
        tmp=tmp+imresize(C{j}{i},[Nr,Nc]); 
    end
    
    if option==0
        R=0; % To share the same histogram code with CLBP
        tmp=(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:)))*255; % Map to 0-255
    else
        % CLBP parameters
        P=8; %8*2^(Ns-j+1); % Neighborhood (P=32 uses too much memory)
        R=1;%2^(Ns-j); % Radius
        patternMappingriu2=getmapping(P,'ri'); % Rotation invariant (u2/ri/riu2)

        % Generate CLBP features
        tmp=(tmp-mean(tmp(:)))/std(tmp(:)); % Normalize to remove global intensity
        [CLBP_S,CLBP_M,CLBP_C]=clbp(tmp,R,P,patternMappingriu2,'x');
        %CLBP_S=lbp_new(tmp,R,P,patternMappingriu2,'x');
    end
    
    % Generate histograms
    xVec=7:16:255;%15:32:255; % 8 bins
    histSize=length(xVec);
    if option==0
        tmp_H=zeros(Nr,Nc,histSize,'single');
    else
        tmp_SH=zeros(Nr-2*R,Nc-2*R,histSize,'single');
        tmp_MH=zeros(Nr-2*R,Nc-2*R,histSize,'single');
        tmp_SMH=zeros(Nr-2*R,Nc-2*R,histSize*2,'single');
    end
    hwsz=4*2^(Ns-j); % Half size of the sliding window (smallest: 9x9=81)
    for rr=1:Nr-2*R % CLBP_S/M/C is of smaller size
        for cc=1:Nc-2*R
            rs=rr-hwsz; if rs<1, rs=1; end
            re=rr+hwsz; if re>(Nr-2*R), re=Nr-2*R; end
            if rs==1, re=rs+hwsz*2; end
            if re==Nr-2*R, rs=re-hwsz*2; end
            cs=cc-hwsz; if cs<1, cs=1; end
            ce=cc+hwsz; if ce>(Nc-2*R), ce=Nc-2*R; end
            if cs==1, ce=cs+hwsz*2; end
            if ce==Nc-2*R, cs=ce-hwsz*2; end
            if option==0
                tmpM=tmp(rs:re,cs:ce);
                tmp_H(rr,cc,:)=hist(tmpM(:),xVec)/length(tmpM(:));
            else
                tmpM=CLBP_S(rs:re,cs:ce);
                tmpHist=hist(tmpM(:),xVec)/length(tmpM(:));
                tmp_SH(rr,cc,:)=tmpHist;
                tmp_SMH(rr,cc,1:histSize)=tmpHist;
                
                tmpM=CLBP_M(rs:re,cs:ce);
                tmpHist=hist(tmpM(:),xVec)/length(tmpM(:));
                tmp_MH(rr,cc,:)=tmpHist;
                tmp_SMH(rr,cc,histSize+1:histSize*2)=tmpHist;
            end
        end
    end
    
    if option==0
        C_H{j}=tmp_H;
        clear tmp tmp_H;
    else
        CLBP_SH{j}=tmp_SH;
        CLBP_MH{j}=tmp_MH;
        CLBP_SMH{j}=tmp_SMH;
        clear tmp tmp_SH temp_MH;
    end
end

%% Segmentation via kmeans clustering, combining all scales
% Form data matrix
R=1;%2^(Ns-2); % pick the largest R if varies
if option==0
    R=0;
end
NXr=(Nr-2*R)*(Nc-2*R);

featureSize=histSize;
if option==3
    featureSize=histSize*2;
end
X=zeros(NXr,featureSize*(Ns-1),'single');

for j=2:Ns
    if option==0
        tmp=C_H{j};
    elseif option==1
        tmp=CLBP_SH{j};
    elseif option==2
        tmp=CLBP_MH{j};
    elseif option==3
        tmp=CLBP_SMH{j};
    end
    
    for rr=1:Nr-2*R
        for cc=1:Nc-2*R
            X((rr-1)*(Nc-2*R)+cc,(j-2)*featureSize+1:(j-1)*featureSize)=tmp(rr,cc,:);
        end
    end
end

% Perform k-means clustering %%% may need distance measure like chi-square %%%
nCluster=2;
[IDX,C,sumd,D]=kmeans(X,nCluster,'distance','correlation');
clear X;

% Show results
map=zeros(Nr,Nc);
for rr=1:Nr-2*R
    for cc=1:Nc-2*R
        map(rr+R,cc+R)=IDX((rr-1)*(Nc-2*R)+cc)*255.0/nCluster;
    end
end
%figure; imshow(map,[]);
save(outFile,'map');
clear map;

%% Segmentation via kmeans clustering (scale by scale only)
if 0 % below is only for exploration purpose

nCluster=2;
for j=2:Ns
    % Form data matrix
    R=1;%2^(Ns-j);
    if option==0
        R=0;
        tmp=C_H{j};
    elseif option==1
        tmp=CLBP_SH{j};
    elseif option==2
        tmp=CLBP_MH{j};
    elseif option==3
        tmp=CLBP_SMH{j};
    end
    
    NXr=(Nr-2*R)*(Nc-2*R);
    if option==3
        X=zeros(NXr,histSize*2,'single');
    else
        X=zeros(NXr,histSize,'single');
    end
    for rr=1:Nr-2*R
        for cc=1:Nc-2*R
            X((rr-1)*(Nc-2*R)+cc,:)=tmp(rr,cc,:);
        end
    end

    % Perform k-means clustering %%% may need distance measure like chi-square %%%
    [IDX,C,sumd,D]=kmeans(X,nCluster,'distance','correlation');
    clear X;

    % Show results
    map=zeros(Nr,Nc);
    for rr=1:Nr-2*R
        for cc=1:Nc-2*R
            map(rr+R,cc+R)=IDX((rr-1)*(Nc-2*R)+cc)*255.0/nCluster;
        end
    end
    figure; imshow(map,[]);
    clear map;
end

end

%% Further refinement of boundary, maybe using irregular neighborhood

%% End of program