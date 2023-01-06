function [theta] = find_legal_association_events(n_measurements,tau)
    % This function finds all legal association events
    % Inputs:
    %       n_measurements      scalar               | number of measurements
    %       tau                 scalar               | number of targets
    % Outputs:
    %       theta               tauXn_legal_events   | all possible association events

    % For legal assocations the following conditions must hold:
    %       1. Each object must be either detected or misdetected
    %       2. No pair of objects can be associated to the same measurement
    % An association with 0 means misdetection. Multiple objects can be associated with misdetection

    theta = zeros(tau,0);
    for n_misdetections = max(0,tau-n_measurements):tau % Case least possible to all but 1 misdetections
        combinations = nchoosek(1:n_measurements, tau-n_misdetections);
        % Append zeros for misdetections;
        combinations = [combinations, zeros(size(combinations,1),n_misdetections)]; 
        permutations = reshape(combinations(:,perms(1:tau)),[],tau);
        theta = [theta, permutations'];
    end
    
    if n_measurements == 1
        theta = [theta, zeros(tau,1)];
    end
    % Remove duplicates
    theta = unique(theta',"rows")';
end