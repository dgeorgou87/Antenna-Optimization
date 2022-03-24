% The codes for this function have been taken from: 
% For details, see Pages 14-16 of the following book:
% Xin-She Yang, Nature-Inspired metaheuristic algorithms (Second Edition)
% Luniver Press, Frome, 2010.

%% Moth Search (MS) Algorithm
% Author: Gai-Ge Wang
% Email: gaigewang@163.com
%             gaigewang@gmail.com

% Main paper:
% Gai-Ge Wang, and Leandro dos Santos Coelho, Moth search algorithm: a bio-inspired metaheuristic
% algorithm for global optimization problems.
% ********, submitted.
% DOI: *****
%%

function delataX=LevyWalk(d)

beta = 1.5;
%Eq. (2.23)
sigma=(gamma(1+beta)*sin(pi*(beta-1)/2)/(gamma((beta)/2)*(beta-1)*2^((beta-2)/2)))^(1/(beta-1));
u=randn(1,d)*sigma;
v=randn(1,d);
step=u./abs(v).^(1/(beta-1)); %Eq. (2.21)

delataX=0.01*step;
