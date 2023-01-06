function [nu_bar, beta, beta_auxillary, z_nc] = associate(z, mu_bar,sigma_bar)
    % This function performs the JPDA association
    % Inputs:
    %       z               dimMeasurementsXn_measurements      | measurements for each target
    %       mu_bar          dimStatesXtau                       | predicted state for each target
    %       sigma_bar       dimStatesXdimStatesXtau             | predicted covariance for each target
    % Outputs:
    %       nu_bar          dimMeasurementsXn_measurementsXtau  | innovation for each separate association
    %       beta            tauXn_measurements                  | marginalised probability for each seperate association
    %       beta_auxillary  tauX1                               | probability of target being misdetected
    
    global tau
    global Q
    global H
    global P_D
    global P_FA

    % number of measurements available
    n_measurements = size(z, 2);

    % First, compute individual association probabilities
    p_association = zeros(tau, n_measurements);
    nu_bar = zeros(size(z,1),n_measurements,tau);
    for t = 1:tau
        z_hat = H*mu_bar(:,t);
        for j = 1:n_measurements
            nu_bar(:,j,t) = z(:,j) - z_hat;
            S_bar = H*sigma_bar(:,:,t)*H' + Q;
            d = nu_bar(:,j,t)'/S_bar*nu_bar(:,j,t);
            % Measurement validation
            if d < 50
                p_association(t,j) = 1/((2*pi)^(size(z,1)/2)*sqrt(det(S_bar)))*exp(-0.5*d);
            end
        end
        % normalise the likelihoods to detection probability
        if (sum(p_association(t,:)) > 0)
            p_association(t,:) = P_D*p_association(t,:)/sum(p_association(t,:));
        end
    end

    % Now find legal association events
    [theta] = find_legal_association_events(n_measurements,tau);
    
    % Evaluate joint probability of event given measurements: p(theta|Z)
    event_probability = ones(size(theta,2),1);
    for event = 1:size(theta,2)
        % Keep track of amount of clutter measurements in event
        n_misdetected = 0;
        for t = 1:tau
            if theta(t,event) ~= 0
                event_probability(event) = event_probability(event)*p_association(t,theta(t,event));
            else
                n_misdetected = n_misdetected + 1;
            end
        end
        event_probability(event) = event_probability(event)*P_D^(tau-n_misdetected)*(1-P_D)^n_misdetected*P_FA^(n_measurements-(tau-n_misdetected));
    end
    % Normalize the joint probabilities
    event_probability = event_probability/sum(event_probability); 
    
    % Compute marginalised probabilities
    beta = zeros(tau,n_measurements);
    % Auxillary is to keep track of misdetection
    beta_auxillary = zeros(tau,1);
    for t = 1:tau
        for j = 1:n_measurements
            % Marginalize over association events that contain a t,j association
            beta(t,j) = sum(event_probability(theta(t,:) == j));
        end
        % Probability that object t was not detected
        beta_auxillary(t) = 1 - sum(beta(t,:));
    end
    
    % Heuristic to find measurements that did not reach association treshold
    % When sum of probability of all individual associations of a
    % measurement is arbitrarily unlikely
    z_nc = z(:,sum(beta,1) < 0.01);
end

