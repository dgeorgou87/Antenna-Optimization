function [OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction, RandSeed)

% Initialize population-based optimization software.

% WARNING: some of the optimization routines will not work if population size is odd.
OPTIONS.popsize = 25; % total population size
OPTIONS.Maxgen = 250; % generation count limit
OPTIONS.numVar = 17; % number of genes in each population member
OPTIONS.pmutate = 0.2; % mutation probability
OPTIONS.partition = 5/12;  % the percentage of population for MBO
OPTIONS.MaxFEs = 2E4; % number of Function Evaluations (FEs)

OPTIONS.n_coy=5;
OPTIONS.n_packs=20;
OPTIONS.popsize=OPTIONS.n_coy*OPTIONS.n_packs;

if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end
rand('state', RandSeed); % initialize random number generator
% if DisplayFlag
%     disp(['random # seed = ', num2str(RandSeed)]);
% end

% Get the addresses of the initialization, cost, and feasibility functions.
[InitFunction, CostFunction, FeasibleFunction] = ProblemFunction();
% Initialize the population.
[MaxParValue, MinParValue, Population, OPTIONS] = InitFunction(OPTIONS);
% Make sure the population does not have duplicates. 
Population = ClearDups(Population, MaxParValue, MinParValue);
% Compute cost of each individual  
Population = CostFunction(OPTIONS, Population);
% Sort the population from most fit to least fit
Population = PopSort(Population);
% Compute the average cost
AverageCost = ComputeAveCost(Population);
% Display info to screen
MinCost = [Population(1).cost];
AvgCost = [AverageCost];
if DisplayFlag
    disp(['The best and mean of Generation # 0 are ', num2str(MinCost(end)), ' and ', num2str(AvgCost(end))]);
end

return;