function [InitFunction, CostFunction, FeasibleFunction] = Fletcher

InitFunction = @FletcherInit;
CostFunction = @FletcherCost;
FeasibleFunction = @FletcherFeasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = FletcherInit(OPTIONS)

global MinParValue MaxParValue a b alph A
Granularity = 0.1;
MinParValue = 1;
MaxParValue = floor(1 + 2 * pi / Granularity);
a = 200 * rand(OPTIONS.numVar,OPTIONS.numVar) - 100;
b = 200 * rand(OPTIONS.numVar,OPTIONS.numVar) - 100;
alph = 2 * pi * rand(OPTIONS.numVar,1) - pi;
A = zeros(OPTIONS.numVar, 1);
for i = 1 : OPTIONS.numVar
    for j = 1 : OPTIONS.numVar
        A(i) = A(i) + a(i,j) * sin(alph(j)) + b(i,j) * cos(alph(j));
    end
end
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = floor(MinParValue + (MaxParValue - MinParValue + 1) * rand(1,OPTIONS.numVar));
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = FletcherCost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue a b alph A
popsize = OPTIONS.popsize;
for popindex = 1 : popsize
    x = zeros(OPTIONS.numVar, 1);
    for j = 1 : OPTIONS.numVar
        gene = Population(popindex).chrom(j);
        x(j) = (gene - MinParValue) / (MaxParValue - MinParValue) * 2 * pi - pi;
    end
    B = zeros(OPTIONS.numVar, 1);
    for i = 1 : OPTIONS.numVar
        for j = 1 : OPTIONS.numVar
            B(i) = B(i) + a(i,j) * sin(x(j)) + b(i,j) * cos(x(j));
        end
    end
    Population(popindex).cost = 0;
    for i = 1 : OPTIONS.numVar
        Population(popindex).cost = Population(popindex).cost + (A(i) - B(i))^2;
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = FletcherFeasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue);
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue);
    end
end
return;