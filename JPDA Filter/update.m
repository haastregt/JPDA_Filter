function [mu, sigma] = update(mu_bar, sigma_bar, beta, beta_auxillary, nu_bar)
    % This function performs the update step of the Kalman Filter
    % Inputs:
    %           mu_bar(t)       dimStatesXtau                       | predicted mean of each target
    %           sigma_bar(t)    dimStatesXdimStatesXtau             | predicted variance of each target
    %           beta            tauXn_measurements                  | complete probability for association
    %           beta_auxillary  tauX1                               | probability of target not being detected
    %           nu_bar          dimMeasurementsXn_measurementsXtau  | innovation for individual associations
    % Outputs:
    %           mu(t)           dimStatesXtau                       | updated mean for each target
    %           sigma(t)        dimStatesXdimStatesXtau             | updated variance for each target
    
    global tau
    global H
    global Q
    
    n_measurements = size(beta,2);

    mu = zeros(size(mu_bar));
    sigma = zeros(size(sigma_bar));

    for t = 1:tau
        nu_total = 0;
        for j = 1:n_measurements
            nu_total = nu_total + beta(t,j)*nu_bar(:,j,t);
        end
        K = sigma_bar(:,:,t)*H/(H*sigma_bar(:,:,t)*H' + Q);

        mu(:,t) = mu_bar(:,t) + K*nu_total;
        
        P_bar = sigma_bar(:,:,t) - K*(H*sigma_bar(:,:,t)*H' + Q)*K';
        summed = 0; 
        for j = 1:n_measurements
            summed = summed + beta(t,j)*(nu_bar(:,j,t)*nu_bar(:,j,t)');
        end
        P_tilde = K*(summed - nu_total*nu_total')*K';
        sigma(:,:,t) = beta_auxillary(t)*sigma_bar(:,:,t) + (1-beta_auxillary(t))*P_bar + P_tilde;
    end
end