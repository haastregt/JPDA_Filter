% This script performs the JPDA filter on 1D data.

% Each target has the same discrete dynamical model x_k+1 = Fx_k + Gu_k
% and the same measurement model z_k = Hx_k.

% Run this code 20 times

clear, clc

iterations = 5; % Number of simulations to run

mmse_jpda_mean_all = zeros(iterations,1);
mmse_jpda_median_all = zeros(iterations,1);
mmse_jpda_75_all = zeros(iterations,1);
mmse_jpda_25_all = zeros(iterations,1);
mmse_gnn_mean_all = zeros(iterations,1);
mmse_gnn_median_all = zeros(iterations,1);
mmse_gnn_75_all = zeros(iterations,1);
mmse_gnn_25_all = zeros(iterations,1);

% Variables to store the execution time of each filter for each iteration
exec_time_jpda = zeros(iterations,1);
exec_time_gnn = zeros(iterations,1);

for i = 1:iterations

    % clear, clc

    %% Parameters
    global F            % F matrix of dynamical model
    global G            % G matrix of dynamical model
    global H            % H matrix of measurement model
    global R            % Covariance matrix of motion model | dimStates X dimStates
    global Q            % Covariance matrix of measurement model | dimStates X dimStates
    global tau          % Number of targets (fixed for now, TODO: can be variable and estimated)
    global P_D          % Probability of a detection
    global P_FA         % Probability of a false alarm
    global map_size     % size for the map, centered around the origin | scalar

    delta_t = 0.1;      % [s] Time between simulation steps
    end_time = 20;     % [s] Duration of simulation
    n_timesteps = end_time/delta_t + 1;

    %% Initialise
    % Define dynamical model: random walk (can be made more complicated)
    n_states = 1;              % Number of states of the dynamics model.
    n_inp    = 1;              % Number of control inputs.
    n_meas   = 1;              % Number of states of a measurement.
    F = eye(n_states);
    G = ones(n_states, n_inp);
    H = eye(n_meas, n_states);

    % Set values for JPDA parameters
    R = 0.02*eye(n_states);
    Q = 0.02*eye(n_meas);
    P_D = 0.9;
    P_FA = 0.9;%0.1;

    % Set the bounds of the map
    map_size = 6;

    % Number of targets
    tau = 2;

    % Initialise arrays to store each timestep for plotting
    ground_truth = zeros(n_states,tau,n_timesteps);
    mu_jpda = zeros(n_states,tau,n_timesteps);
    mu_gnn = zeros(n_states,tau,n_timesteps);
    sigma_jpda = zeros(n_states,n_states,tau,n_timesteps);
    sigma_gnn = zeros(n_states,n_states,tau,n_timesteps);
    % Cell arrays can have variable lengths for each timestep
    z = cell(n_timesteps,1); 
    association_ground_truth = cell(n_timesteps,1);

    % Set initial estimate of target states
    mu_jpda(:,:,1) = map_size*(rand(n_states, tau)-0.5);
    mu_gnn = mu_jpda;

    % Set initial estimate of covariances. Increase to start with less certainty
    sigma_jpda = repmat(1*R,[1,1,tau]);
    sigma_gnn = sigma_jpda;

    % Sample a ground truth for each target
    for t = 1:tau
        ground_truth(:,t,1) = mvnrnd(mu_jpda(:,t,1),sigma_jpda(:,:,t,1));
    end


    %% Run
    for timestep = 2:n_timesteps
        % Retrieve u (just 0 for now)
        u = zeros(n_inp,tau);
        
        % Simulate dynamical model
        [ground_truth(:,:,timestep)] = simulate_dynamics(ground_truth(:,:,timestep-1), u);

        % Simulate measurements
        [z{timestep}, association_ground_truth{timestep}] = simulate_measurements(ground_truth(:,:,timestep));
        
        % Do an iteration of JPDA Filter
        tic
        [mu_jpda(:,:,timestep), sigma_jpda(:,:,:,timestep)] = iterate(mu_jpda(:,:,timestep-1), sigma_jpda(:,:,:,timestep-1), u, z{timestep});
        exec_time_jpda(i) = toc;

        % Do an iteration of GNN Filter
        tic
        [mu_gnn(:,:,timestep), sigma_gnn(:,:,:,timestep)] = gnn_iterate(mu_gnn(:,:,timestep-1), sigma_gnn(:,:,:,timestep-1), u, z{timestep});
        exec_time_gnn(i) = toc;

    end

    %% Filter Evaluation

    % Calculate MMSE for each filter and the target closest to it at any point in time
    mmse_jpda = zeros(n_timesteps,1);
    mmse_gnn = zeros(n_timesteps,1);

    for timestep = 1:n_timesteps
        % Find the target closest to the JPDA estimate at this timestep
        [~, closest_target] = min(abs(mu_jpda(1,:,timestep) - ground_truth(1,:,timestep)));
        mmse_jpda(timestep) = (mu_jpda(1,closest_target,timestep) - ground_truth(1,closest_target,timestep))^2;
        
        % Find the target closest to the GNN estimate at this timestep
        [~, closest_target] = min(abs(mu_gnn(1,:,timestep) - ground_truth(1,:,timestep)));
        mmse_gnn(timestep) = (mu_gnn(1,closest_target,timestep) - ground_truth(1,closest_target,timestep))^2;
    end

    % Calculate the mean, median, 75th and 25th percentile of the MMSE
    mmse_jpda_mean = mean(mmse_jpda);
    mmse_jpda_median = median(mmse_jpda);
    mmse_jpda_75 = prctile(mmse_jpda, 75);
    mmse_jpda_25 = prctile(mmse_jpda, 25);

    mmse_gnn_mean = mean(mmse_gnn);
    mmse_gnn_median = median(mmse_gnn);
    mmse_gnn_75 = prctile(mmse_gnn, 75);
    mmse_gnn_25 = prctile(mmse_gnn, 25);


    %% Visualize results
