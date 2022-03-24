function [InitFunction, CostFunction, FeasibleFunction] = Patch_10

InitFunction = @Patch10Init;
CostFunction = @Patch10Cost;
FeasibleFunction = @Patch10Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch10Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

% lu(1,1)=45; %low L    
% lu(2,1)=83; %upper L  
% lu(1,2)=2.6; %low W    
% lu(2,2)=2.9; %upper W 


lu(1,1)=33; %low Wb      d
lu(2,1)=83; %upper Wb   d

lu(1,11)=40; %low Yb      d    
lu(2,11)=110; %upper Yb    d 

lu(1,2)=0.1; %low r1      d
lu(2,2)=0.3; %upper r1    d  *leg
lu(1,3)=0.1; %low r2      d
lu(2,3)=0.3; %upper r2    d
lu(1,4)=0.1; %low r3      d
lu(2,4)=0.3; %upper r3    d
lu(1,5)=0.1; %low r4     d
lu(2,5)=0.3; %upper r4     d
lu(1,6)=0.1; %low r5    d
lu(2,6)=0.3; %upper r5   d
lu(1,7)=1.2; %low xf     d
lu(2,7)=3; %upper xf    d
lu(1,8)=0.4; %low yf     d   *L
lu(2,8)=0.65; %upper yf   d
lu(1,9)=0.1; %low r6    d
lu(2,9)=0.3; %upper r6   d
lu(1,10)=1.5; %low Wk    d
lu(2,10)=3.5; %upper Wk   d


MinParValue = lu(1,:);
MaxParValue = lu(2,:);
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = MinParValue + (MaxParValue - MinParValue) .* rand(1,OPTIONS.numVar)';
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = false;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Patch10Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_10_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

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
      
	Make_Patch_10(Population(popindex).chrom,fC,freqname) 
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
function [Population] = Patch10Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;