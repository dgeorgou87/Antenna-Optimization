function [InitFunction, CostFunction, FeasibleFunction] = Patch_6

InitFunction = @Patch6Init;
CostFunction = @Patch6Cost;
FeasibleFunction = @Patch6Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch6Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=59; %low W    d
lu(2,1)=83; %upper W  d
lu(1,2)=50; %low L    d
lu(2,2)=115;%upper L  d
lu(1,3)=0.2; %low Wg1   d 
lu(2,3)=0.5; %upper Wg1  d
lu(1,4)=0.15; %low Wg2  d
lu(2,4)=0.4; %upper Wg2  d
lu(1,5)=0.2; %low Lg   d 
lu(2,5)=0.35; %upper Lg  d
lu(1,6)=0.05; %low t1    d
lu(2,6)=0.15; %upper t1  d
lu(1,7)=0.05; %low t2   d 
lu(2,7)=0.15; %upper t2   d 
lu(1,8)=0.05; %low t3    d
lu(2,8)=0.13; %upper t3  d
lu(1,9)=0.05; %low t4    d
lu(2,9)=0.13; %upper t4 d
lu(1,10)=0.05; %low s1   d
lu(2,10)=0.09; %upper s1 d
lu(1,11)=0.06; %low s2   d
lu(2,11)=0.12; %upper s2 d
lu(1,12)=0.3; %low s3   d 
lu(2,12)=0.8; %upper s3 d 
lu(1,13)=0.03; %low Wf    d
lu(2,13)=0.08;%upper Wf d
lu(1,14)=0.1; %low Lf   d 
lu(2,14)=0.25; %upper Lf  d
lu(1,15)=0.01; %low Wf1   d
lu(2,15)=0.02; %upper Wf1 d
lu(1,16)=0.85; %low Lf1    d
lu(2,16)=0.95; %upper Lf1  d
lu(1,17)=0.1; %low W1    d
lu(2,17)=0.25; %upper W1  d
lu(1,18)=0.06; %low L1    d
lu(2,18)=0.1; %upper L1   d
lu(1,19)=0.1; %low W3    d
lu(2,19)=0.25; %upper W3 d
lu(1,20)=0.12; %low W2    d
lu(2,20)=0.2; %upper W2   d
lu(1,21)=0.13; %low L2   d
lu(2,21)=0.2; %upper L2  d
lu(1,22)=0.05; %low L3   d
lu(2,22)=0.095; %upper L3 d
lu(1,23)=0.12; %low L4    d
lu(2,23)=0.25; %upper L4     d
lu(1,24)=0.06; %low L5    d
lu(2,24)=0.13; %upper L5    d
lu(1,25)=0.2; %low L6    d
lu(2,25)=0.28; %upper L6  d
lu(1,26)=0.2; %low W4    d
lu(2,26)=0.34; %upper W4  d
lu(1,27)=0.025; %low W5   d
lu(2,27)=0.06; %upper W5  d
lu(1,28)=0.02; %low W6   d
lu(2,28)=0.05; %upper W6 d

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
function [Population] = Patch6Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_6_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

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
      
	Make_Patch_6(Population(popindex).chrom,fC,freqname) 
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
function [Population] = Patch6Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;