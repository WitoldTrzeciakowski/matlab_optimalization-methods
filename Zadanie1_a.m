% ===== DWUFAZOWA ALGEBRAICZNA METODA SYMPLEKS =====
% Implementacja dokładnie według przykładu z PDF

% Dane wejściowe
A = [3 -1 3 0 0 1 0; 
     2 3 3 -1 0 0 1; 
     -3 2 3 0 1 0 0]

b = [10; 16; 16]

% ========================================
% FAZA I - minimalizacja sumy zmiennych sztucznych
% ========================================

c = [0; 0; 0; 0; 0; 1; 1]

% --- KROK 0: Inicjalizacja ---
B = [6; 7; 5]
N = [1; 2; 3; 4]

% KROK 1: Rozwiązanie bazowe
bf = (A(:,B))^(-1) * b

% KROK 2: Zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q] = min(cfN)
q = N(q)

% KROK 4: Warunek stopu - cfq < 0, więc kontynuujemy
% KROK 5: Przetransformowana kolumna
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Wybór zmiennej wychodzącej
ratios = bf ./ afq
ratios(afq <= 0) = 1e10
[min_ratio, p] = min(ratios)

% KROK 7: Wymiana zmiennych
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 1 ---
% KROK 1
bf = (A(:,B))^(-1) * b

% KROK 2
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq < 0, kontynuujemy
% KROK 5
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6
ratios = bf ./ afq
ratios(afq <= 0) = 1e10
[min_ratio, p] = min(ratios)

% KROK 7
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 2 ---
% KROK 1
bf = (A(:,B))^(-1) * b

% KROK 2
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3
[cfq, q_idx] = min(cfN)

% KROK 4: cfq = 0, STOP FAZY I
% Wartość funkcji celu fazy I
w = c(B)' * bf

% ========================================
% FAZA II - minimalizacja oryginalnej funkcji
% ========================================

% Usuwamy zmienne sztuczne z macierzy A
A = A(:, 1:5)

% Oryginalny wektor kosztów
c = [9; -5; 0; 0; 0]

% Nowe indeksy zmiennych niebazowych (tylko zmienne pierwotne i dopełniające)
N = [3; 4]

% Baza po fazie I (bez zmiennych sztucznych)
B = [1; 2; 5]

% --- KROK 0 fazy II ---
% KROK 1
bf = (A(:,B))^(-1) * b

% KROK 2
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq < 0, kontynuujemy
% KROK 5
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6
ratios = bf ./ afq
ratios(afq <= 0) = 1e10
[min_ratio, p] = min(ratios)

% KROK 7
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 1 fazy II ---
% KROK 1
bf = (A(:,B))^(-1) * b

% KROK 2
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3
[cfq, q_idx] = min(cfN)

% KROK 4: cfq >= 0, STOP - rozwiązanie optymalne

% ========================================
% ROZWIĄZANIE OPTYMALNE
% ========================================

% Wektor rozwiązania
x = zeros(5,1)
x(B) = bf

% Wartość funkcji celu
z_opt = c' * x

% Wypisanie wyników
x1 = x(1)
x2 = x(2)
x3 = x(3)

% Weryfikacja ograniczeń oryginalnych
check1 = -3*x1 + x2 - 3*x3
check2 = -2*x1 - 3*x2 - 3*x3
check3 = 3*x1 - 2*x2 - 3*x3

% Warunki nieujemności
nonneg_check = [x1 >= 0, x2 >= 0, x3 >= 0]