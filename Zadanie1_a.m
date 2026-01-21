diary sympleksALG

A = [3 -1 3 0 0 1 0; 
     2 3 3 -1 0 0 1; 
     -3 2 3 0 1 0 0]

% ====================================================
% FAZA I - MINIMALIZACJA SUMY ZMIENNYCH SZTUCZNYCH
% ====================================================

% Wektor kosztów dla fazy I: 
% Zmienne pierwotne i dopełniające mają koszt 0
% Zmienne sztuczne mają koszt 1 (minimalizujemy ich sumę)
c = [0; 0; 0; 0; 0; 1; 1]

% --- KROK 0: INICJALIZACJA ---
% Początkowa baza: zmienne sztuczne (x₆, x₇) i zmienna dopełniająca (x₅)
B = [6; 7; 5]

% Początkowe zmienne niebazowe: x₁, x₂, x₃, x₄
N = [1; 2; 3; 4]

% Wektor prawych stron ograniczeń
b = [10; 16; 16]

% --- ITERACJA 1 ---
% KROK 1: Wyznaczenie bazowego rozwiązania dopuszczalnego
bf = (A(:,B))^(-1) * b

% KROK 2: Obliczenie zredukowanych kosztów dla zmiennych niebazowych
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej do bazy (najbardziej ujemny zredukowany koszt)
[cfq, q] = min(cfN)

% KROK 4: cfq = -6 < 0 → kontynuujemy algorytm
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test  
bf ./ afq

% Wybór: minimalny dodatni iloraz w wierszu 2 => p = 2
p = 2 

% KROK 7: Wymiana zmiennych (x₃ wchodzi do bazy, x₇ wychodzi)
l = B(p)
B(p) = N(q)
N(q) = l

% --- ITERACJA 2 ---
% KROK 1: Nowe bazowe rozwiązanie dopuszczalne
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór nowej zmiennej wchodzącej
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 5: Kierunek poprawy
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test 
bf ./ afq

% Wybór: minimalny dodatni iloraz w wierszu 2 => p = 2
p = 2

% KROK 7: Wymiana zmiennych 
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 3 ---
% KROK 1: Nowe bazowe rozwiązanie
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty  
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q] = min(cfN)

% cfq = -1.5 < 0 => kontynuujemy algorytm

% KROK 1 (ponownie): Wyznaczenie bazowego rozwiązania
bf = (A(:,B))^(-1) * b

% KROK 2 (ponownie): Nowe zredukowane koszty
cfN = c(N,:) - A(:,N)'*(A(:,B)^(-1))'*c(B,:)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q] = min(cfN)

% KROK 5: Obliczenie kierunku poprawy
afq = (A(:,B))^(-1) * A(:,N(q))

% KROK 6: Test ilorazowy
bf ./ afq

% Wybór: minimalny dodatni iloraz w wierszu 1 → p = 1
p = 1

% KROK 7: Wymiana zmiennych (x₄ wchodzi do bazy, x₆ wychodzi)
l = B(p)
B(p) = N(q)
N(q) = l

% --- ITERACJA 4 ---
% KROK 1: Nowe bazowe rozwiązanie
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N,:) - A(:,N)'*(A(:,B)^(-1))'*c(B,:)

% KROK 3: Test cfq
[cfq, q] = min(cfN)

% KONIEC FAZY I: cfq = 0 >+ 0 => znaleziono bazowe rozwiązanie dopuszczalne
% Wszystkie zmienne sztuczne zostały usunięte z bazy

% ====================================================
% FAZA II - MINIMALIZACJA ORYGINALNEJ FUNKCJI CELU
% ====================================================

% Usunięcie zmiennych sztucznych z macierzy A
% Zachowujemy tylko zmienne pierwotne (x₁-x₃) i dopełniające (x₄, x₅)
A = A(:, 1:5)

% Oryginalny wektor kosztów
c = [9; -5; 0; 0; 0]

% Nowe zbiory zmiennych na podstawie końcowej bazy z fazy I
% Zmienne niebazowe: x₂, x₃
N = [2; 3]

% Zmienne bazowe: x₄, x₁, x₅
B = [4; 1; 5]

% --- ITERACJA 1 fazy II ---
% KROK 1: Bazowe rozwiązanie dopuszczalne (kontynuacja z fazy I)
bf = (A(:,B))^(-1) * b

% KROK 2: Zredukowane koszty dla oryginalnej funkcji celu
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq = -9 < 0 → kontynuujemy algorytm
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test
bf ./ afq

% KROK 7: Wymiana zmiennych (x₃ wchodzi do bazy, x₁ wychodzi)
p = 2
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 2 fazy II ---
% KROK 1: Nowe bazowe rozwiązanie
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq = -5 < 0 → kontynuujemy algorytm
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test ilorazowy
bf ./ afq

% KROK 7: Wymiana zmiennych (x₂ wchodzi do bazy, x₄ wychodzi)
p = 1
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 3 fazy II ---
% KROK 1: Nowe bazowe rozwiązanie
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq = -1.25 < 0 → kontynuujemy algorytm
% KROK 5: Kierunek poprawy
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test ilorazowy
bf ./ afq

% KROK 7: Wymiana zmiennych (x₄ wchodzi do bazy, x₅ wychodzi)
p = 3
l = B(p)
B(p) = q
N(q == N) = l

% --- ITERACJA 4 fazy II ---
% KROK 1: Nowe bazowe rozwiązanie
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q_idx] = min(cfN)

% --- ITERACJA 5 fazy II  ---
% KROK 1: Nowe bazowe rozwiązanie dopuszczalne
bf = (A(:,B))^(-1) * b

% KROK 2: Nowe zredukowane koszty
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)

% KROK 3: Wybór zmiennej wchodzącej
[cfq, q_idx] = min(cfN)
q = N(q_idx)

% KROK 4: cfq = -1 < 0 → kontynuujemy algorytm
% KROK 5: Kierunek poprawy
afq = (A(:,B))^(-1) * A(:,q)

% KROK 6: Test ilorazowy
bf ./ afq

% Wybór: minimalny dodatni iloraz w wierszu 2 → p = 2
p = 2

% KROK 7: Wymiana zmiennych (x₁ wchodzi do bazy, x₃ wychodzi)
l = B(p)
B(p) = q
N(q == N) = l

%Sprawdzenie cfq 
bf = (A(:,B))^(-1) * b
cfN = c(N) - A(:,N)' * ((A(:,B))^(-1))' * c(B)
[cfq, q_idx] = min(cfN)

% KONIEC ALGORYTMU: cfq = 2 > 0 → osiągnięto rozwiązanie optymalne

% ====================================================
% ROZWIĄZANIE OPTYMALNE
% ====================================================

% Konstrukcja wektora rozwiązania
x = zeros(5,1)      % Wektor dla x₁, x₂, x₃, x₄, x₅
x(B) = bf           % Wartości zmiennych bazowych

% Ekstrakcja wartości 
x1 = x(1)
x2 = x(2)
x3 = x(3)



diary off