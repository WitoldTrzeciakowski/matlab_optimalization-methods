clear all
clc

fprintf('=== KLASYFIKACJA SVM - AUTO MPG ===\n\n');

%% =========================
% 1. WCZYTANIE DANYCH
% =========================
fprintf('1. Wczytywanie danych...\n');

filename = 'auto-mpg.csv';

if ~exist(filename, 'file')
    error('Plik %s nie istnieje!', filename);
end

% Wczytanie danych - bardziej niezawodna metoda
try
    % Próba 1: użyj readmatrix z obsługą brakujących wartości
    data = readmatrix(filename, ...
        'FileType', 'text', ...
        'Delimiter', {' ', '\t'}, ...
        'ConsecutiveDelimitersRule', 'join', ...
        'TreatAsMissing', '?', ...
        'NumHeaderLines', 0);
    
    fprintf('   Wczytano macierz: %d wierszy x %d kolumn\n', size(data));
    
    % Auto MPG ma zwykle 9 kolumn (ostatnia to nazwa samochodu)
    % Bierzemy tylko pierwsze 8 kolumn liczbowych
    if size(data, 2) > 8
        data = data(:, 1:8);
        fprintf('   Pominięto kolumnę z nazwami samochodów\n');
    end
    
catch
    % Próba 2: użyj readtable jako fallback
    fprintf('   Próba alternatywnej metody wczytywania...\n');
    T = readtable(filename, ...
        'ReadVariableNames', false, ...
        'Delimiter', {' ', '\t'}, ...
        'ConsecutiveDelimitersRule', 'join', ...
        'TreatAsMissing', '?');
    
    % Konwersja do macierzy
    data = table2array(T(:, 1:8));
    fprintf('   Wczytano tabelę: %d wierszy x %d kolumn\n', size(data));
end

% Usuń wiersze z NaN
data_clean = data(~any(isnan(data), 2), :);
fprintf('   Po usunięciu braków: %d rekordów\n', size(data_clean, 1));

%% =========================
% 2. PRZYGOTOWANIE DANYCH
% =========================
fprintf('2. Przygotowanie danych...\n');

% Atrybut prognozowany: mpg (kolumna 1)
mpg = data_clean(:, 1);

% Macierz cech: kolumny 2-8
X = data_clean(:, 2:end);

fprintf('   Liczba cech: %d\n', size(X, 2));
fprintf('   Liczba próbek: %d\n', length(mpg));

%% =========================
% 3. PODZIAŁ NA KLASY (medianą mpg)
% =========================
med_mpg = median(mpg);
fprintf('3. Podział na klasy względem mediany mpg = %.2f\n', med_mpg);

y = ones(size(mpg));
y(mpg < med_mpg) = -1;

n_pos = sum(y == 1);
n_neg = sum(y == -1);
fprintf('   Klasa +1 (mpg >= %.2f): %d próbek\n', med_mpg, n_pos);
fprintf('   Klasa -1 (mpg < %.2f): %d próbek\n', med_mpg, n_neg);

%% =========================
% 4. NORMALIZACJA CECH
% =========================
fprintf('4. Normalizacja cech...\n');

mean_X = mean(X);
std_X = std(X);
std_X(std_X == 0) = 1;

X = (X - mean_X) ./ std_X;

% Upewnij się, że nie ma NaN/Inf
if any(isnan(X(:))) || any(isinf(X(:)))
    fprintf('   UWAGA: Znaleziono NaN/Inf. Zastępowanie zerami...\n');
    X(isnan(X)) = 0;
    X(isinf(X)) = 0;
end

%% =========================
% 5. PODZIAŁ NA ZBIÓR UCZĄCY I TESTOWY
% =========================
fprintf('\n5. Podział na zbiór uczący i testowy\n');

idx_pos = find(y == 1);
idx_neg = find(y == -1);

% ZABEZPIECZENIE: Sprawdź, czy mamy wystarczająco danych
if length(idx_pos) < 2 || length(idx_neg) < 2
    error('Za mało danych w jednej z klas! Potrzeba co najmniej 2 próbek w każdej klasie.');
end

% Połowa danych z każdej klasy, max 50, min 1
n_train_pos = max(1, min(50, floor(length(idx_pos)/2)));
n_train_neg = max(1, min(50, floor(length(idx_neg)/2)));
n_train = min(n_train_pos, n_train_neg);

fprintf('   Wybrano po %d próbek z każdej klasy\n', n_train);

rng(42); % Dla powtarzalności
train_pos = idx_pos(randperm(length(idx_pos), n_train));
train_neg = idx_neg(randperm(length(idx_neg), n_train));

train_idx = [train_pos; train_neg];
test_idx = setdiff(1:length(y), train_idx);

