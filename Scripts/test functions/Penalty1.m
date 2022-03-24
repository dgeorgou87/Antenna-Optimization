function [InitFunction, CostFunction, FeasibleFunction] = Penalty1

InitFunction = @Penalty1Init;
CostFunction = @Penalty1Cost;
FeasibleFunction = @Penalty1Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Penalty1Init(OPTIONS)

global MinParValue MaxParValue
Granularity = 0.1;
MinParValue = 1;
MaxParValue = floor(1 + 2 * 50 / Granularity);
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = floor(MinParValue + (MaxParValue - MinParValue + 1) * rand(1,OPTIONS.numVar));
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Penalty1Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
for popindex = 1 : OPTIONS.popsize
    Population(popindex).cost = 0;
    for i = 1 : OPTIONS.numVar
        gene = Population(popindex).chrom(i);
        x = (gene - MinParValue) / (MaxParValue - MinParValue) * 2 * 50 - 50;
        y(i) = 1 + (x + 1) / 4;
        if (x > 10)
            u = 100 * (x - 10)^4;
        elseif (x < -10)
            u = 100 * (-x - 10)^4;
        else
            u = 0;
        end
        Population(popindex).cost = Population(popindex).cost + u;
    end
    Population(popindex).cost = Population(popindex).cost + (10 * (sin(pi*y(1)))^2 + (y(OPTIONS.numVar) - 1)^2) * pi / 30;
    for i = 1 : OPTIONS.numVar-1
        Population(popindex).cost = Population(popindex).cost + ((y(i) - 1)^2 * (1 + 10 * (sin(pi*y(i+1)))^2)) * pi / 30;
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Penalty1Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue);
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue);
    end
end
return;