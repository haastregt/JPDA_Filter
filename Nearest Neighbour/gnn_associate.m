function [z_hat, invalid] = gnn_associate(z, mu_bar,sigma_bar)
    % This function performs the GNN association

    global tau
    global Q
    global H
    global P_D
    global P_FA

    % Number of available measurements
    n_measurements = size(z,2);
    % gate_threshold = chi2inv(0.99,2); % Threshold for the Mahalanobis distance
    gate_threshold = 50; % [m] % TODO: This is a temporary value that is used just for debugging purposes
    invalid = 0;    % Flag to indicate if there are any valid associations by the end of this function

    %% Step 1: Compute cost matrix L_ij (i = 1,2,...,targets; j = 1,2,...,measurements)
    L_ij = zeros(tau,n_measurements); % Initialize the cost matrix

    for i = 1:tau
        for j = 1:n_measurements
            % 1.1: Compute the Mahalanobis distance between the expected measurement and measurement
            dist = (z(j) - H*mu_bar(:,i))' * inv(H*sigma_bar(:,:,i)*H' + Q) * (z(j) - H*mu_bar(:,i));
            
            % 1.2: if the Mahalanobis distance is less than the threshold, then the measurement is gated and is assigned a cost according to the distance
            % if the Mahalanobis distance is greater than the threshold, then the measurement is not gated and is assigned a cost of infinity
            if dist < gate_threshold
                L_ij(i,j) = dist;
            else
                L_ij(i,j) = inf;
            end

        end
    end


    %% Step 2: Use brute force to find the optimal theta^*i (i = 1,2,...,targets)

    % 2.1: Compute the cost for all possible combinations of targets with the measurements and misdetections. and choose the one with the lowest cost
    % NOTE: Each observation can only be associated with one target, and each target can only be associated with one observation.
    % TODO: Make this code work for any number of targets and potentially implement the Hungarian algorithm if needed
    
    min_total_cost = inf; % Initialize the minimum total cost
    cost = 0;

    if tau == 1
        for t1 = 1:size(z, 2)
            new_total_cost = L_ij(1,t1);
            if new_total_cost < min_total_cost
                min_total_cost = new_total_cost;
                theta_1_star = t1;
            end
        end
    elseif tau == 2
        for t1 = 1:size(z, 2)
            for t2 = 1:size(z, 2)
                if t2 == t1
                    continue
                end
            end
            new_total_cost = L_ij(1,t1) + L_ij(2,t2);
            if new_total_cost < min_total_cost
                min_total_cost = new_total_cost;
                theta_1_star = t1;
                theta_2_star = t2;
            end
        end
    elseif tau == 3
        for t1 = 1:size(z, 2)
            for t2 = 1:size(z, 2)
                if t2 == t1
                    continue
                end
                for t3 = 1:size(z, 2)
                    if t3 == t1 || t3 == t2
                        continue
                    end
                    new_total_cost = L_ij(1,t1) + L_ij(2,t2) + L_ij(3,t3);
                    if new_total_cost < min_total_cost
                        min_total_cost = new_total_cost;
                        theta_1_star = t1;
                        theta_2_star = t2;
                        theta_3_star = t3;
                    end
                end
            end
        end
    end

    %% Step 3: Check if there are any valid associations
    if min_total_cost == inf
        % If there are no valid associations, then return the measurements as they are
        z_hat = z;
        invalid = 1;
        return
    end

    %% Step 4: Using the optimal association theta^*i (i = 1,2,...,targets), compute the association matrix A_ij (i = 1,2,...,targets; j = 1,2,...,measurements + misdetections )
    A_ij = zeros(tau,n_measurements); % Initialize the association matrix

    % If theta^*i = j != 0, then A_ij = 1
    % If theta^*i = 0, then A_i,m+i = 1

    if tau == 1
        if theta_1_star ~= 0
            A_ij(1,theta_1_star) = 1;
        else
            A_ij(1,n_measurements+1) = 1;
        end
    elseif tau == 2
        if theta_1_star ~= 0
            A_ij(1,theta_1_star) = 1;
        else
            A_ij(1,n_measurements+1) = 1;
        end
        if theta_2_star ~= 0
            A_ij(2,theta_2_star) = 1;
        else
            A_ij(2,n_measurements+2) = 1;
        end
    elseif tau == 3
        if theta_1_star ~= 0
            A_ij(1,theta_1_star) = 1;
        else
            A_ij(1,n_measurements+1) = 1;
        end
        if theta_2_star ~= 0
            A_ij(2,theta_2_star) = 1;
        else
            A_ij(2,n_measurements+2) = 1;
        end
        if theta_3_star ~= 0
            A_ij(3,theta_3_star) = 1;
        else
            A_ij(3,n_measurements+3) = 1;
        end
    end


    %% Step 4 Return the measurement obtained from the association matrix
    z_hat = zeros(size(tau, 2), size(z, 2));

    for i = 1:tau
        for j = 1:n_measurements
            if A_ij(i,j) == 1
                z_hat(i) = z(j);
            end
        end
    end


















end