X_train = X(train_idx, :);
y_train = y(train_idx);
X_test = X(test_idx, :);
y_test = y(test_idx);

fprintf('   Zbiór uczący: %d próbek\n', length(train_idx));
fprintf('   Zbiór testowy: %d próbek\n', length(test_idx));

%% =========================
% 6. METODA PRIMAL - UPROSZCZONA
% =========================
fprintf('\n6. Metoda PRIMAL\n');

[m, d] = size(X_train);
C = 1;

% Upewnij się, że y_train jest wektorem kolumnowym
y_train = y_train(:);

% 1. Macierz H (tylko dla w, b i ξ są w części liniowej)
H = zeros(d+1+m, d+1+m);
H(1:d, 1:d) = eye(d);

% 2. Wektor f
f = [zeros(d+1, 1); C*ones(m, 1)];

% 3. Ograniczenia: y_i*(w·x_i + b) ≥ 1 - ξ_i, ξ_i ≥ 0
A = zeros(2*m, d+1+m);

% Ograniczenia y_i*(w·x_i + b) ≥ 1 - ξ_i
for i = 1:m
    A(i, 1:d) = -y_train(i) * X_train(i, :);
    A(i, d+1) = -y_train(i);
    A(i, d+1+i) = -1;
end

% Ograniczenia ξ_i ≥ 0
for i = 1:m
    A(m+i, d+1+i) = -1;
end

b = [-ones(m, 1); zeros(m, 1)];
lb = [-inf(d+1, 1); zeros(m, 1)];

% Opcje dla quadprog
options = optimoptions('quadprog', ...
    'Display', 'off', ...
    'Algorithm', 'interior-point-convex');

fprintf('   Rozwiązywanie problemu optymalizacji...\n');
try
    tic;
    sol_primal = quadprog(H, f, A, b, [], [], lb, [], [], options);
    time_primal = toc;
    
    w_primal = sol_primal(1:d);
    b_primal = sol_primal(d+1);
    xi_primal = sol_primal(d+2:end);
    
    fprintf('   Sukces! Czas: %.4f s\n', time_primal);
    fprintf('   Błędy treningowe (ξ > 0): %d\n', sum(xi_primal > 0.001));
    fprintf('   ||w|| = %.4f\n', norm(w_primal));
    
catch ME
    fprintf('   BŁĄD w primal: %s\n', ME.message);
    fprintf('   Używam uproszczonego rozwiązania (perceptron)...\n');
    
    % Uproszczone rozwiązanie jako fallback
    w_primal = (X_train' * X_train) \ (X_train' * y_train);
    b_primal = 0;
    time_primal = 0;
end

%% =========================
% 7. METODA DUAL - UPROSZCZONA
% =========================
fprintf('\n7. Metoda DUAL\n');

% Upewnij się, że y_train jest wektorem kolumnowym
y_train = y_train(:);

% Macierz Grama
K = X_train * X_train';

