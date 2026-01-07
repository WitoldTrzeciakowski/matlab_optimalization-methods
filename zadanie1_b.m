clear all
clc

% ====================================================
% PROBLEM ORYGINALNY:
% Maksymalizacja: 9x₁ - 5x₂
% Ograniczenia:
%   3x₁ - x₂ + 3x₃ = 10          (równość)
%   2x₁ + 3x₂ + 3x₃ ≤ 16         (nierówność ≤)
%   -3x₁ + 2x₂ + 3x₃ ≤ 16        (nierówność ≤)
%   x₁, x₂, x₃ ≥ 0
% ====================================================

% ====================================================
% FAZA I - Minimalizacja sumy zmiennych sztucznych
% ====================================================

% Macierz współczynników A dla zmiennych:
% x₁, x₂, x₃, s₂, s₃, a₁
% gdzie: s₂, s₃ - zmienne dopełniające (slack) dla 2. i 3. ograniczenia
%        a₁ - zmienna sztuczna dla 1. ograniczenia (równość)
A = [3 -1 3 0 0 1
     2  3 3 1 0 0
    -3  2 3 0 1 0]

% Wektor prawej strony
b = [10; 16; 16]

% Wektor kosztów dla fazy I: minimalizacja a₁
c = [0 0 0 0 0 1]'

% Liczba zmiennych i ograniczeń
n = 6  % x₁, x₂, x₃, s₂, s₃, a₁
m = 3  % liczba ograniczeń

% Zakres indeksów wierszy macierzy A w tablicy (wiersze 2..m+1)
i1_m = 2:(m+1)

% ===============================================
% Krok 0. Inicjalizacja tablicy sympleksu Fazy I
% ===============================================
T = [c', 0; A, b]

% ===============================================
% Krok 1. Wyzerowanie wiersza 0 dla zmiennej bazowej a₁
% Wiersz 0: [0 0 0 0 0 1 0]
% Wiersz 2: [3 -1 3 0 0 1 10] (gdzie a₁ ma współczynnik 1)
% Odejmujemy wiersz 2 od wiersza 0
% ===============================================
T(1,:) = T(1,:) - T(2,:)

% ===============================================
% ITERACJA 1 Fazy I
% ===============================================

% Krok 1. Wybór zmiennej wchodzącej (kolumny głównej)
% Szukamy najbardziej ujemnego współczynnika w wierszu 0
[min_val, q] = min(T(1,1:end-1))
q  % wyświetlamy numer kolumny

% Krok 2. Wybór zmiennej wychodzącej (wiersza głównego)
% Obliczamy ilorazy tylko dla dodatnich współczynników w kolumnie q
ratios = T(i1_m, n+1) ./ T(i1_m, q)
ratios(T(i1_m, q) <= 0) = Inf
[min_ratio, r_idx] = min(ratios)
r = i1_m(r_idx)  % numer wiersza w T

% Krok 3. Aktualizacja tablicy (pivoting)
% Dzielimy wiersz główny przez element główny
T(r,:) = T(r,:) / T(r,q)

% Aktualizacja wiersza 0 (funkcja celu)
T(1,:) = T(1,:) - T(1,q) * T(r,:)

% Aktualizacja wiersza 3
T(3,:) = T(3,:) - T(3,q) * T(r,:)

% Aktualizacja wiersza 4
T(4,:) = T(4,:) - T(4,q) * T(r,:)

% ===============================================
% Sprawdzenie czy Faza I zakończona (w = 0)
% ===============================================
w = T(1,n+1)

% ===============================================
% FAZA II - Przygotowanie tablicy dla oryginalnego problemu
% ===============================================

% Usuwamy kolumnę zmiennej sztucznej a₁ (kolumna 6)
T2 = T(2:end, [1:5, n+1])

% Dodajemy wiersz z oryginalną funkcją celu
% Maksymalizacja 9x₁ - 5x₂ odpowiada minimalizacji -9x₁ + 5x₂
c_original = [-9 5 0 0 0]'
T2 = [c_original', 0; T2]

% Nowe wymiary
n2 = 5  % liczba zmiennych w fazie II: x₁, x₂, x₃, s₂, s₃
m2 = 3  % liczba ograniczeń
i1_m2 = 2:(m2+1)

% ===============================================
% Wyzerowanie wiersza 0 dla zmiennych bazowych
% ===============================================
% Zmienne bazowe: x₁ (wiersz 2, kolumna 1), s₂ (wiersz 3, kolumna 4), s₃ (wiersz 4, kolumna 5)

% Dla x₁: współczynnik w wierszu 0 wynosi -9, odejmujemy -9 × wiersz 2
T2(1,:) = T2(1,:) - T2(1,1) * T2(2,:)

% Dla s₂: współczynnik w wierszu 0 wynosi 0, nic nie robimy
% Dla s₃: współczynnik w wierszu 0 wynosi 0, nic nie robimy

% ===============================================
% Sprawdzenie optymalności w fazie II
% Wszystkie współczynniki w wierszu 0 są nieujemne → rozwiązanie optymalne
% ===============================================

% ===============================================
% Odczyt rozwiązania
% ===============================================
x = zeros(n2,1)

% x₁ jest w wierszu 2, kolumna 1
x(1) = T2(2, n2+1)

% s₂ jest w wierszu 3, kolumna 4  
x(4) = T2(3, n2+1)

% s₃ jest w wierszu 4, kolumna 5
x(5) = T2(4, n2+1)

% x₂ i x₃ są niebazowe, więc mają wartość 0

% ===============================================
% Weryfikacja ograniczeń
% ===============================================
% Ograniczenie 1: 3x₁ - x₂ + 3x₃ = 10
check1 = 3*x(1) - x(2) + 3*x(3)

% Ograniczenie 2: 2x₁ + 3x₂ + 3x₃ + s₂ = 16
check2 = 2*x(1) + 3*x(2) + 3*x(3) + x(4)

% Ograniczenie 3: -3x₁ + 2x₂ + 3x₃ + s₃ = 16
check3 = -3*x(1) + 2*x(2) + 3*x(3) + x(5)

% Wartość oryginalnej funkcji celu (maksymalizacja)
z = 9*x(1) - 5*x(2)

% ===============================================
% Wypisanie wyników
% ===============================================
disp('Rozwiązanie optymalne:')
disp(['x₁ = ', num2str(x(1))])
disp(['x₂ = ', num2str(x(2))])
disp(['x₃ = ', num2str(x(3))])
disp(['s₂ = ', num2str(x(4))])
disp(['s₃ = ', num2str(x(5))])
disp(['Wartość funkcji celu z = ', num2str(z)])

disp('Weryfikacja ograniczeń:')
disp(['3x₁ - x₂ + 3x₃ = ', num2str(check1), ' (powinno być 10)'])
disp(['2x₁ + 3x₂ + 3x₃ + s₂ = ', num2str(check2), ' (powinno być 16)'])
disp(['-3x₁ + 2x₂ + 3x₃ + s₃ = ', num2str(check3), ' (powinno być 16)'])