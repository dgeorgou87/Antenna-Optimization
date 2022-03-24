function [InitFunction, CostFunction, FeasibleFunction] = Patch_7

InitFunction = @Patch7Init;
CostFunction = @Patch7Cost;
FeasibleFunction = @Patch7Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch7Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=45; %low W    d
lu(2,1)=83; %upper W  d
lu(1,2)=50; %low L    d
lu(2,2)=115;%upper L  d
lu(1,3)=2.7; %low Sw   d
lu(2,3)=2.9; %upper Sw  d
lu(1,4)=2.7; %low Sl  d
lu(2,4)=2.9; %upper Sl  d
lu(1,5)=0.1; %low Se    d
lu(2,5)=0.35; %upper Se  d
lu(1,6)=0.01; %low Lw    d
lu(2,6)=0.03; %upper Lw  d
lu(1,7)=0.05; %low g1    d
lu(2,7)=0.15; %upper g1   d 
lu(1,8)=0.05; %low g2    d
lu(2,8)=0.15; %upper g2  d
lu(1,9)=0.3; %low a    d
lu(2,9)=0.43; %upper a  d
lu(1,10)=0.19; %low b   d
lu(2,10)=0.33; %upper b  d
lu(1,11)=0.09; %low c   d
lu(2,11)=0.18; %upper c  d
lu(1,12)=0.15; %low d    d
lu(2,12)=0.28; %upper d  d
lu(1,13)=0.12; %low e    d
lu(2,13)=0.25;%upper e  d
lu(1,14)=0.12; %low f    d
lu(2,14)=0.25; %upper f  d
lu(1,15)=0.06; %low j   d
lu(2,15)=0.14; %upper j d
lu(1,16)=0.008; %low m    d
lu(2,16)=0.015; %upper m  d


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
function [Population] = Patch7Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_7_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

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
      
	Make_Patch_7(Population(popindex).chrom,fC,freqname) 
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
function [Population] = Patch7Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;