function [x_opt, f_val, historia_x] = solver_sr1_armijo(fun_uchwyt, x0, max_iter, tol)
    
    % Parametry metody
    eta = 0.1;      % Parametr Armijo
    beta = 0.5;     % Krok redukcji w Armijo
    epsilon_sr1 = 1e-8; % Zabezpieczenie mianownika w SR1
    
    x = x0(:);
    n = length(x);
    B = eye(n);
    
    % Inicjalizacja historii
    historia_x = x;
    
    [f_curr, g_curr] = fun_uchwyt(x);
    
    for k = 1:max_iter
        % 1. Sprawdzenie kryterium stopu
        if norm(g_curr) < tol
            disp(['Zbieżność osiągnięta w iteracji: ', num2str(k)]);
            break;
        end
        
        % 2. Wyznaczenie kierunku d_k: B_k * d_k = -g_k
        d = -B \ g_curr;
        
        % Sprawdzenie czy kierunek jest kierunkiem spadku
        if g_curr' * d > 0
            d = -g_curr;
            B = eye(n);
        end
        
        % 3. Dobór długości kroku (Reguła Armijo)
        alpha = 1;
        iter_armijo = 0;
        
        % Pętla while sprawdzająca warunek Armijo
        while true
            x_new = x + alpha * d;
            [f_new, ~] = fun_uchwyt(x_new);
            
            if f_new <= f_curr + eta * alpha * (g_curr' * d)
                break; % Warunek spełniony
            end
            
            alpha = alpha * beta;
            iter_armijo = iter_armijo + 1;
            if iter_armijo > 50
                break; % Zabezpieczenie przed pętlą nieskończoną
            end
        end
        
        % 4. Aktualizacja zmiennych
        x_next = x + alpha * d;
        [f_next, g_next] = fun_uchwyt(x_next);
        
        % 5. Aktualizacja macierzy B (SR1)
        s = x_next - x;
        y = g_next - g_curr;
        
        % Obliczenie mianownika SR1
        Bs = B * s;
        mianownik = (y - Bs)' * s;
        
        % Warunek stabilności SR1
        if abs(mianownik) > epsilon_sr1 * norm(s) * norm(y - Bs)
            term = (y - Bs);
            B = B + (term * term') / mianownik;
        end
        
        % Przejście do następnej iteracji
        x = x_next;
        f_curr = f_next;
        g_curr = g_next;
        
        % Zapisz historię
        historia_x = [historia_x, x];
    end
    
    x_opt = x;
    f_val = f_curr;
end