%     timesteps = 0:delta_t:end_time;
% 
%     figure(1), clf(1), hold on
%     legendstrings = [];
%     for t = 1:tau
%         plot(timesteps,squeeze(ground_truth(1,t,:)))    % ground truth
%         plot(timesteps,squeeze(mu_jpda(1,t,:)))         % JPDA estimate
%         plot(timesteps,squeeze(mu_gnn(1,t,:)))          % GNN estimate
%         legendstrings = [legendstrings, "ground truth target " + num2str(t), "JPDA estimate" + num2str(t), "GNN estimate" + num2str(t)];
%     end
%     xlabel("Time (s)");
%     ylabel("Position [m]");
%     title("1D random walk with " + num2str(tau) + " targets");
%     legend(legendstrings)
%     hold off
% 
%     % Plot the MMSE for each filter
%     figure(2), clf(2), hold on
%     plot(timesteps, mmse_jpda)
%     plot(timesteps, mmse_gnn)
%     xlabel("Time (s)");
%     ylabel("MMSE [m^2]");
%     title("1D random walk with " + num2str(tau) + " targets");
%     legend("JPDA", "GNN")
%     hold off


    %% Save the results for each iteration
    % Save the MMSE metrics for each filter
    mmse_jpda_mean_all(i) = mmse_jpda_mean;
    mmse_jpda_median_all(i) = mmse_jpda_median;
    mmse_jpda_75_all(i) = mmse_jpda_75;
    mmse_jpda_25_all(i) = mmse_jpda_25;

    mmse_gnn_mean_all(i) = mmse_gnn_mean;
    mmse_gnn_median_all(i) = mmse_gnn_median;
    mmse_gnn_75_all(i) = mmse_gnn_75;
    mmse_gnn_25_all(i) = mmse_gnn_25;

end

% Before saving results compute the average of each MMSE metric over all iterations
results = struct;

results.mmse_jpda_mean_all = mean(mmse_jpda_mean_all);
results.mmse_jpda_median_all = mean(mmse_jpda_median_all);
results.mmse_jpda_75_all = mean(mmse_jpda_75_all);
results.mmse_jpda_25_all = mean(mmse_jpda_25_all);

results.mmse_gnn_mean_all = mean(mmse_gnn_mean_all);
results.mmse_gnn_median_all = mean(mmse_gnn_median_all);
results.mmse_gnn_75_all = mean(mmse_gnn_75_all);
results.mmse_gnn_25_all = mean(mmse_gnn_25_all);

results.exec_time_jpda = mean(exec_time_jpda);
results.exec_time_gnn = mean(exec_time_gnn);

% Save the results
save("results.mat", "results")