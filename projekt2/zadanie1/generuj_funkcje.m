% generuj_funkcje.m
% Skrypt generujący pliki funkcji celu i ich gradientów przy użyciu Symbolic Toolbox

clear; clc;

% Definicja zmiennych symbolicznych (wektor x o dowolnym rozmiarze)
x = sym('x', [1 0]); % Tworzymy zmienną, która będzie wektorem w generowanych funkcjach

%% 1. Funkcja Rosenbrocka (uogólniona)
% f = sum( 100*(x(i+1) - x(i)^2)^2 + (1 - x(i))^2 )
n_ros = 2; % Dla celów symbolicznych definiujemy dla n=2, ale kod zrobimy uniwersalny wektorowo
syms x1 x2 real
f_ros_sym = 100*(x2 - x1^2)^2 + (1 - x1)^2;

% Generowanie pliku dla Funkcji Rosenbrocka (Wartość)
matlabFunction(f_ros_sym, 'File', 'rosenbrock_func', 'Vars', {[x1; x2]});

% Generowanie pliku dla Gradientu Rosenbrocka
g_ros_sym = gradient(f_ros_sym, [x1; x2]);
matlabFunction(g_ros_sym, 'File', 'rosenbrock_grad', 'Vars', {[x1; x2]});

%% 2. Funkcja Kwadratowa (Druga funkcja z zestawu)
% Przyjmijmy prostą, wypukłą funkcję kwadratową: f(x) = x1^2 + 10*x2^2
f_quad_sym = x1^2 + 10*x2^2;

% Generowanie plików
matlabFunction(f_quad_sym, 'File', 'quad_func', 'Vars', {[x1; x2]});
g_quad_sym = gradient(f_quad_sym, [x1; x2]);
matlabFunction(g_quad_sym, 'File', 'quad_grad', 'Vars', {[x1; x2]});

disp('Wygenerowano pliki: rosenbrock_func.m, rosenbrock_grad.m, quad_func.m, quad_grad.m');