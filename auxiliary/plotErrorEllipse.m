function [plotX, plotY] = plotErrorEllipse(mu, Sigma, p)
    % Helper function for plotting uncertainty bounds
    s = -2 * log(1 - p);
    [V, D] = eig(Sigma * s);
    t = linspace(0, 2 * pi);
    a = (V * sqrt(D)) * [cos(t(:))'; sin(t(:))'];

    plotX = a(1, :) + mu(1);
    plotY = a(2, :) + mu(2);
end