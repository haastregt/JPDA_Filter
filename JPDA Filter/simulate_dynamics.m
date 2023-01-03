function [ground_truth] = simulate_dynamics(ground_truth, u)
    global F
    global G
    global R
    global tau
    
    for t = 1:tau
        ground_truth(:,t) = mvnrnd(F*ground_truth(:,t) + G*u(:,t), R);
    end
end