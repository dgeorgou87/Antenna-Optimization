function [InitFunction, CostFunction, FeasibleFunction] = Patch_1

InitFunction = @Patch1Init;
CostFunction = @Patch1Cost;
FeasibleFunction = @Patch1Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch1Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=34; %low W    d
lu(2,1)=83; %upper W  d
lu(1,2)=44; %low L    d
lu(2,2)=105;%upper L  d


lu(1,3)=0.14; %low Ls1   d
lu(2,3)=0.17; %upper Ls1 d
lu(1,4)=0.14; %low Ls2   d
lu(2,4)=0.17; %upper Ls2 d          
lu(1,5)=0.14; %low Ls3   d
lu(2,5)=0.17; %upper Ls3 d

lu(1,6)=0.28; %low Ws1   d
lu(2,6)=0.5; %upper Ws1  d
lu(1,7)=0.28; %low Ws2   d
lu(2,7)=0.5; %upper Ws2  d
lu(1,8)=0.28; %low Ws3   d
lu(2,8)=0.5; %upper Ws3  d

lu(1,9)=0.05; %low L1    d
lu(2,9)=0.15; %upper L1  d
lu(1,10)=0.05; %low L2   d
lu(2,10)=0.15; %upper L2 d
lu(1,11)=0.05; %low L3   d
lu(2,11)=0.15; %upper L3 d

lu(1,12)=0.1; %low W1    d
lu(2,12)=0.4; %upper W1  d
lu(1,13)=0.1; %low W2    d
lu(2,13)=0.4; %upper W2  d
lu(1,14)=0.1; %low W3    d
lu(2,14)=0.4; %upper W3  d

% lu(1,15)=0.2; %low Wsub
% lu(2,15)=0.4; %upper Wsub
% lu(1,16)=-0.9; %low Lsub
% lu(2,16)=0.9; %upper Lsub

lu(1,15)=0.2; %low yfeed    d
lu(2,15)=0.8; %upper yfeed  d
lu(1,16)=0.1; %low Wfeed    d
lu(2,16)=0.25; %upper Wfeed d

lu(1,17)=0.1;  %low Wground  d
lu(2,17)=1;    %upper Wground d

MinParValue = lu(1,:);
MaxParValue = lu(2,:);
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = MinParValue + (MaxParValue - MinParValue) .* rand(1,OPTIONS.numVar);
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = false;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Patch1Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_1_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

%p = OPTIONS.numVar;
for popindex = 1 : popsize
    Population(popindex).cost=0;
    Xi=1e10;
    limitdB=-18;
    Population(popindex).chrom=RoundNew(Population(popindex).chrom,2);
    
%     Lp=Population(popindex).chrom(1);
%     Wp=Population(popindex).chrom(2);
%     FeedWidth=Population(popindex).chrom(10)*(Wp/2);
%     xfeed=Population(popindex).chrom(11)*(Wp/2);
%     xfeedmax=(Wp/2)-(FeedWidth/2);
%     if abs(xfeed)>xfeedmax
%        xfeed=sign(xfeed)*xfeedmax/(Wp/2);
%     end
      
	Make_Patch_1(Population(popindex).chrom,fC,freqname) 
    [S11maxval,VSWRmaxval,AR,MinGain]=ReadHFSSOutput;
    if S11maxval>limitdB %dB
        Population(popindex).cost=Population(popindex).cost+Xi*abs(abs(limitdB)-abs(S11maxval));
    else
        Population(popindex).cost=S11maxval;
    end
    Population(popindex).S11maxval = S11maxval;
    Population(popindex).VSWRmaxval = VSWRmaxval;
%     Population(popindex).AR = AR;
%     Population(popindex).MinGain = MinGain;
    
    
	%fprintf(fid,'S11=%fdB VSWR=%f AR=%f MinGain=%f ',S11maxval,VSWRmaxval,AR,MinGain);
%     fprintf('S11=%fdB VSWR=%f AR=%f MinGain=%f ',S11maxval,VSWRmaxval,AR,MinGain);
    fprintf('S11=%fdB VSWR=%f ',S11maxval,VSWRmaxval);
    for k=1:length(Population(popindex).chrom)
        %fprintf(fid,'%f ',Population(popindex).chrom(k));
        fprintf('%f ',Population(popindex).chrom(k));
    end
    %fprintf(fid,'\n');
    fprintf('\n'); 
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Patch1Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;