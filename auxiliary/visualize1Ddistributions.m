function [] = visualize1Ddistributions(true_posterior, jpda_posterior, gnn_posterior, ground_truth)
    x = -4:0.005:4;
    
    hold on; grid on;
    
    % Plot the true and approximated posteriors
    plot(x, true_posterior, 'k', x, jpda_posterior, 'b', x, gnn_posterior,'g');

    % Plot the ground truth
    plot(ground_truth,0,'r*');


    title('Multimodal distribution');
    hold off;
    xlim([-4 4]);
    ylim([0 0.4]);

    xlabel('x');
    ylabel('P(x)');
    legend('True Posterior','JPDA Posterior', 'GNN Posterior', 'Ground Truth');


end