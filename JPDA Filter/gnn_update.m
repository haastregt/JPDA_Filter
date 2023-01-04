function [mu, sigma] = gnn_update(mu_bar, sigma_bar, z)
    % This function performs the update step of the Kalman Filter
    % Inputs:
    %           mu_bar(t)       dimStatesXtau                       | predicted mean of each target
    %           sigma_bar(t)    dimStatesXdimStatesXtau             | predicted variance of each target
    %           z(t)            dimTargetsXn_measurements           | measurements at time t
    % Outputs:
    %           mu(t)           dimStatesXtau                       | updated mean for each target
    %           sigma(t)        dimStatesXdimStatesXtau             | updated variance for each target
    
    global tau
    global H
    global Q
    
    n_measurements = size(z,2);

    mu = zeros(size(mu_bar));
    sigma = zeros(size(sigma_bar));


    % Perform the Kalman update step for each target
    for t = 1:tau
        K = sigma_bar(:,:,t)*H/(H*sigma_bar(:,:,t)*H' + Q); % Kalman gain
        nu_bar(:,t) = z(:,t) - H*mu_bar(:,t);               % Innovation
        S = H*sigma_bar(:,:,t)*H' + Q;                      % Innovation covariance

        mu(:,t) = mu_bar(:,t) + K*nu_bar(:,t);              % Updated mean
        sigma(:,:,t) = sigma_bar(:,:,t) - K*S*K';           % Updated variance

    end


end