function [eez, hhx, hhy] = CylinderScattering(cylinder_options, simulation_options, ...
    boundary, boundary_case, PML_options) 
    
    % Extract options
    x0_nl = cylinder_options(1);
    R_nl = cylinder_options(2);
    e_r = cylinder_options(3);
    sigma_r = cylinder_options(4);
    y0_nl = cylinder_options(5);

    Xm_nl = simulation_options(1);
    Ym_nl = simulation_options(2);
    N_x = simulation_options(3);
    N_y = simulation_options(4);
    Tn = simulation_options(5);
    f0 = simulation_options(6);

    Npml = PML_options(1);
    pow = PML_options(2);
    Rpml = PML_options(3);
    N_x_new = N_x + 2*Npml;
    N_y_new = N_y + 2*Npml;

    % Useful constants
    e0=8.85418781762e-12;
    m0=1.256637061436e-06;
    c0 = 3*10^8;
    lambda0 = c0/f0;

    % Simulation Characteristics
    X_m = Xm_nl*lambda0;
    Y_m = Ym_nl*lambda0;
    dx = X_m/N_x;
    dy = Y_m/N_y;

    Tmax = Tn/f0;
    dt = 0.9*dx/(sqrt(2)*c0);

    % TM: Ez, Hx, Hy
    if boundary == "PML"
        Ez = zeros(N_x_new+1, N_y_new+1);
        Hx = zeros(N_x_new+1, N_y_new);
        Hy = zeros(N_x_new, N_y_new+1);
        
        Ezx_pml = zeros(N_x_new+1, N_y_new+1);
        Ezy_pml = zeros(N_x_new+1, N_y_new+1);
    else
        Ez = zeros(N_x+1, N_y+1);
        Hx = zeros(N_x+1, N_y);
        Hy = zeros(N_x, N_y+1);
    end

    % Create the cylinder
    if boundary == "PML"
        e = e0*ones(N_x_new+1, N_y_new+1);
        sigma = zeros(N_x_new+1, N_y_new+1);
    else
        e = e0*ones(N_x+1, N_y+1);
        sigma = zeros(N_x+1, N_y+1);
    end
    n_lambda = lambda0/dx;
    [e, sigma] = createCylinder(e, sigma, e_r, sigma_r, x0_nl, y0_nl, R_nl, n_lambda);

 
    % Constants for field updating
    Ca = (2*e-dt*sigma)./(2*e+dt*sigma);
    Cb = (2*dt./(2*e + dt * sigma))*(1/dx);
    Da = dt/(m0*dy);
    Db = dt/(m0*dx);


    % PML Parameters    
    se = - (pow+1)*e0*c0*log(Rpml)/(2*dx*Npml);
    sh = (m0/e0)*se;
    sigmaE = zeros(N_x_new, N_y_new);
    sigmaHx = zeros(N_x_new, N_y_new);
    sigmaHy = zeros(N_x_new, N_y_new);

    % X-negative (xn)
    for i = 1:Npml
        sigmaE(Npml-i+1, :)= sigmaE(Npml-i+1, :) + se*(i/Npml)^(pow);
        sigmaHx(Npml-i+1, :)= sigmaHx(Npml-i+1,:) + sh*(i/Npml)^(pow);
        sigmaHy(Npml-i+1, :)= sigmaHy(Npml-i+1,:) + sh*((i+0.5)/Npml)^(pow);
    end
    
    % X-positive (xp)
    for i = 1:Npml
        sigmaE(Npml+N_x+i, :)= sigmaE(Npml+N_x+i, :) + se*(i/Npml)^(pow);
        sigmaHx(Npml+N_x+i, :)= sigmaHx(Npml+N_x+i,:) + sh*(i/Npml)^(pow);
        sigmaHy(Npml+N_x+i, :)= sigmaHy(Npml+N_x+i,:) + sh*((i+0.5)/Npml)^(pow);
    end 
    
    % Y-negative (yn)
    for j = 1:Npml
        sigmaE(:, Npml-j+1)= sigmaE(:, Npml-j+1) + se*(j/Npml)^(pow);
        sigmaHx(:, Npml-j+1)= sigmaHx(:, Npml-j+1) + sh*(j/Npml)^(pow);
        sigmaHy(:, Npml-j+1)= sigmaHy(:, Npml-j+1) + sh*((j+0.5)/Npml)^(pow);
    end
    
    % Y-positive (yp)
    for j = 1:Npml
        sigmaE(:, Npml+N_y+j)= sigmaE(:, Npml+N_y+j) + se*(j/Npml)^(pow);
        sigmaHx(:, Npml+N_y+j)= sigmaHx(:, Npml+N_y+j) + sh*(j/Npml)^(pow);
        sigmaHy(:, Npml+N_y+j)= sigmaHy(:, Npml+N_y+j) + sh*((j+0.5)/Npml)^(pow);
    end 

    
    Ca_pml = exp(1).^(-sigmaE.*dt/e0);
    Cb_pml = (1-Ca_pml)./(sigmaE.*dx);
    Dax_pml = exp(1).^( -sigmaHx.*dt./m0);
    Day_pml = exp(1).^( -sigmaHy.*dt./m0);
    Dbx_pml = (1-Dax_pml)./(sigmaHx.*dx);
    Dby_pml = (1-Day_pml)./(sigmaHy.*dx);

    l = 1;
    if boundary == "No-boundary"
        for t = 0:dt:Tmax
            % Update Electric Field
            Ez = updateEz(Ez, Hx, Hy, Ca, Cb, N_x, N_y, 0, 0);

            % Update source
            Ez(N_x/2, N_y/2) = sin(2*pi*f0*t);
    
            % Update Magnetic Fields
            Hx = updateHx(Hx, Ez, Da, N_x, N_y, 0, 0);
            Hy = updateHy(Hy, Ez, Db, N_x, N_y, 0, 0);

            % Save the field values
            eez(:, :, l) = Ez;
            hhx(:, :, l) = Hx;
            hhy(:, :, l) = Hy;
            l = l + 1;
        end

    elseif boundary == "Mur-first-order"
        for t = 0:dt:Tmax         
            % Update Electrical Field with First order Mur ABC
            Ez = updateEzMurFirst(Ez, Hx, Hy, Ca, Cb, N_x, N_y, dx, dt, c0, boundary_case);

            % Update source
            Ez(N_x/2, N_y/2) = sin(2*pi*f0*t);

            % Update Magnetic Fields
            Hx = updateHx(Hx, Ez, Da, N_x, N_y, 0, 0);
            Hy = updateHy(Hy, Ez, Db, N_x, N_y, 0, 0);

            % Save the field values
            eez(:, :, l) = Ez;
            hhx(:, :, l) = Hx;
            hhy(:, :, l) = Hy;
            l = l + 1;
        end

    elseif boundary == "Mur-second-order"
        for t = 0:dt:Tmax 
            % Update Electrical Field with Second Order Mur ABC
            if l ~= 1
                Ez_prev = eez(:, :, l-1);
                Ez = updateEzMurSecond(Ez, Ez_prev, Hx, Hy, Ca, Cb, N_x, N_y, dx, dy, dt, c0, boundary_case);
            else
                Ez = updateEzMurSecond(Ez, Ez, Hx, Hy, Ca, Cb, N_x, N_y, dx, dy, dt, c0, boundary_case);
            end

            % Update source
            Ez(N_x/2, N_y/2) = sin(2*pi*f0*t);

            % Update Magnetic Fields
            Hx = updateHx(Hx, Ez, Da, N_x, N_y, 0, 0);
            Hy = updateHy(Hy, Ez, Db, N_x, N_y, 0, 0);

            % Save the field values
            eez(:, :, l) = Ez;
            hhx(:, :, l) = Hx;
            hhy(:, :, l) = Hy;
            l = l + 1;
        end

    elseif boundary == "PML"
        for t = 0:dt:Tmax            
            % Update Electric field
            Ez = updateEz(Ez, Hx, Hy, Ca, Cb, N_x, N_y, 1, Npml);
            
            % Update source
            Ez(floor(N_x_new/2), floor(N_y_new/2)) = sin(2*pi*f0*t);       
            
            % Update PML (-x) Electric
            [Ezx_pml, Ezy_pml] = updatePMLxnE(Ezx_pml, Ezy_pml, Hx, Hy, Ca_pml, Cb_pml, Npml, N_x, N_y);   
            
            if boundary_case == "full"
                % Update PML (+x) Electric
                [Ezx_pml, Ezy_pml] = updatePMLxpE(Ezx_pml, Ezy_pml, Hx, Hy, Ca_pml, Cb_pml, Npml, N_x, N_y);
                
                % Update PML (-y) Electric 
                [Ezx_pml, Ezy_pml] = updatePMLynE(Ezx_pml, Ezy_pml, Hx, Hy, Ca_pml, Cb_pml, Npml, N_x, N_y);
                
                % Update PML (+y) Electric
                [Ezx_pml, Ezy_pml] = updatePMLypE(Ezx_pml, Ezy_pml, Hx, Hy, Ca_pml, Cb_pml, Npml, N_x, N_y);
            end
            
            % Update Magnetic Field
            Hx = updateHx(Hx, Ez, Da, N_x, N_y, 1, Npml);
            Hy = updateHy(Hy, Ez, Db, N_x, N_y, 1, Npml);
            
            % Update PML (-x) Magnetic
            [Hx, Hy] = updatePMLxnH(Hx, Hy, Ez, Ezx_pml, Ezy_pml, Dax_pml, Dbx_pml, Day_pml, ...
                Dby_pml, Npml, N_x, N_y);
            
            if boundary_case == "full"
                % Update PML (+x) Magnetic
                [Hx, Hy] = updatePMLxpH(Hx, Hy, Ez, Ezx_pml, Ezy_pml, Dax_pml, Dbx_pml, Day_pml, ...
                    Dby_pml, Npml, N_x, N_y);
                
                % Update PML (-y) Magnetic
                [Hx, Hy] = updatePMLynH(Hx, Hy, Ez, Ezx_pml, Ezy_pml, Dax_pml, Dbx_pml, Day_pml, ...
                    Dby_pml, Npml, N_x, N_y);
                
                % Update PML (+y) Magnetic
                [Hx, Hy] = updatePMLypH(Hx, Hy, Ez, Ezx_pml, Ezy_pml, Dax_pml, Dbx_pml, Day_pml, ...
                    Dby_pml, Npml, N_x, N_y);
            end
            
            eez(:, :, l) = Ez(Npml+1:Npml+N_y+1,Npml+1:Npml+N_y+1);
            hhx(:, :, l) = Hx;
            hhy(:, :, l) = Hy;
            l = l + 1;
        end         
    end       
end



