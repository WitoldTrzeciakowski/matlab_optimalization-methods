diary sympleksTAB
clear all
clc

%% ===================== DANE =====================
c = [9 -5 0]'  % wektor kosztow: min 9x1 - 5x2 + 0x3

% Macierz A dla: x1 x2 x3 s1 s2 a1 a2
A = [ 3  -1  3   0  0  1  0
      2   3  3  -1  0  0  1
     -3   2  3   0  1  0  0 ]

b = [10
     16
     16]

% FAZA I: minimalizacja sumy zmiennych sztucznych
c1 = [0 0 0 0 0 1 1]'  % koszty fazy I

%% ===================== FAZA I =====================
% Krok 0: Inicjalizacja tablicy sympleks
T = [c1' 0
     A   b]

% Zerowanie wiersza celu dla zmiennych bazowych (a1, a2)
T(1,:) = T(1,:) - T(2,:) - T(3,:)

% ===============================================
% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% ===============================================
[min_val, q] = min(T(1,1:7))

% ===============================================
% Krok 2. Wybór zmiennej wychodzącej (wiersza głównego)
% ===============================================
ratios = T(2:4,8) ./ T(2:4,q)
ratios(T(2:4,q) <= 0) = Inf
[min_ratio, r_idx] = min(ratios)
r = r_idx + 1

% ===============================================
% Krok 3. Aktualizacja tablicy (pivoting)
% ===============================================
T(r,:) = T(r,:) / T(r,q)
T(1,:) = T(1,:) - T(1,q) * T(r,:)
if r ~= 2, T(2,:) = T(2,:) - T(2,q) * T(r,:), end
if r ~= 3, T(3,:) = T(3,:) - T(3,q) * T(r,:), end
if r ~= 4, T(4,:) = T(4,:) - T(4,q) * T(r,:), end

T

% ===============================================
% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% ===============================================
[min_val, q] = min(T(1,1:7))

% ===============================================
% Krok 2. Wybór zmiennej wychodzącej (wiersza głównego)
% ===============================================
ratios = T(2:4,8) ./ T(2:4,q)
ratios(T(2:4,q) <= 0) = Inf
[min_ratio, r_idx] = min(ratios)
r = r_idx + 1

% ===============================================
% Krok 3. Aktualizacja tablicy (pivoting)
% ===============================================
T(r,:) = T(r,:) / T(r,q)
T(1,:) = T(1,:) - T(1,q) * T(r,:)
if r ~= 2, T(2,:) = T(2,:) - T(2,q) * T(r,:), end
if r ~= 3, T(3,:) = T(3,:) - T(3,q) * T(r,:), end
if r ~= 4, T(4,:) = T(4,:) - T(4,q) * T(r,:), end

T

w = T(1,8)  % wartość funkcji celu fazy I

%% ===================== FAZA II =====================
% Tworzenie tablicy bez zmiennych sztucznych
T2 = T(2:4,[1:5 8])  % kolumny: x1,x2,x3,s1,s2 i b

% Wstawienie wiersza celu oryginalnego: dla max -9x1 + 5x2
T2 = [-9 5 0 0 0 0
       T2]

% Korekta wiersza celu dla zmiennych bazowych
% Zmienne bazowe: x3 (wiersz 2, kolumna 3), x2 (wiersz 3, kolumna 2), s2 (wiersz 4, kolumna 5)
% Wyzerowanie dla x2
T2(1,:) = T2(1,:) - T2(1,2) * T2(3,:)
% Wyzerowanie dla x3
T2(1,:) = T2(1,:) - T2(1,3) * T2(2,:)
% Wyzerowanie dla s2
T2(1,:) = T2(1,:) - T2(1,5) * T2(4,:)

T2

% ===============================================
% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% ===============================================
[max_val, q] = max(T2(1,1:5))

% ===============================================
% Krok 2. Wybór zmiennej wychodzącej (wiersza głównego)
% ===============================================
ratios = T2(2:4,6) ./ T2(2:4,q)
ratios(T2(2:4,q) <= 0) = Inf
[min_ratio, r_idx] = min(ratios)
r = r_idx + 1

% ===============================================
% Krok 3. Aktualizacja tablicy (pivoting)
% ===============================================
T2(r,:) = T2(r,:) / T2(r,q)
T2(1,:) = T2(1,:) - T2(1,q) * T2(r,:)
if r ~= 2, T2(2,:) = T2(2,:) - T2(2,q) * T2(r,:), end
if r ~= 3, T2(3,:) = T2(3,:) - T2(3,q) * T2(r,:), end
if r ~= 4, T2(4,:) = T2(4,:) - T2(4,q) * T2(r,:), end

T2

% ===============================================
% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% ===============================================
[max_val, q] = max(T2(1,1:5))
ratios = T2(2:4,6) ./ T2(2:4,q)
ratios(T2(2:4,q) <= 0) = Inf
[min_ratio, r_idx] = min(ratios)
r = r_idx + 1

% ===============================================
% Krok 3. Aktualizacja tablicy (pivoting)
% ===============================================
T2(r,:) = T2(r,:) / T2(r,q)
T2(1,:) = T2(1,:) - T2(1,q) * T2(r,:)
if r ~= 2, T2(2,:) = T2(2,:) - T2(2,q) * T2(r,:), end
if r ~= 3, T2(3,:) = T2(3,:) - T2(3,q) * T2(r,:), end
if r ~= 4, T2(4,:) = T2(4,:) - T2(4,q) * T2(r,:), end

T2

% ===============================================
% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% ===============================================
[max_val, q] = max(T2(1,1:5))
% Jeśli max_val <= 0, rozwiązanie optymalne

%% ===================== ROZWIAZANIE =====================
% Odczyt wartości zmiennych bazowych
% Po ostatniej iteracji zmienne bazowe to: x1 (wiersz 2), x2 (wiersz 3), s1 (wiersz 4)
x1 = T2(2,6)
x2 = T2(3,6)
s1 = T2(4,6)

% Zmienne niebazowe
x3 = 0
s2 = 0

% Wartość funkcji celu: min 9x1 - 5x2
z = 9*x1 - 5*x2

% Sprawdzenie ograniczeń
lewa_strona = A(:,1:5) * [x1; x2; x3; s1; s2]
prawa_strona = b

% Sprawdzenie nieujemności
x1, x2, x3, s1, s2
diary off;