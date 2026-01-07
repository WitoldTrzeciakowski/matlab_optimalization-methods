clear all
clc
diary SympleksTab
% Minimalizacja 9x1 - 5x2 jest równoważna maksymalizacji -9x1 + 5x2.
c = [9 -5 0]'

% Macierz po sprowadzeniu do równań
A = [ 3  -1  3   0  0  1  0  0
      2   3  3  -1  0  0  1  0
     -3   2  3   0 -1  0  0  1 ]

b = [10
     16
     16]

% FAZA I: minimalizacja sumy zmiennych sztucznych: w = a1 + a2 + a3
% Współczynniki funkcji celu fazy I: 0 dla wszystkich zmiennych oprócz zmiennych sztucznych, które mają 1.
c1 = [0 0 0 0 0 1 1 1]'

% Tablica sympleks dla fazy I: wiersz funkcji celu (c1' i 0) oraz macierz A i wektor b.
T = [c1' 0
     A   b]

% Zerowanie wiersza celu (a1,a2,a3 w bazie) - operacja eliminacji, aby uzyskać postać kanoniczną.
T(1,:) = T(1,:) - T(2,:) - T(3,:) - T(4,:)

%% ===================== FAZA I – ITERACJA 1 =====================
% Wybór zmiennej wchodzącej: minimalna wartość w wierszu celu (optymalizacja minimalizacji).
[~, q] = min(T(1,1:8))

% Obliczenie ilorazów dla wyboru zmiennej wychodzącej.
ratios = T(2:4,9) ./ T(2:4,q)
ratios(T(2:4,q) <= 0) = Inf   % Jeśli mianownik <=0, to iloraz ustawiamy na Inf (nie bierzemy pod uwagę).
[~, r_idx] = min(ratios)      % Wybór najmniejszego nieujemnego ilorazu.
r = r_idx + 1                 % Dostosowanie indeksu, bo ratios dotyczyły wierszy 2-4.

% Operacja pivotowania: przeskalowanie wiersza r oraz aktualizacja pozostałych wierszy, w tym wiersza celu.
T(r,:) = T(r,:) / T(r,q)
T(1,:) = T(1,:) - T(1,q)*T(r,:)
T(3,:) = T(3,:) - T(3,q)*T(r,:)
T(4,:) = T(4,:) - T(4,q)*T(r,:)

T

%% ===================== FAZA I – ITERACJA 2 =====================
[~, q] = min(T(1,1:8))

ratios = T(2:4,9) ./ T(2:4,q)
ratios(T(2:4,q) <= 0) = Inf
[~, r_idx] = min(ratios)
r = r_idx + 1

T(r,:) = T(r,:) / T(r,q)
T(1,:) = T(1,:) - T(1,q)*T(r,:)
T(2,:) = T(2,:) - T(2,q)*T(r,:)
T(4,:) = T(4,:) - T(4,q)*T(r,:)

T

%% ===================== FAZA I – ITERACJA 3 =====================
[~, q] = min(T(1,1:8))

ratios = T(2:4,9) ./ T(2:4,q)
ratios(T(2:4,q) <= 0) = Inf
[~, r_idx] = min(ratios)
r = r_idx + 1

T(r,:) = T(r,:) / T(r,q)
T(1,:) = T(1,:) - T(1,q)*T(r,:)
T(2,:) = T(2,:) - T(2,q)*T(r,:)
T(3,:) = T(3,:) - T(3,q)*T(r,:)

T

%% ===================== FAZA II =====================
% Po fazie I, jeśli zmienne sztuczne są niebazowe, to tworzymy tablicę dla fazy II.
% Usuwamy kolumny zmiennych sztucznych (kolumny 6,7,8) i wiersz celu fazy I.
% Z tablicy T bierzemy tylko wiersze 2-4 (ograniczenia) i kolumny 1-5 (zmienne x1,x2,x3,s1,s2) oraz kolumnę prawych stron (9).
T2 = T(2:4,[1:5 9])

% Wstawiamy wiersz celu dla oryginalnego zadania.
% Oryginalne zadanie to min 9x1 - 5x2, co jest równoważne max -9x1 + 5x2.
% Dlatego w fazie II ustawiamy wiersz celu: [-9 5 0 0 0 0] (dla zmiennych x1,x2,x3,s1,s2 i prawej strony).
T2 = [-9 5 0 0 0 0
       T2]
T2(1,:) = T2(1,:) - T2(1,2)*T2(3,:)

T2

%% ===================== ROZWIĄZANIE =====================
x1 = 0
x2 = T2(3,6)
x3 = T2(2,6)