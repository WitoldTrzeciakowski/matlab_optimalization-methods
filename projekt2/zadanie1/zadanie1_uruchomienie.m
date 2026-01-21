clear; close all; clc;

%% CZĘŚĆ 1: Animacja dla wymiaru 2 (Rosenbrock)
disp('--- Rozpoczynanie optymalizacji: Funkcja Rosenbrocka ---');

% Punkt startowy dla funkcji Rosenbrocka
x0_ros = [-1.2; 1.0]; 

% Parametry: funkcja, punkt startowy, max iteracji, tolerancja
[x_opt, f_min, historia] = solver_sr1_armijo(@funkcja_rosenbrocka, x0_ros, 200, 1e-4);

disp(['Znalezione minimum: ', num2str(x_opt')]);

% Rysowanie animacji
figure('Name', 'Animacja Rosenbrock 2D');
hold on; grid on;
xlabel('x1'); ylabel('x2');
title('Optymalizacja SR1 - Rosenbrock');

% Rysowanie poziomic
% Przygotowanie siatki
[X, Y] = meshgrid(-2:0.1:2, -1:0.1:3);
Z = zeros(size(X));
% Obliczanie wartości na siatce
for i = 1:size(X,1)
    for j = 1:size(X,2)
        Z(i,j) = funkcja_rosenbrocka([X(i,j); Y(i,j)]);
    end
end
% Logarytmiczna skala poziomic
contour(X, Y, log(1+Z), 30); 

% Animacja ścieżki
h_plot = plot(historia(1,1), historia(2,1), 'ro-', 'LineWidth', 1.5, 'MarkerSize', 4);

for k = 2:size(historia, 2)
    % Aktualizacja danych wykresu
    set(h_plot, 'XData', historia(1, 1:k), 'YData', historia(2, 1:k));
    
    % Odświeżenie widoku
    drawnow; 
    pause(0.1);
end
hold off;


%% CZĘŚĆ 2: Animacja dla wymiaru 2 (Funkcja Kwadratowa)
disp(' ');
disp('--- Rozpoczynanie optymalizacji: Funkcja Kwadratowa ---');

% Punkt startowy dla funkcji kwadratowej
x0_quad = [2; 2]; 

% Uruchomienie solwera
[x_opt_q, f_min_q, historia_q] = solver_sr1_armijo(@funkcja_kwadratowa, x0_quad, 100, 1e-4);

figure('Name', 'Animacja Funkcja Kwadratowa 2D');
hold on; grid on; axis equal;
xlabel('x1'); ylabel('x2');
title('Optymalizacja SR1 - Funkcja Kwadratowa');

% Rysowanie poziomic
[Xq, Yq] = meshgrid(-3:0.1:3, -3:0.1:3);
Zq = Xq.^2 + 10*Yq.^2;
contour(Xq, Yq, Zq, 30); 
colorbar;

% Animacja ścieżki
h_plot_q = plot(historia_q(1,1), historia_q(2,1), 'k*-', 'LineWidth', 1.5);

for k = 2:size(historia_q, 2)
    set(h_plot_q, 'XData', historia_q(1, 1:k), 'YData', historia_q(2, 1:k));
    drawnow;
    pause(0.1);
end
hold off;


%% CZĘŚĆ 3: Test dla wymiaru 100
disp(' ');
disp('--- Testowanie dla N=100 ---');

N = 100;

% 1. Rosenbrock N=100
x0_ros_100 = ones(N, 1); 
x0_ros_100(1:2:end) = -1.2;

tic;
[x_opt_100, f_min_100, ~] = solver_sr1_armijo(@funkcja_rosenbrocka, x0_ros_100, 1000, 1e-4);
czas = toc;

disp(['Rosenbrock 100D - Wartość końcowa funkcji: ', num2str(f_min_100)]);
disp(['Czas obliczeń: ', num2str(czas), ' s']);
% Sprawdzenie błędu względem optimum globalnego
disp(['Norma różnicy od rozwiązania globalnego: ', num2str(norm(x_opt_100 - ones(N,1)))]);

% 2. Kwadratowa N=100
x0_quad_100 = 5 * ones(N, 1); % Start z punktu [5, 5, ..., 5]

tic;
[x_opt_q100, f_min_q100, ~] = solver_sr1_armijo(@funkcja_kwadratowa, x0_quad_100, 1000, 1e-4);
czas_q = toc;

disp(' ');
disp(['Kwadratowa 100D - Wartość końcowa funkcji: ', num2str(f_min_q100)]);
disp(['Czas obliczeń: ', num2str(czas_q), ' s']);