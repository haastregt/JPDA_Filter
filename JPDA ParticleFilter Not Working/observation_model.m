% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           S(t)                           3XM | Particle set (x,y,weight for each particle)
% Outputs:  
%           z_j                            2XM | Expected measurement (x,y)
function z_j = observation_model(S)

    % TODO: Implement observation model
    z_j = S(1:2,:);

end
