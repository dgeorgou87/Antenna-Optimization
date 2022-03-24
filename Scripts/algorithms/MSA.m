
%% Moth Search (MS) Algorithm
% Author: Gai-Ge Wang
% Email: gaigewang@gmail.com
%             gaigewang@163.com

% Main paper:
% Gai-Ge Wang, Moth search algorithm: a bio-inspired metaheuristic
% algorithm for global optimization problems.
% Memetic Computing.
% DOI: 10.1007/s12293-016-0212-3
% http://rd.springer.com/article/10.1007%2Fs12293-016-0212-3

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %%
%% Notes:
% Different run may generate different solutions, this is determined by
% the the nature of metaheuristic algorithms.
%%

function [MinCost] = MS(ProblemFunction, DisplayFlag, RandSeed)

% Moth Search (MS) Algorithm software for minimizing a general function
% The fixed generation is considered as termination condition.

% INPUTS: ProblemFunction is the handle of the function that returns
%         the handles of the initialization, cost, and feasibility functions.
%         DisplayFlag = true or false, whether or not to display and plot results.
%         ProbFlag = true or false, whether or not to use probabilities to update emigration rates.
%         RandSeed = random number seed
% OUTPUTS: MinCost = array of best solution, one element for each generation
%          Hamming = final Hamming distance between solutions
% CAVEAT: The "ClearDups" function that is called below replaces duplicates with randomly-generated
%         individuals, but it does not then recalculate the cost of the replaced individuals.

tic

if ~exist('ProblemFunction', 'var')
    ProblemFunction = @Ackley;
end
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end
if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

fclose('all');

outname=['MSA_',func2str(ProblemFunction),'_results.txt'];
fid=fopen(outname,'w');


[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction, RandSeed);

% % % % % % % % % % % %             Initial parameter setting          % % % % % % % % % % % %%%%
%% Initial parameter setting
Keep = 2; % elitism parameter: how many of the best moths to keep from one generation to the next
maxStepSize = 1.0;        %Max Step size
partition = OPTIONS.partition;
numMoth1 = ceil(partition*OPTIONS.popsize);  % NP1 in paper
numMoth2 = OPTIONS.popsize - numMoth1; % NP2 in paper
TempChone = zeros(1, OPTIONS.numVar);
goldenRatio = (sqrt(5)-1)/2; % you can change this Ratio so as to get much better performance
% % % % % % % % % % % %       End of Initial parameter setting       % % % % % % % % % % % %%
%%

% % % % % % % % % % % %             Begin the optimization loop        % % % % % % % % % %%%%
% Begin the optimization loop
for GenIndex = 1 : OPTIONS.Maxgen
    
    % % % % % % % % % % % %            Elitism Strategy           % % % % % % % % % % % %%%%%
    %% Save the best monarch butterflis in a temporary array.
    for j = 1 : Keep
        chromKeep(j,:) = Population(j).chrom;
        costKeep(j) = Population(j).cost;
    end
    % % % % % % % % % % % %       End of  Elitism Strategy      % % % % % % % % % % % %%%%
    %%
    
    % % % % % % % % % % % %%            L¨¦vy flights          %% % % % % % % % % % % % % %%%%
    %% Migration operator
    for k1 = 1 : numMoth1
        scale = maxStepSize/(GenIndex^2); %Smaller step for local walk
        delataX = LevyWalk(OPTIONS.numVar);
        Population(k1).chrom = Population(k1).chrom + scale*delataX;
    end  %% for k1
    % % % % % % % % % % % %%%       End of L¨¦vy flights      % % % % % % % % % % % %%%%%
    %%
    
    % % % % % % % % % % % %             Flying in a straingt line          % % % % % % % % % % % %%
    %% Flying in a straingt line
    for k2 = 1 : numMoth2
        for parnum = 1:OPTIONS.numVar
            if (rand >= 0.5)
                TempChone(parnum) = Population(k1+k2).chrom(parnum)...
                    + goldenRatio*(Population(1).chrom(parnum) - Population(k1+k2).chrom(parnum));
            else
                TempChone(parnum) = Population(k1+k2).chrom(parnum)...
                    + (1/goldenRatio)*(Population(1).chrom(parnum) - Population(k1+k2).chrom(parnum));
            end
        end  %% for parnum
        Population(k1+k2).chrom =  rand*TempChone;
    end %% for k2
    % % % % % % % % % % % %       End of  Flying in a straingt line      % % % % % % % % % % % %
    %%
    
    % % % % % % % % % % % %          Evaluate new Population       % % % % % % %  % % %%  % % 
    % Make sure each individual is legal.
    Population = FeasibleFunction(OPTIONS, Population);
    % Calculate cost
    Population = CostFunction(OPTIONS, Population);
    % Sort from best to worst
    Population = PopSort(Population);
    % % % % % %% % % % % %       End of Evaluate new Population   % %% % %% % % % %  % % 
    %%
    
    % % % % % % % % % % % %            Elitism Strategy          % % % % % % % % % % % %%% %% %
    %% Replace the worst with the previous generation's elites.
    n = length(Population);
    for k3 = 1 : Keep
        Population(n-k3+1).chrom = chromKeep(k3,:);
        Population(n-k3+1).cost = costKeep(k3);
    end % end for k3
    % % % % % % % % % % % %     End of  Elitism Strategy      % % % % % % % % % % % %%% %% %
    %%
    
    % % % % % % % % % %           Precess and output the results          % % % % % % % % % % % %%%
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
    
    % % % % % % % % % % %    End of Precess and output the results     %%%%%%%%%% %% %
    %%
    
end % end for GenIndex
Conclude(DisplayFlag, OPTIONS, Population, nLegal, MinCost);

toc

% % % % % % % % % %     End of Moth Search (MS) Algorithm implementation     %%%% %% %
%%
