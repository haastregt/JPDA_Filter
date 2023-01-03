% This function performs the prediction step.
% Inputs:
%           S(t-1)            3XM | Particle set (x,y,weight for each particle)
%           u                 3X1 | inputs, 3rd input always 0
% Outputs:   
%           S_bar(t)          3XM | Particle set (x,y,weight for each particle)
function [S_bar] = predict_states(S, u, delta_t)

    global R % covariance matrix of motion model | shape 2x2
    global M % number of particles
    
    % Currently dynamical model is a random walk
    F = [1, 0; 0, 1]; 
    G = [0, 0; 0, 0];

    % Appending zeros for the extra weight state
    F = [F, [0; 0]; 0, 0, 1];
    G = [G, [0; 0]; 0, 0, 0];
      
    S_bar = F*S + G*repmat(u,M) + [R * randn(2,M); zeros(1,M)];
end