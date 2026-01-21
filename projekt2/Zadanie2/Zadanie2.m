%% KLASYFIKACJA SVM - AUTO MPG
clear variables
close all

%% 1. WCZYTANIE DANYCH
filename = 'auto-mpg.csv';

% Wczytanie danych z obsługą brakujących wartości
data = readmatrix(filename, ...
    'FileType', 'text', ...
    'Delimiter', {' ', '\t'}, ...
    'ConsecutiveDelimitersRule', 'join', ...
    'TreatAsMissing', '?', ...
    'NumHeaderLines', 0);

% Pobranie tylko kolumn liczbowych
if size(data, 2) > 8
    data = data(:, 1:8);
end

% Usunięcie wierszy z brakującymi danymi
data_clean = data(~any(isnan(data), 2), :);

%% 2. PRZYGOTOWANIE DANYCH
mpg = data_clean(:, 1);
X = data_clean(:, 2:end);

%% 3. PODZIAŁ NA KLASY
med_mpg = median(mpg);
y = ones(size(mpg));
y(mpg < med_mpg) = -1;

%% 4. NORMALIZACJA CECH
mean_X = mean(X);
std_X = std(X);
std_X(std_X == 0) = 1;
X = (X - mean_X) ./ std_X;

%% 5. PODZIAŁ NA ZBIÓR UCZĄCY I TESTOWY
idx_pos = find(y == 1);
idx_neg = find(y == -1);

n_train = min(50, floor(min(length(idx_pos), length(idx_neg))/2));

rng(42);
train_pos = idx_pos(randperm(length(idx_pos), n_train));
train_neg = idx_neg(randperm(length(idx_neg), n_train));
train_idx = [train_pos; train_neg];
test_idx = setdiff(1:length(y), train_idx);

X_train = X(train_idx, :);
y_train = y(train_idx);
X_test = X(test_idx, :);
y_test = y(test_idx);

%% 6. METODA PRIMAL
[m, d] = size(X_train);
C = 1;
y_train = y_train(:);

H = zeros(d+1+m, d+1+m);
H(1:d, 1:d) = eye(d);
f = [zeros(d+1, 1); C*ones(m, 1)];

A = zeros(2*m, d+1+m);
for i = 1:m
    A(i, 1:d) = -y_train(i) * X_train(i, :);
    A(i, d+1) = -y_train(i);
    A(i, d+1+i) = -1;
    A(m+i, d+1+i) = -1;
end

b = [-ones(m, 1); zeros(m, 1)];
lb = [-inf(d+1, 1); zeros(m, 1)];

options = optimoptions('quadprog', 'Display', 'off');
sol_primal = quadprog(H, f, A, b, [], [], lb, [], [], options);
w_primal = sol_primal(1:d);
b_primal = sol_primal(d+1);
xi_primal = sol_primal(d+2:end);

%% 7. METODA DUAL
K = X_train * X_train';
H_dual = (y_train * y_train') .* K;
H_dual = (H_dual + H_dual') / 2;
H_dual = H_dual + eye(m) * 1e-8;

f_dual = -ones(m, 1);
Aeq = y_train';
beq = 0;
lb_dual = zeros(m, 1);
ub_dual = C * ones(m, 1);

alpha = quadprog(H_dual, f_dual, [], [], Aeq, beq, lb_dual, ub_dual, [], options);

w_dual = zeros(d, 1);
for i = 1:m
    w_dual = w_dual + alpha(i) * y_train(i) * X_train(i, :)';
end

epsilon = 1e-5;
sv_idx = find(alpha > epsilon & alpha < C - epsilon);
if ~isempty(sv_idx)
    b_dual = mean(y_train(sv_idx) - X_train(sv_idx, :) * w_dual);
else
    sv_idx = find(alpha > epsilon);
    b_dual = mean(y_train(sv_idx) - X_train(sv_idx, :) * w_dual);
end

%% 8. TESTOWANIE
y_pred_primal = sign(X_test * w_primal + b_primal);
y_pred_dual = sign(X_test * w_dual + b_dual);
y_pred_primal(y_pred_primal == 0) = 1;
y_pred_dual(y_pred_dual == 0) = 1;

TP_primal = sum((y_pred_primal == 1) & (y_test == 1));
TN_primal = sum((y_pred_primal == -1) & (y_test == -1));
FP_primal = sum((y_pred_primal == 1) & (y_test == -1));
FN_primal = sum((y_pred_primal == -1) & (y_test == 1));
accuracy_primal = (TP_primal + TN_primal) / length(y_test);

TP_dual = sum((y_pred_dual == 1) & (y_test == 1));
TN_dual = sum((y_pred_dual == -1) & (y_test == -1));
FP_dual = sum((y_pred_dual == 1) & (y_test == -1));
FN_dual = sum((y_pred_dual == -1) & (y_test == 1));
accuracy_dual = (TP_dual + TN_dual) / length(y_test);

%% 9. WIZUALIZACJA
if size(X_train, 2) >= 2
    figure('Position', [100, 100, 1200, 400]);
    feat1 = 1;
    feat2 = 2;
    
    subplot(1, 3, 1);
    hold on; grid on;
    scatter(X_train(y_train == 1, feat1), X_train(y_train == 1, feat2), 50, 'b', 'filled');
    scatter(X_train(y_train == -1, feat1), X_train(y_train == -1, feat2), 50, 'r', 'filled');
    x1 = linspace(min(X(:, feat1)), max(X(:, feat1)), 100);
    if abs(w_primal(feat2)) > 1e-10
        x2 = (-w_primal(feat1) * x1 - b_primal) / w_primal(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2);
    end
    
    subplot(1, 3, 2);
    hold on; grid on;
    scatter(X_train(y_train == 1, feat1), X_train(y_train == 1, feat2), 50, 'b', 'filled');
    scatter(X_train(y_train == -1, feat1), X_train(y_train == -1, feat2), 50, 'r', 'filled');
    if abs(w_dual(feat2)) > 1e-10
        x2 = (-w_dual(feat1) * x1 - b_dual) / w_dual(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2);
    end
    xlabel('Cecha 1'); ylabel('Cecha 2'); title('DUAL - zbiór uczący');
    
    subplot(1, 3, 3);
    hold on; grid on;
    correct = (y_pred_primal == y_test);
    scatter(X_test(correct, feat1), X_test(correct, feat2), 60, 'g', 'filled');
    scatter(X_test(~correct, feat1), X_test(~correct, feat2), 80, 'm', 'x', 'LineWidth', 2);
    if abs(w_primal(feat2)) > 1e-10
        x2 = (-w_primal(feat1) * x1 - b_primal) / w_primal(feat2);
        plot(x1, x2, 'k-', 'LineWidth', 2);
    end
    xlabel('Cecha 1'); ylabel('Cecha 2'); title('PRIMAL - wyniki testowe');
end

%% 10. ZAPIS WYNIKÓW
results = [accuracy_primal, accuracy_dual];
csvwrite('svm_wyniki.csv', results);
csvwrite('wektor_w_primal.csv', w_primal);
csvwrite('wektor_w_dual.csv', w_dual);
csvwrite('przesuniecie_b.csv', [b_primal, b_dual]);