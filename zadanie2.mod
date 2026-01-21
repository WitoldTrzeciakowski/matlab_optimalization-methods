# ============================================
# GREENTREE – PLAN PRODUKCJI (AMPL + Gurobi)
# ============================================

# Zmienne decyzyjne (akry)
var x1 >= 0;        # kukurydza
var x2 >= 0;        # pszenica
var x3 >= 0, <= 120;# soja (limit dotacji)
var x4 >= 0;        # owies

# Funkcja celu – maksymalizacja przychodu
maximize Profit:
    39.6*x1
  + 31.5*x2
  + 26.24*x3
  + 53.9*x4;

# Ograniczenie powierzchni ziemi
subject to Land:
    x1 + x2 + x3 + x4 <= 500;

# Kontrakt na kukurydzę (min. 10 000 buszli)
subject to CornContract:
    110*x1 >= 10000;

# Pszenica ≥ soja + owies
subject to WheatRule:
    x2 >= x3 + x4;

# Rozwiązanie
solve;

# Wyniki
display x1, x2, x3, x4, Profit;
