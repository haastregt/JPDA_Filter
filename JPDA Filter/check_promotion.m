function [promote, purge, tracker] = check_promotion(beta_auxillary, tracker)
    % This function checks for M/N heuristics.
    % Inputs:
    %       beta_auxillary          1xtau     | Probability of misdetection
    %       tracker                 (n+1)xtau | M/N heuristic for each target
    % Outputs:
    %       tracker                 (n+1)xtau | updated M/N heuristic for each target
    %       promote                 1xtau     | 1 if promoted, 0 otherwise
    %       purge                   1xtau     | 1 if purged, 0 otherwise
    
    global M_P
    global M_D

    tracker(1:(end-1),:) = tracker(2:end,:);
    % Give a hit if probability of misdetection is bigger than probability of detection
    tracker(end,:) = beta_auxillary > 0.9; 
    % Total hits in past n times
    M = sum(tracker(2:end,:),1);

    purge = M > M_D;
    % after N steps, -1 that was initialised at end position will have moved to first position
    promote = find((tracker(1,:) == -1).*(M < M_P));
    purge = find(purge + ((tracker(1,:) == -1) .* (~(M < M_P))));
end

