%% ===== ZADANIE FIRMY GREENTREE - PLAN PRODUKCJI =====
% Rozwiązanie zadania programowania liniowego dwoma metodami

%% 1. SFORMUŁOWANIE PROBLEMU
clear all; clc;

fprintf('=== ZADANIE FIRMY GREENTREE ===\n\n');

% Dane z zadania
area_total = 500;         % Całkowity areał [akry]
soja_limit = 120;         % Limit soi [akry]
kukurydza_min_buszle = 10000; % Minimalna dostawa kukurydzy [buszle]
plon_kukurydza = 110;     % Plon kukurydzy [buszle/akr]

% Ceny sprzedaży za buszel [$]
cena_kukurydza = 0.36;
cena_pszenica = 0.90;
cena_soja = 0.82;
cena_owies = 0.98;

% Plony z akra [buszle/akr]
plon = [110; 35; 32; 55]; % kukurydza, pszenica, soja, owies

% Przychód z akra [$]
przychod_akr = plon .* [cena_kukurydza; cena_pszenica; cena_soja; cena_owies];

fprintf('Dane wejściowe:\n');
fprintf('  Łączny areał: %d akrów\n', area_total);
fprintf('  Limit soi: ≤ %d akrów\n', soja_limit);
fprintf('  Minimalna dostawa kukurydzy: ≥ %d buszli\n', kukurydza_min_buszle);
fprintf('  Plony [buszle/akr]: kukurydza=%d, pszenica=%d, soja=%d, owies=%d\n', plon);
fprintf('  Ceny [$]: kukurydza=%.2f, pszenica=%.2f, soja=%.2f, owies=%.2f\n\n', ...
    cena_kukurydza, cena_pszenica, cena_soja, cena_owies);

%% 2. PRZEKSZTAŁCENIE DO POSTACI STANDARDOWEJ
% x1 - kukurydza, x2 - pszenica, x3 - soja, x4 - owies

% Funkcja celu: Maksymalizacja przychodu = minimalizacja (-przychód)
f = -przychod_akr;  % Ujemne, bo linprog minimalizuje

% Ograniczenia nierównościowe
A = [1, 1, 1, 1;        % x1+x2+x3+x4 ≤ 500 (całkowity areał)
     0, 0, 1, 0;        % x3 ≤ 120 (limit soi)
     0, -1, 1, 1];      % -x2 + x3 + x4 ≤ 0 (x2 ≥ x3+x4 -> -x2+x3+x4 ≤ 0)

b = [area_total; soja_limit; 0];

% Ograniczenia równościowe
Aeq = [];
beq = [];

% Dolne ograniczenia zmiennych
lb = [kukurydza_min_buszle/plon_kukurydza; 0; 0; 0];

% Górne ograniczenia zmiennych
ub = [Inf; Inf; soja_limit; Inf]; % x3 ≤ 120

%% 3. ROZWIĄZANIE ZA POMOCĄ linprog
fprintf('=== ROZWIĄZANIE 1 ===\n');

options = optimoptions('linprog', 'Display', 'iter', 'Algorithm', 'dual-simplex');

[x_linprog, fval_linprog, exitflag_linprog, output_linprog] = linprog(f, A, b, Aeq, beq, lb, ub, options);

if exitflag_linprog == 1
    fprintf('\n--- Rozwiązanie optymalne ---\n');
    fprintf('Zmienne decyzyjne [akry]:\n');
    fprintf('  Kukurydza: %8.2f akrów (%.0f buszli)\n', ...
        x_linprog(1), x_linprog(1)*plon(1));
    fprintf('  Pszenica: %8.2f akrów (%.0f buszli)\n', ...
        x_linprog(2), x_linprog(2)*plon(2));
    fprintf('  Soja: %8.2f akrów (%.0f buszli)\n', ...
        x_linprog(3), x_linprog(3)*plon(3));
    fprintf('  Owies: %8.2f akrów (%.0f buszli)\n', ...
        x_linprog(4), x_linprog(4)*plon(4));
    
    fprintf('\nWyniki:\n');
    fprintf('  Maksymalny przychód: $%.2f\n', -fval_linprog);
    fprintf('  Wykorzystany areał: %.2f z %d akrów (%.1f%%)\n', ...
        sum(x_linprog), area_total, 100*sum(x_linprog)/area_total);
    fprintf('  Liczba iteracji: %d\n', output_linprog.iterations);
    
    % Sprawdzenie ograniczeń
    fprintf('\nSprawdzenie ograniczeń:\n');
    fprintf('  Całkowity areał: %.2f ≤ %d (spełnione: %d)\n', ...
        sum(x_linprog), area_total, sum(x_linprog) <= area_total);
    fprintf('  Limit soi: %.2f ≤ %d (spełnione: %d)\n', ...
        x_linprog(3), soja_limit, x_linprog(3) <= soja_limit);
    fprintf('  Kontrakt kukurydza: %.0f ≥ %d buszli (spełnione: %d)\n', ...
        x_linprog(1)*plon(1), kukurydza_min_buszle, x_linprog(1)*plon(1) >= kukurydza_min_buszle);
    fprintf('  Pszenica ≥ owies+soja: %.2f ≥ %.2f (spełnione: %d)\n', ...
        x_linprog(2), x_linprog(4)+x_linprog(3), x_linprog(2) >= x_linprog(4)+x_linprog(3));
