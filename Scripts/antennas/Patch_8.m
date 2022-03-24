function [InitFunction, CostFunction, FeasibleFunction] = Patch_8

InitFunction = @Patch8Init;
CostFunction = @Patch8Cost;
FeasibleFunction = @Patch8Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch8Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=20; %low Wpatch    d
lu(2,1)=105; %upper Wpatch  d
lu(1,2)=2.6; %low Wsub2    d   *Wpatch 
lu(2,2)=2.9; %upper Wsub2   d
lu(1,3)=1.1; %low Wsub1      d
lu(2,3)=1.35; %upper Wsub1   d  *Wsub2
lu(1,4)=0.45; %low SL      d  *Wpatch
lu(2,4)=0.68; %upper SL    d
lu(1,5)=0.22; %low SW      d     *SL
lu(2,5)=0.30; %upper SW    d
lu(1,6)=0.2; %low G      d
lu(2,6)=0.4; %upper G    d    *SL
lu(1,7)=0.09; %low Tc       d   *Wpatch
lu(2,7)=0.13; %upper Tc     d
lu(1,8)=0.6; %low L1    d
lu(2,8)=0.85; %upper L1   d    *Wsub2
lu(1,9)=0.5; %low W1     d
lu(2,9)=0.9; %upper W1    d
lu(1,10)=0.2; %low L2     d  
lu(2,10)=0.55; %upper L2  d   *SW
lu(1,11)=0.15; %low W2    d   *SW
lu(2,11)=0.3; %upper W2   d
lu(1,12)=0.3; %low R    d
lu(2,12)=0.36;%upper R   d
lu(1,13)=0.03; %low Wfeed     d     *Wsub2
lu(2,13)=0.09; %upper Wfeed     d


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
function [Population] = Patch8Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_8_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

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
      
	Make_Patch_8(Population(popindex).chrom,fC,freqname) 
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
function [Population] = Patch8Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;