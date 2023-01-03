% This function performs the ML data association
%           S_bar(t)                 3XMXTau | x,y,weight for each particle for each target
%           z(t)                     2Xn     | n measurements of x,y
%           association_ground_truth 1Xn     | ground truth target ID for every measurement  
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

    m_k = size(z,2); % Number of measurements

    % Initiate Storage Variables
    z_hat = zeros(2, M, tau);
    nu = zeros(size(z_hat));
    nu_cov = zeros(2,2,m_k,tau);
    prob = zeros(m_k,tau);

    
    for t = 1:tau % Loop through all targets
        z_hat(:,:,t) = observation_model(S_bar(:,:,t));

        for j = 1:m_k % Loop through each measurement
            nu(:,:,t) = z(:,j) - z_hat(:,:,t);
            prob(j,t) = evaluate_probability(nu(:,:,t),nu_cov(:,:,j,t));
        end
    end
    

    function prob = evaluate_probability(nu, nu_cov)
        d = nu'*(nu\inv(nu_cov));
        prob = 1/(2*pi*sqrt(det(nu_cov)))*exp(-0.5*d^2);
    end
end
