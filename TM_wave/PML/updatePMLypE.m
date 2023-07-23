function [Ezx_pml, Ezy_pml] = updatePMLypE(Ezx_pml_prev, Ezy_pml_prev, Hx, Hy, Ca_pml, Cb_pml, Npml, N_x, N_y)
    Ezx_pml = Ezx_pml_prev;
    Ezy_pml = Ezy_pml_prev; 
    for i = Npml+1:N_y+Npml
        for j = Npml+N_x+1:N_x+2*Npml-1
            Ezx_pml(i, j) = Ca_pml(i, j)*Ezx_pml(i, j) + Cb_pml(i, j)*(Hy(i, j) ...
                - Hy(i-1, j));
            Ezy_pml(i, j) = Ca_pml(i, j)*Ezy_pml(i, j) + Cb_pml(i, j)*(Hx(i, j-1) ...
                - Hx(i, j));
        end
    end