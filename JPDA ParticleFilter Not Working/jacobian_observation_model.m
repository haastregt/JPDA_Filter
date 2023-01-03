% This function is the implementation of the jacobian measurement model
% required for the update of the covariance function after incorporating
% the measurements
% Inputs:
%           x(t)        2X1
%           j           1X1 which target
%           z_j         2X1
% Outputs:  
%           H           2X2
function H = jacobian_observation_model(x, j, z_j)
    H = [1, 0; 0, 1];
end
