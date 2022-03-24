function [InitFunction, CostFunction, FeasibleFunction] = Patch_4

InitFunction = @Patch4Init;
CostFunction = @Patch4Cost;
FeasibleFunction = @Patch4Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch4Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=0.5; %low FeedS   d
lu(2,1)=3; %upper FeedS   d
lu(1,2)=1; %low FeedWidth    d
lu(2,2)=3.5; %upper FeedWidth   d
lu(1,3)=0.9; %low FeedLength     d
lu(2,3)=1.2; %upper FeedLength   d
lu(1,4)=15; %low PatchWidth    d
lu(2,4)=40; %upper PatchWidth     d 
lu(1,5)=3; %low PatchD    d
lu(2,5)=9; %upper PatchD   d
lu(1,6)=3; %low PatchBase      d
lu(2,6)=9; %upper PatchBase    d
% lu(1,7)=0.5; %low SlotWidth1      d   
% lu(2,7)=1.5; %upper SlotWidth1     d  
% lu(1,8)=0.5; %low SlotWidth2       d
% lu(2,8)=1.5; %upper SlotWidth2     d
% lu(1,9)=0.5; %low SlotWidth3     d
% lu(2,9)=1.5; %upper SlotWidth3    d
lu(1,7)=0.01; %low SlotWidth1      d   
lu(2,7)=0.15; %upper SlotWidth1     d  
lu(1,8)=0.01; %low SlotWidth2       d
lu(2,8)=0.15; %upper SlotWidth2     d
lu(1,9)=0.01; %low SlotWidth3     d
lu(2,9)=0.15; %upper SlotWidth3    d
lu(1,10)=0.02; %low Width1     d
lu(2,10)=0.15; %upper Width1  d
lu(1,11)=0.02; %low Width2    d
lu(2,11)=0.15; %upper Width2   d
lu(1,12)=0.02; %low Width3    d
lu(2,12)=0.15;%upper Width3   d


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
function [Population] = Patch4Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_4_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

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
      
	Make_Patch_4(Population(popindex).chrom,fC,freqname) 
    [S11maxval,VSWRmaxval]=ReadHFSSOutput;
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
function [Population] = Patch4Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;