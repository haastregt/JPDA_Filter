function [x_0, p_x] = initialize1Dstate()

    mu1 = -2.3; sigma1 = 1; weight1 = 0.4;
    mu2 = 2; sigma2 = 1;  weight2 = 0.6;
    x = -4:0.005:4;
    y1 = normpdf(x,mu1,sigma1);
    y2 = normpdf(x,mu2,sigma2);
    p_x = weight1*y1 + weight2*y2;

    %% Generate one random sample from the mixture of two gaussians and compute its corresponding x value
    r = randsample(1:length(p_x),1,true,p_x);
    x_0 = x(r);

end