else
    fprintf('Solver nie znalazł rozwiązania. Exit flag: %d\n', exitflag_linprog);
end

%% 4. ROZWIĄZANIE ZA POMOCĄ linprog
fprintf('\n\n=== ROZWIĄZANIE 2 ===\n');

options_ip = optimoptions('linprog', 'Display', 'iter', 'Algorithm', 'interior-point');

[x_ip, fval_ip, exitflag_ip, output_ip] = linprog(f, A, b, Aeq, beq, lb, ub, options_ip);

if exitflag_ip == 1
    fprintf('\n--- Rozwiązanie optymalne ---\n');
    fprintf('Zmienne decyzyjne [akry]:\n');
    fprintf('  Kukurydza: %8.2f akrów (%.0f buszli)\n', ...
        x_ip(1), x_ip(1)*plon(1));
    fprintf('  Pszenica: %8.2f akrów (%.0f buszli)\n', ...
        x_ip(2), x_ip(2)*plon(2));
    fprintf('  Soja: %8.2f akrów (%.0f buszli)\n', ...
        x_ip(3), x_ip(3)*plon(3));
    fprintf('  Owies: %8.2f akrów (%.0f buszli)\n', ...
        x_ip(4), x_ip(4)*plon(4));
    
    fprintf('\nWyniki:\n');
    fprintf('  Maksymalny przychód: $%.2f\n', -fval_ip);
    fprintf('  Wykorzystany areał: %.2f z %d akrów (%.1f%%)\n', ...
        sum(x_ip), area_total, 100*sum(x_ip)/area_total);
    fprintf('  Liczba iteracji: %d\n', output_ip.iterations);
else
    fprintf('Solver nie znalazł rozwiązania. Exit flag: %d\n', exitflag_ip);
end

%% 5. PORÓWNANIE ROZWIĄZAŃ
fprintf('\n\n=== PORÓWNANIE ROZWIĄZAŃ ===\n');

if exitflag_linprog == 1 && exitflag_ip == 1
    % Różnice między rozwiązaniami
    diff_x = abs(x_linprog - x_ip);
    diff_fval = abs(-fval_linprog - (-fval_ip));
    
    fprintf('\nPorównanie wartości zmiennych:\n');
    fprintf('          | linprog (dual) | linprog (IP)  | Różnica   |\n');
    fprintf('----------|----------------|---------------|-----------|\n');
    fprintf('Kukurydza | %12.2f  | %12.2f | %9.2f |\n', ...
        x_linprog(1), x_ip(1), diff_x(1));
    fprintf('Pszenica  | %12.2f  | %12.2f | %9.2f |\n', ...
        x_linprog(2), x_ip(2), diff_x(2));
    fprintf('Soja      | %12.2f  | %12.2f | %9.2f |\n', ...
        x_linprog(3), x_ip(3), diff_x(3));
    fprintf('Owies     | %12.2f  | %12.2f | %9.2f |\n', ...
        x_linprog(4), x_ip(4), diff_x(4));
    fprintf('Przychód  | %12.2f  | %12.2f | %9.2f |\n', ...
        -fval_linprog, -fval_ip, diff_fval);
    
   else
    fprintf('Co najmniej jeden solver nie znalazł rozwiązania optymalnego.\n');
end


