% This function performs the ML data association
%           S_bar(t)                 3XM | (x,y,weight for each particle)
%           z(t)                     2Xn | n measurements of x,y
%           association_ground_truth 1Xn | ground truth target ID for every measurement  
% Outputs: 
%           outlier                  1Xn   | (1 means outlier, 0 means not outlier) 
%           Psi(t)                   1XnXM
%           c                        1xnxM
function [outlier, Psi, c] = JPDA_associate(S_bar, z, association_ground_truth)
    if nargin < 3
        association_ground_truth = [];
    end
    
    global lambda_psi % threshold on average likelihood for outlier detection
    global Q % covariance matrix of the measurement model
    global M % number of particles
    global tau % number of targets

    % TODO: Use JPDA. Now LAB2 association is still used

    nObs = size(z,2);

    % Initiate Storage Variables
    z_hat = zeros(2, M, tau);
    nu = zeros(size(z_hat)); 
    psi = zeros(M, tau);
    Psi = zeros(1,nObs,M);
    outlier = zeros(1,nObs);
    c = zeros(1,nObs, M);

    % Loop through all targets. More efficient to do out of main loop
    for k = 1:tau
        z_hat(:,:,k) = observation_model(S_bar, k);
    end
    
    % Loop through each observation
    for i = 1:nObs
        nu(:,:,:) = z(:,i) - z_hat;
        nu(2,:,:) = mod(nu(2,:,:) + pi, 2*pi) - pi;
        
        psi(:,:) = 1/(2*pi*det(Q)^(1/2)) * exp(-1/2 * sum(nu.^2 ./ repmat(diag(Q),[1,M,tau])));
        [Psi(1,i,:), c(1,i,:)] = max(psi,[],2);
       
    end
    outlier = mean(Psi,3) <= lambda_psi;

end
