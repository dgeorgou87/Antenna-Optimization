function [InitFunction, CostFunction, FeasibleFunction] = Penalty2

InitFunction = @Penalty2Init;
CostFunction = @Penalty2Cost;
FeasibleFunction = @Penalty2Feasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = Penalty2Init(OPTIONS)

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
function [Population] = Penalty2Cost(OPTIONS, Population)

% Compute the cost of each member in Population

global MinParValue MaxParValue
for popindex = 1 : OPTIONS.popsize
    Population(popindex).cost = 0;
    for i = 1 : OPTIONS.numVar
        gene = Population(popindex).chrom(i);
        x(i) = (gene - MinParValue) / (MaxParValue - MinParValue) * 2 * 50 - 50;
        if (x(i) > 5)
            u = 100 * (x(i) - 5)^4;
        elseif (x(i) < -5)
            u = 100 * (-x(i) - 5)^4;
        else
            u = 0;
        end
        Population(popindex).cost = Population(popindex).cost + u;
    end
    Population(popindex).cost = Population(popindex).cost + 0.1 * ((sin(pi*3*x(1)))^2 + (x(OPTIONS.numVar) - 1)^2 * (1 + (sin(2*pi*x(OPTIONS.numVar)))^2));
    for i = 1 : OPTIONS.numVar-1
        Population(popindex).cost = Population(popindex).cost + 0.1 * ((x(i) - 1)^2 * (1 + (sin(3*pi*x(i+1)))^2));
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Penalty2Feasible(OPTIONS, Population)

global MinParValue MaxParValue
for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue);
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue);
    end
end
return;