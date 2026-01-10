function [f, g] = quadratic_val_grad(x)
    % Prosta funkcja kwadratowa f(x) = sum (i * x_i^2)
    % Pozwala przetestować algorytm na funkcji wypukłej
    
    n = length(x);
    vec_coeff = (1:n)'; % Wagi: 1, 2, ..., n (zwiększa uwarunkowanie)
    
    % Wartość
    f = sum(vec_coeff .* (x.^2));
    
    % Gradient: pochodna x_i^2 to 2*x_i
    g = 2 * vec_coeff .* x;
end