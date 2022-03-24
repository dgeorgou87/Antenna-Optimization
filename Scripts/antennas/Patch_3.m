function [InitFunction, CostFunction, FeasibleFunction] = Patch_3

InitFunction = @Patch3Init;
CostFunction = @Patch3Cost;
FeasibleFunction = @Patch3Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Patch3Init(OPTIONS)

global MinParValue MaxParValue
%Granularity = 0.1;

lu(1,1)=34; %low W     
lu(2,1)=83; %upper W   
lu(1,2)=44; %low L    
lu(2,2)=105;%upper L   


lu(1,3)=0.05; %low Ls1          
lu(2,3)=0.5; %upper Ls1         
lu(1,4)=0.05; %low Ls2          
lu(2,4)=0.5; %upper Ls2        
%lu(1,5)=0.05; %low Ls3          
%lu(2,5)=0.3; %upper Ls3         

lu(1,5)=0.1; %low Ws1           
lu(2,5)=0.2; %upper Ws1         
lu(1,6)=0.1; %low Ws2           
lu(2,6)=0.2; %upper Ws2         
lu(1,7)=0.1; %low Ws3           
lu(2,7)=0.5; %upper Ws3        

lu(1,8)=0.1; %low W3
lu(2,8)=0.45; %upper W3
lu(1,9)=0.1; %low L1           
lu(2,9)=0.2; %upper L1          
lu(1,10)=0.1; %low L2          
lu(2,10)=0.2; %upper L2         
lu(1,11)=0.05; %low L3          
lu(2,11)=0.07; %upper L3        

lu(1,12)=0.1;      %low xfeed       
lu(2,12)=0.8;       %upper xfeed    
lu(1,13)=0.1;      %low Wfeed       
lu(2,13)=0.2;      %upper Wfeed   

lu(1,14)=0.1;   %low Lground     
lu(2,14)=1;     %upper Lground   


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
function [Population] = Patch3Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
popsize = OPTIONS.popsize;
fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_3_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];

%p = OPTIONS.numVar;
for popindex = 1 : popsize
    Population(popindex).cost=0;
    Xi=1e10;
    limitdB=-10;
    Population(popindex).chrom=RoundNew(Population(popindex).chrom,2);
    
%     Lp=Population(popindex).chrom(1);
%     Wp=Population(popindex).chrom(2);
%     FeedWidth=Population(popindex).chrom(10)*(Wp/2);
%     xfeed=Population(popindex).chrom(11)*(Wp/2);
%     xfeedmax=(Wp/2)-(FeedWidth/2);
%     if abs(xfeed)>xfeedmax
%        xfeed=sign(xfeed)*xfeedmax/(Wp/2);
%     end
      
	Make_Patch_3(Population(popindex).chrom,fC,freqname) 
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
function [Population] = Patch3Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue(k));
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue(k));
    end
end
return;