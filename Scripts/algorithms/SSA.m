%_________________________________________________________________________________
%  Salp Swarm Algorithm (SSA) source codes version 1.0
%
%  Developed in MATLAB R2016a
%
%  Author and programmer: Seyedali Mirjalili
%
%         e-Mail: ali.mirjalili@gmail.com
%                 seyedali.mirjalili@griffithuni.edu.au
%
%       Homepage: http://www.alimirjalili.com
%
%   Main paper:
%   S. Mirjalili, A.H. Gandomi, S.Z. Mirjalili, S. Saremi, H. Faris, S.M. Mirjalili,
%   Salp Swarm Algorithm: A bio-inspired optimizer for engineering design problems
%   Advances in Engineering Software
%   DOI: http://dx.doi.org/10.1016/j.advengsoft.2017.07.002
%____________________________________________________________________________________

function [MinCost] = SSA(ProblemFunction, DisplayFlag, ProbFlag, RandSeed)

if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end
if ~exist('ProbFlag', 'var')
    ProbFlag = false;
end
if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

fclose('all');

outname=['SSA_',func2str(ProblemFunction),'_results.txt'];
fid=fopen(outname,'w');

[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction, RandSeed);

Population = CostFunction(OPTIONS, Population);


%Initialize the positions of salps
%SalpPositions=initialization(N,dim,ub,lb);


%Position=zeros(1,OPTIONS.numVar);
%fitness=inf;


%calculate the fitness of initial salps

for i=1:OPTIONS.popsize
    %SalpFitness(1,i)=fobj(SalpPositions(i,:));
    SalpPositions(i,:)=Population(i).chrom;
    SalpFitness(1,i)=Population(i).cost;
end

[sorted_salps_fitness,sorted_indexes]=sort(SalpFitness);

for newindex=1:OPTIONS.popsize
    Sorted_salps(newindex,:)=SalpPositions(sorted_indexes(newindex),:);
end

Position=Sorted_salps(1,:);
fitness=sorted_salps_fitness(1);

%Main loop
%l=2; % start from the second iteration since the first iteration was dedicated to calculating the fitness of salps
for GenIndex = 1 : OPTIONS.Maxgen
    
    c1 = 2*exp(-(4*GenIndex/OPTIONS.Maxgen)^2); % Eq. (3.2) in the paper
    
    for i=1:OPTIONS.popsize
        
        SalpPositions= SalpPositions';
        
        if i<=OPTIONS.popsize/2
            for j=1:1:OPTIONS.numVar
                c2=rand();
                c3=rand();
                %%%%%%%%%%%%% % Eq. (3.1) in the paper %%%%%%%%%%%%%%
                if isscalar(MaxParValue)==1
                    if c3<0.5 
                        SalpPositions(j,i)=Position(j)+c1*((MaxParValue-MinParValue)*c2+MinParValue);
                    else
                        SalpPositions(j,i)=Position(j)-c1*((MaxParValue-MinParValue)*c2+MinParValue);
                    end
                else
                    if c3<0.5 
                        SalpPositions(j,i)=Position(j)+c1*((MaxParValue(j)-MinParValue(j))*c2+MinParValue(j));
                    else
                        SalpPositions(j,i)=Position(j)-c1*((MaxParValue(j)-MinParValue(j))*c2+MinParValue(j));
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            
        elseif i>OPTIONS.popsize/2 && i<OPTIONS.popsize+1
            point1=SalpPositions(:,i-1);
            point2=SalpPositions(:,i);
            
            SalpPositions(:,i)=(point2+point1)/2; % % Eq. (3.4) in the paper
        end
        
        SalpPositions= SalpPositions';
    end
    
    for i=1:size(SalpPositions,1)
        
        Tp=SalpPositions(i,:)>MaxParValue;
        Tm=SalpPositions(i,:)<MinParValue;
        SalpPositions(i,:)=(SalpPositions(i,:).*(~(Tp+Tm)))+MaxParValue.*Tp+MinParValue.*Tm;
        
        temp=OPTIONS.popsize;
        OPTIONS.popsize=1;
        Population(i).chrom=SalpPositions(i,:);
        Population(i) = CostFunction(OPTIONS, Population(i));
        OPTIONS.popsize=temp;
        %SalpFitness(1,i)=fobj(SalpPositions(i,:));
        SalpFitness(1,i)=Population(i).cost;
        if SalpFitness(1,i)<fitness
            Position=SalpPositions(i,:);
            fitness=SalpFitness(1,i);
        end
            MinCost=[MinCost fitness];
            Population(i).chrom=SalpPositions(i,:);
            Population(i).cost=SalpFitness(1,i);         
    end
    
    Population = PopSort(Population);
    
    if DisplayFlag
        disp(['The best of Generation # ', num2str(GenIndex), ' is ',...
        num2str(MinCost(end))]);
    end
    
    fprintf(fid,'The best of Generation %d is %f and %f.', GenIndex,...
        MinCost(end));
    if isfield(Population,'S11maxval')
        fprintf(fid,'S11maxval=%f ,',Population(1).S11maxval);
        fprintf(fid,'VSWRmaxval=%f ,',Population(1).VSWRmaxval);
        fprintf(fid,'AR=%f ,',Population(1).AR);
        fprintf(fid,'MinGain=%f ,',Population(1).MinGain);
    end
         
	fprintf(fid,' Best chrom is: ');
    for i = 1 : OPTIONS.numVar
        fprintf(fid,'%f, ',Population(1).chrom(i));
    end
    fprintf(fid,'\n');
    
    %Convergence_curve(l)=fitness;
end



