function [f, g] = funkcja_rosenbrocka(x)
    % Oblicza wartość i gradient funkcji Rosenbrocka dla dowolnego wymiaru N (parzystego)
    % x - wektor kolumnowy
    
    n = length(x);
    f = 0;
    g = zeros(n, 1);
    
    for i = 1:2:n-1
        x_i = x(i);
        x_next = x(i+1);
        
        % Wartość funkcji
        term1 = 100 * (x_next - x_i^2)^2;
        term2 = (1 - x_i)^2;
        f = f + term1 + term2;
        
        % Gradient
        % Pochodna po x_i
        g(i) = g(i) - 400 * x_i * (x_next - x_i^2) - 2 * (1 - x_i);
        % Pochodna po x_{i+1}
        g(i+1) = g(i+1) + 200 * (x_next - x_i^2);
    end
end