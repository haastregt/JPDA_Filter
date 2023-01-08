function [jpda_mse, gnn_mse] = compute_MSE(n_rep)
    global R            % Covariance matrix of motion model | dimStates X dimStates
    global tau          % Number of targets
    
    % Simulation duration
    delta_t = 0.1;      % [s] Time between simulation steps
    end_time = 1;     % [s] Duration of simulation
    n_timesteps = end_time/delta_t + 1;
    
    jpda_error = zeros(n_rep*n_timesteps,1);
    gnn_error = zeros(n_rep*n_timesteps,1);
    
    for n = 1:n_rep
        % Set initial estimate of target states
        mu(:,:) = [1, 2];
        mu_gnn = mu;
        
        % Set initial estimate of covariances. Increase to start with less certainty
        sigma(:,:,:) = repmat(1*R,[1,1,tau]);
        sigma_gnn = sigma;
        
        % Sample a ground truth for each target
        for t = 1:tau
            ground_truth(:,t) = mvnrnd(mu(:,t),sigma(:,:,t));
        end
        
        % Run
        for timestep = 2:n_timesteps
            % Retrieve u (0 for a random walk)
            u = zeros(1,tau);
            
            % Simulate dynamical model
            [ground_truth(:,:)] = simulate_dynamics(ground_truth(:,:), u);
        
            % Simulate measurements
            [z] = simulate_measurements(ground_truth(:,:));
            
            % Do an iteration of JPDA Filter
            [mu(:,:), sigma(:,:,:)] = iterate(mu(:,:), sigma(:,:,:), u, z);
        
            % Do an iteration of GNN Filter
            [mu_gnn(:,:), sigma_gnn(:,:,:)] = gnn_iterate(mu_gnn(:,:), sigma_gnn(:,:,:), u, z);
    
            jpda_error((n-1)*n_timesteps + timestep) = mean(squeeze((ground_truth-mu).^2));
            gnn_error((n-1)*n_timesteps + timestep) = mean(squeeze((ground_truth-mu_gnn).^2));
        end
    end
    
    jpda_mse = mean(jpda_error(find(jpda_error)));
    gnn_mse = mean(gnn_error(find(gnn_error)));
end