%___________________________________________________________________%
%  Grey Wold Optimizer (GWO) source codes version 1.0               %
%                                                                   %
%  Developed in MATLAB R2011b(7.13)                                 %
%                                                                   %
%  Author and programmer: Seyedali Mirjalili                        %
%                                                                   %
%         e-Mail: ali.mirjalili@gmail.com                           %
%                 seyedali.mirjalili@griffithuni.edu.au             %
%                                                                   %
%       Homepage: http://www.alimirjalili.com                       %
%                                                                   %
%   Main paper: S. Mirjalili, S. M. Mirjalili, A. Lewis             %
%               Grey Wolf Optimizer, Advances in Engineering        %
%               Software , in press,                                %
%               DOI: 10.1016/j.advengsoft.2013.12.007               %
%                                                                   %
%___________________________________________________________________%

% Grey Wolf Optimizer
%function [Alpha_score,Alpha_pos,Convergence_curve]=GWO(SearchAgents_no,Max_iter,lb,ub,OPTIONS.numVar,fobj)
function [MinCost] = GWO(ProblemFunction, DisplayFlag, ProbFlag, RandSeed)

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

outname=['GWO_',func2str(ProblemFunction),'_results.txt'];
fid=fopen(outname,'w');


[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction, RandSeed);

Population = CostFunction(OPTIONS, Population);

% initialize alpha, beta, and delta_pos
Alpha_pos=zeros(1,OPTIONS.numVar);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(1,OPTIONS.numVar);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(1,OPTIONS.numVar);
Delta_score=inf; %change this to -inf for maximization problems

%Initialize the positions of search agents
%Positions=initialization(SearchAgents_no,OPTIONS.numVar,ub,lb);

%Convergence_curve=zeros(1,Max_iter);

%GenIndex=0;% Loop counter

% Main loop
%while GenIndex<OPTIONS.Maxgen
for GenIndex = 1 : OPTIONS.Maxgen
    %for i=1:size(Positions,1)  
     for i=1:size(Population,2)
        
       % Return back the search agents that go beyond the boundaries of the search space
        %Flag4ub=Positions(i,:)>ub;
        %Flag4lb=Positions(i,:)<lb;
        %Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               
        
        % Calculate objective function for each search agent
        %fitness=fobj(Positions(i,:));
        fitness=Population(i).cost;
        
        % Update Alpha, Beta, and Delta
        if fitness<Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=Population(i).chrom;
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Population(i).chrom;
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Population(i).chrom;
        end
    end
    
    
    a=2-GenIndex*((2)/OPTIONS.Maxgen); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=1:OPTIONS.popsize
        for j=1:OPTIONS.numVar  
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Population(i).chrom(j)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Population(i).chrom(j)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Population(i).chrom(j)); % Equation (3.5)-part 3
            X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3             
            
            Population(i).chrom(j)=(X1+X2+X3)/3;% Equation (3.7)
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Make sure each individual is legal.
    Population = FeasibleFunction(OPTIONS, Population);
    % Calculate cost
    Population = CostFunction(OPTIONS, Population);
    % Sort from best to worst
    Population = PopSort(Population);
    % Replace the worst with the previous generation's elites.
    %n = length(Population);
    % Make sure the population does not have duplicates. 
    Population = ClearDups(Population, MaxParValue, MinParValue);
    % Sort from best to worst
    Population = PopSort(Population);
    % Compute the average cost
    [AverageCost, nLegal] = ComputeAveCost(Population);
    % Display info to screen
    MinCost = [MinCost Population(1).cost];
    AvgCost = [AvgCost AverageCost];
    if DisplayFlag
        disp(['The best and mean of Generation # ', num2str(GenIndex), ' are ',...
            num2str(MinCost(end)), ' and ', num2str(AvgCost(end))]);
    end
    
        fprintf(fid,'The best and mean of Generation %d are %f and %f.', GenIndex,...
            MinCost(end), AvgCost(end));
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
    
    %%%%%%%%%%%%%%%
    
    %GenIndex=GenIndex+1;    
    Convergence_curve(GenIndex)=Alpha_score;
end

Conclude(DisplayFlag, OPTIONS, Population, nLegal, MinCost); 

return;