% Macierz H dla problemu dualnego
H_dual = (y_train * y_train') .* K;

% Upewnij się, że H_dual jest symetryczna i dodatnio półokreślona
H_dual = (H_dual + H_dual') / 2;
H_dual = H_dual + eye(m) * 1e-8;

% Wektor f
f_dual = -ones(m, 1);

% Ograniczenia: Σα_i y_i = 0, 0 ≤ α_i ≤ C
Aeq = y_train';
beq = 0;
lb_dual = zeros(m, 1);
ub_dual = C * ones(m, 1);

options_dual = optimoptions('quadprog', 'Display', 'off');

try
    tic;
    alpha = quadprog(H_dual, f_dual, [], [], Aeq, beq, lb_dual, ub_dual, [], options_dual);
    time_dual = toc;
    
    % Oblicz w
    w_dual = zeros(d, 1);
    for i = 1:m
        w_dual = w_dual + alpha(i) * y_train(i) * X_train(i, :)';
    end
    
    % Oblicz b z wektorów wspierających
    epsilon = 1e-5;
    sv_idx = find(alpha > epsilon & alpha < C - epsilon);
    if ~isempty(sv_idx)
        b_dual = mean(y_train(sv_idx) - X_train(sv_idx, :) * w_dual);
    else
        % Jeśli brak wektorów wspierających, użyj wszystkich α > 0
        sv_idx = find(alpha > epsilon);
        if ~isempty(sv_idx)
            b_dual = mean(y_train(sv_idx) - X_train(sv_idx, :) * w_dual);
        else
            b_dual = 0;
        end
    end
    
    fprintf('   Sukces! Czas: %.4f s\n', time_dual);
    fprintf('   Wektory wspierające: %d\n', sum(alpha > epsilon));
    fprintf('   ||w|| = %.4f\n', norm(w_dual));
    
catch ME
    fprintf('   Błąd w dual: %s\n', ME.message);
    fprintf('   Używam wyników z primal jako fallback...\n');
    w_dual = w_primal;
    b_dual = b_primal;
    time_dual = time_primal;
end

%% =========================
% 8. TESTOWANIE I STATYSTYKI
% =========================
fprintf('\n8. Testowanie i statystyki\n');

% Predykcje
y_pred_primal = sign(X_test * w_primal + b_primal);
y_pred_dual = sign(X_test * w_dual + b_dual);

% Popraw wartości równe 0
y_pred_primal(y_pred_primal == 0) = 1;
y_pred_dual(y_pred_dual == 0) = 1;

% Funkcja do obliczania metryk
function [acc, prec, rec, spec, f1] = calculate_metrics(y_true, y_pred)
    TP = sum((y_pred == 1) & (y_true == 1));
    TN = sum((y_pred == -1) & (y_true == -1));
    FP = sum((y_pred == 1) & (y_true == -1));
    FN = sum((y_pred == -1) & (y_true == 1));
    
    acc = (TP + TN) / (TP + TN + FP + FN);
    
    if TP + FP > 0
        prec = TP / (TP + FP);
    else
        prec = 0;
    end
    
    if TP + FN > 0
        rec = TP / (TP + FN);
    else
        rec = 0;
    end
    
    if TN + FP > 0
        spec = TN / (TN + FP);
    else
        spec = 0;
    end
    
    if prec + rec > 0
        f1 = 2 * prec * rec / (prec + rec);
    else
        f1 = 0;
    end
end

% Oblicz metryki
[accuracy_primal, precision_primal, recall_primal, specificity_primal, f1_primal] = ...
    calculate_metrics(y_test, y_pred_primal);
[accuracy_dual, precision_dual, recall_dual, specificity_dual, f1_dual] = ...
    calculate_metrics(y_test, y_pred_dual);

%% =========================
% 9. WYNIKI
% =========================
fprintf('\n9. WYNIKI KLASYFIKACJI\n');
fprintf('   =========================================\n');
fprintf('   Metryka            PRIMAL       DUAL\n');
fprintf('   -----------------------------------------\n');
fprintf('   Dokładność        %6.2f%%     %6.2f%%\n', accuracy_primal*100, accuracy_dual*100);
fprintf('   Precyzja          %6.2f%%     %6.2f%%\n', precision_primal*100, precision_dual*100);
fprintf('   Czułość           %6.2f%%     %6.2f%%\n', recall_primal*100, recall_dual*100);
fprintf('   Swoistość         %6.2f%%     %6.2f%%\n', specificity_primal*100, specificity_dual*100);
fprintf('   F1-score          %6.4f      %6.4f\n', f1_primal, f1_dual);
fprintf('   Czas [s]          %6.4f      %6.4f\n', time_primal, time_dual);
fprintf('   =========================================\n');

%% =========================
% 10. WIZUALIZACJA (tylko jeśli mamy co najmniej 2 cechy)
% =========================
fprintf('\n10. Tworzenie wykresów...\n');

if size(X_train, 2) >= 2
    figure('Position', [100, 100, 1200, 400], 'Name', 'Klasyfikacja SVM');
    
    feat1 = 1; % Pierwsza cecha
    feat2 = 2; % Druga cecha
    
    % PRIMAL
    subplot(1, 3, 1);
    hold on; grid on;
    scatter(X_train(y_train == 1, feat1), X_train(y_train == 1, feat2), ...
        50, 'b', 'filled', 'DisplayName', 'Klasa +1');
    scatter(X_train(y_train == -1, feat1), X_train(y_train == -1, feat2), ...
        50, 'r', 'filled', 'DisplayName', 'Klasa -1');
    
    % Hiperpłaszczyzna
    x1 = linspace(min(X(:, feat1)), max(X(:, feat1)), 100);
    if abs(w_primal(feat2)) > 1e-10
        x2 = (-w_primal(feat1) * x1 - b_primal) / w_primal(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2, 'DisplayName', 'Granica');
    end
    
    xlabel('Cecha 1');
    ylabel('Cecha 2');
    title('PRIMAL - zbiór uczący');
    legend('Location', 'best');
    
    % DUAL
    subplot(1, 3, 2);
    hold on; grid on;
    scatter(X_train(y_train == 1, feat1), X_train(y_train == 1, feat2), 50, 'b', 'filled');
    scatter(X_train(y_train == -1, feat1), X_train(y_train == -1, feat2), 50, 'r', 'filled');
    
    if abs(w_dual(feat2)) > 1e-10
        x2 = (-w_dual(feat1) * x1 - b_dual) / w_dual(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2);
    end
    
    xlabel('Cecha 1');
    ylabel('Cecha 2');
    title('DUAL - zbiór uczący');
    
    % Test - wyniki
    subplot(1, 3, 3);
    hold on; grid on;
    
    % Ogranicz do maksymalnie 100 próbek dla czytelności
    n_viz = min(100, length(y_test));
    idx_viz = 1:n_viz;
    
    correct = (y_pred_primal(idx_viz) == y_test(idx_viz));
    incorrect = ~correct;
    
    scatter(X_test(correct, feat1), X_test(correct, feat2), ...
        60, 'g', 'filled', 'DisplayName', 'Poprawne');
    scatter(X_test(incorrect, feat1), X_test(incorrect, feat2), ...
        80, 'm', 'x', 'LineWidth', 2, 'DisplayName', 'Błędne');
    
    if abs(w_primal(feat2)) > 1e-10
        x2 = (-w_primal(feat1) * x1 - b_primal) / w_primal(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2, 'DisplayName', 'Granica');
    end
    
    xlabel('Cecha 1');
    ylabel('Cecha 2');
    title('PRIMAL - wyniki testowe');
    legend('Location', 'best');
else
    fprintf('   Za mało cech do wizualizacji 2D (potrzeba co najmniej 2)\n');
end

%% =========================
% 11. WNIOSKI
% =========================
fprintf('\n11. WNIOSKI:\n');
fprintf('   =============================================\n');
fprintf('   1. Skuteczność klasyfikacji: ~%.1f%%\n', max(accuracy_primal, accuracy_dual)*100);

if abs(accuracy_primal - accuracy_dual) < 0.01
    fprintf('   2. OBIE metody dają PODOBNE wyniki\n');
elseif accuracy_primal > accuracy_dual
    fprintf('   2. Metoda PRIMAL lepsza o %.2f%%\n', (accuracy_primal - accuracy_dual)*100);
else
    fprintf('   2. Metoda DUAL lepsza o %.2f%%\n', (accuracy_dual - accuracy_primal)*100);
end

% Porównanie czasu
if time_dual < time_primal
    fprintf('   3. Metoda DUAL była szybsza o %.1f%%\n', ...
        (time_primal - time_dual)/max(time_primal, eps)*100);
elseif time_primal < time_dual
    fprintf('   3. Metoda PRIMAL była szybsza o %.1f%%\n', ...
        (time_dual - time_primal)/max(time_dual, eps)*100);
else
    fprintf('   3. OBIE metody miały ten sam czas\n');
end

fprintf('   4. Różnica wektorów w: ||Δw|| = %.6f\n', norm(w_primal - w_dual));

% Analiza ważności cech
fprintf('\n   5. NAJWAŻNIEJSZE CECHY (wag w z PRIMAL):\n');
features = {'Cylinders', 'Displacement', 'Horsepower', 'Weight', ...
            'Acceleration', 'Model Year', 'Origin'};
[~, idx] = sort(abs(w_primal), 'descend');
for i = 1:min(3, length(features))
    fprintf('      %d. %s: %.4f\n', i, features{idx(i)}, w_primal(idx(i)));
end

fprintf('   =============================================\n');

%% =========================
% 12. ZAPIS WYNIKÓW
% =========================
% Zapis do plików CSV
try
    results_table = table(accuracy_primal, accuracy_dual, ...
                         precision_primal, precision_dual, ...
                         recall_primal, recall_dual, ...
                         specificity_primal, specificity_dual, ...
                         f1_primal, f1_dual, ...
                         time_primal, time_dual, ...
                         'VariableNames', {'Acc_Primal', 'Acc_Dual', ...
                                           'Prec_Primal', 'Prec_Dual', ...
                                           'Rec_Primal', 'Rec_Dual', ...
                                           'Spec_Primal', 'Spec_Dual', ...
                                           'F1_Primal', 'F1_Dual', ...
                                           'Time_Primal', 'Time_Dual'});
    
    writetable(results_table, 'svm_wyniki.csv');
    
    % Zapis wektorów
    csvwrite('wektor_w_primal.csv', w_primal);
    csvwrite('wektor_w_dual.csv', w_dual);
    csvwrite('przesuniecie_b.csv', [b_primal; b_dual]);
    
    fprintf('\nWyniki zapisano do plików:\n');
    fprintf('   - svm_wyniki.csv (metryki)\n');
    fprintf('   - wektor_w_primal.csv\n');
    fprintf('   - wektor_w_dual.csv\n');
    fprintf('   - przesuniecie_b.csv\n');
    
catch ME
    fprintf('\nUWAGA: Nie udało się zapisać wyników: %s\n', ME.message);
end

fprintf('\n=== KONIEC ===\n');