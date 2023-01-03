% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       3XM | Particle set (x,y,weight for each particle)
% Outputs:
%           S(t):           3XM | Particle set (x,y,weight for each particle)
function S = systematic_resample(S_bar)
	
    global M % number of particles 
    
    S = zeros(3,M);
    CDF = cumsum(S_bar(3,:));
    r = rand/M;

    for m = 1:M
        index = find(CDF >= (r + (m-1)/M), 1, 'first');
        S(:,m) = [S_bar(1:2,index); 1/M];
    end
end