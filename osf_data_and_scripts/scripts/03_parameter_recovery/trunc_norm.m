function x = trunc_norm(mu, sigma, k)
% Sample from N(mu, sigma) truncated to [mu-k*sigma, mu+k*sigma]

    lower = mu - k*sigma;
    upper = mu + k*sigma;

    x = mu + sigma*randn;

    while (x < lower) || (x > upper)
        x = mu + sigma*randn;
    end
end