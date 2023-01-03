% This function calcultes the weights for each particle based on the
% observation likelihood
%           S_bar(t)            3XM | Particle set (x,y,weight for each particle)
%           outlier             1Xn
%           Psi(t)              1XnXM
% Outputs: 
%           S_bar(t)            3XM | Particle set (x,y,weight for each particle)
function S_bar = weight_particles(S_bar, Psi, outlier)
    % Remove Outliers
    Psi_filtered = Psi(1,~outlier,:);

    % Get weights
    weights = prod(Psi_filtered,2);
    weights = (weights/sum(weights));
    
    S_bar(3,:) = weights;
end
