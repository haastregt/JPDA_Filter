function [z, association_ground_truth] = simulate_measurements(ground_truth)
    global H
    global Q
    global tau
    global map_size
    global P_FA
    global P_D
    
    association_ground_truth = [];
    z = zeros(size(H,1), 0);
    for t = 1:tau
        detected = false;
        while ~detected
            if rand(1) < P_FA
                % Clutter can come from targets as well, just with higher
                % variance
                false_detection = mvnrnd(ground_truth(:,t),20*Q)';
                z = [z, false_detection];
                association_ground_truth = [association_ground_truth, 0];
            else
                detected = true;
            end
        end
        
        if rand(1) < P_D
            detection = mvnrnd(ground_truth(:,t),Q)';
            z = [z, detection];
            association_ground_truth = [association_ground_truth, t];
        end
    end
end