clc;
clear;

addpath("3D/PML/");
addpath("3D/TFSF/");

% Extract options
Xm_nl = 6;
Ym_nl = 6;
Zm_nl = 6;
Nx = 60;
Ny = 60;
Nz = 60;
Tn = 10;
f0 = 2*10^9;

% Useful constants
e0=8.85418781762e-12;
m0=1.256637061436e-06;
c0 = 3*10^8;
lambda0 = c0/f0;

% Simulation Characteristics
X_m = Xm_nl*lambda0;
Y_m = Ym_nl*lambda0;
Z_m = Zm_nl*lambda0;
dx = X_m/Nx;
dy = Y_m/Ny;
dz = Z_m/Nz;

Tmax = Tn/f0;
dt = 0.7*dx/(sqrt(3)*c0);

% PML Characteristics
Npml = 8;
pow = 2;
Rpml = 10^(-6);
N_x_new = Nx + 2*Npml;
N_y_new = Ny + 2*Npml;
N_z_new = Nz + 2*Npml;

% Regular Field Matrices
Ex = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Ey = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Ez = zeros(N_x_new+1, N_y_new+1, N_z_new+1);

Hx = zeros(N_x_new+1, N_y_new, N_z_new);
Hy = zeros(N_x_new, N_y_new+1, N_z_new);
Hz = zeros(N_x_new, N_y_new, N_z_new+1);

% PML Field Matrices
Exy = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Exz = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Eyx = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Eyz = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Ezx = zeros(N_x_new+1, N_y_new+1, N_z_new+1);
Ezy = zeros(N_x_new+1, N_y_new+1, N_z_new+1);

Hxy = zeros(N_x_new+1, N_y_new, N_z_new);
Hxz = zeros(N_x_new+1, N_y_new, N_z_new);
Hyx = zeros(N_x_new, N_y_new+1, N_z_new);
Hyz = zeros(N_x_new, N_y_new+1, N_z_new);
Hzx = zeros(N_x_new, N_y_new, N_z_new+1);
Hzy = zeros(N_x_new, N_y_new, N_z_new+1);

% e = e0 * ones(N_x, N_y, N_z);

% Constants for field updating
Ce = dt/e0;
Cm = dt/m0;

% PML Conductivities    
se = - (pow+1)*e0*c0*log(Rpml)/(2*dx*Npml);
sh = (m0/e0)*se;
sigmaEx = zeros(N_x_new, N_y_new, N_z_new);
sigmaEy = zeros(N_x_new, N_y_new, N_z_new);
sigmaEz = zeros(N_x_new, N_y_new, N_z_new);
sigmaHx = zeros(N_x_new, N_y_new, N_z_new);
sigmaHy = zeros(N_x_new, N_y_new, N_z_new);
sigmaHz = zeros(N_x_new, N_y_new, N_z_new);


% X-negative (-x)
for i = 1:Npml
    sigmaEx(Npml-i+1, :, :)= sigmaEx(Npml-i+1, :, :) + se*((i+0.5)/Npml)^(pow);
    sigmaEy(Npml-i+1, :, :)= sigmaEy(Npml-i+1, :, :) + se*(i/Npml)^(pow);
    sigmaEz(Npml-i+1, :, :)= sigmaEz(Npml-i+1, :, :) + se*(i/Npml)^(pow);
    sigmaHx(Npml-i+1, :, :)= sigmaHx(Npml-i+1, :, :) + se*((i)/Npml)^(pow);
    sigmaHy(Npml-i+1, :, :)= sigmaHy(Npml-i+1, :, :) + se*(i/Npml)^(pow);
    sigmaHz(Npml-i+1, :, :)= sigmaHz(Npml-i+1, :, :) + sh*((i+0.5)/Npml)^(pow);
end

% X-positive (+x)
for i = 1:Npml
    sigmaEx(Npml+Ny+i, :, :)= sigmaEx(Npml+Ny+i, :, :) + se*((i+0.5)/Npml)^(pow);
    sigmaEy(Npml+Ny+i, :, :)= sigmaEy(Npml+Ny+i, :, :) + se*(i/Npml)^(pow);
    sigmaEz(Npml+Ny+i, :, :)= sigmaEz(Npml+Ny+i, :, :) + se*(i/Npml)^(pow);
    sigmaHx(Npml+Ny+i, :, :)= sigmaHx(Npml+Ny+i, :, :) + se*((i)/Npml)^(pow);
    sigmaHy(Npml+Ny+i, :, :)= sigmaHy(Npml+Ny+i, :, :) + se*(i/Npml)^(pow);
    sigmaHz(Npml+Ny+i, :, :)= sigmaHz(Npml+Ny+i, :, :) + sh*((i+0.5)/Npml)^(pow);
end 

% Y-negative (-y)
for j = 1:Npml
    sigmaEx(:, Npml-j+1, :)= sigmaEx(:, Npml-j+1, :) + se*(j/Npml)^(pow);
    sigmaEy(:, Npml-j+1, :)= sigmaEy(:, Npml-j+1, :) + se*((j+0.5)/Npml)^(pow);
    sigmaEz(:, Npml-j+1, :)= sigmaEz(:, Npml-j+1, :) + se*(j/Npml)^(pow);
    sigmaHx(:, Npml-j+1, :)= sigmaHx(:, Npml-j+1, :) + se*(j/Npml)^(pow);
    sigmaHy(:, Npml-j+1, :)= sigmaHy(:, Npml-j+1, :) + se*(j/Npml)^(pow);
    sigmaHz(:, Npml-j+1, :)= sigmaHz(:, Npml-j+1, :) + sh*((j+0.5)/Npml)^(pow);
end

% Y-positive (+y)
for j = 1:Npml
    sigmaEx(:, Npml+Ny+j, :)= sigmaEx(:, Npml+Ny+j, :) + se*(j/Npml)^(pow);
    sigmaEy(:, Npml+Ny+j, :)= sigmaEy(:, Npml+Ny+j, :) + se*((j+0.5)/Npml)^(pow);
    sigmaEz(:, Npml+Ny+j, :)= sigmaEz(:, Npml+Ny+j, :) + se*(j/Npml)^(pow);
    sigmaHx(:, Npml+Ny+j, :)= sigmaHx(:, Npml+Ny+j, :) + se*(j/Npml)^(pow);
    sigmaHy(:, Npml+Ny+j, :)= sigmaHy(:, Npml+Ny+j, :) + se*(j/Npml)^(pow);
    sigmaHz(:, Npml+Ny+j, :)= sigmaHz(:, Npml+Ny+j, :) + sh*((j+0.5)/Npml)^(pow);
end 

% Z-negative (-z)
for mk = 1:Npml
    sigmaEx(:, :, Npml-mk+1)= sigmaEx(:, :, Npml-mk+1) + se*(mk/Npml)^(pow);
    sigmaEy(:, :, Npml-mk+1)= sigmaEy(:, :, Npml-mk+1) + se*(mk/Npml)^(pow);
    sigmaEz(:, :, Npml-mk+1)= sigmaEz(:, :, Npml-mk+1) + se*(mk/Npml)^(pow);
    sigmaHx(:, :, Npml-mk+1)= sigmaHx(:, :, Npml-mk+1) + se*(mk/Npml)^(pow);
    sigmaHy(:, :, Npml-mk+1)= sigmaHy(:, :, Npml-mk+1) + se*(mk/Npml)^(pow);
    sigmaHz(:, :, Npml-mk+1)= sigmaHz(:, :, Npml-mk+1) + sh*(mk/Npml)^(pow);
end

% Z-positive (+z)
for mk = 1:Npml
    sigmaEx(:, :, Npml+Ny+mk)= sigmaEx(:, :, Npml+Ny+mk) + se*(mk/Npml)^(pow);
    sigmaEy(:, :, Npml+Ny+mk)= sigmaEy(:, :, Npml+Ny+mk) + se*(mk/Npml)^(pow);
    sigmaEz(:, :, Npml+Ny+mk)= sigmaEz(:, :, Npml+Ny+mk) + se*(mk/Npml)^(pow);
    sigmaHx(:, :, Npml+Ny+mk)= sigmaHx(:, :, Npml+Ny+mk) + se*(mk/Npml)^(pow);
    sigmaHy(:, :, Npml+Ny+mk)= sigmaHy(:, :, Npml+Ny+mk) + se*(mk/Npml)^(pow);
    sigmaHz(:, :, Npml+Ny+mk)= sigmaHz(:, :, Npml+Ny+mk) + sh*(mk/Npml)^(pow);
end




% PML updating parameters
Cax_pml = exp(1).^(-sigmaEx.*dt/e0);
Cay_pml = exp(1).^(-sigmaEy.*dt/e0);
Caz_pml = exp(1).^(-sigmaEz.*dt/e0);
Cbx_pml = (1-Cax_pml)./(sigmaEx.*dx);
Cby_pml = (1-Cay_pml)./(sigmaEy.*dx);
Cbz_pml = (1-Caz_pml)./(sigmaEz.*dx);

Dax_pml = exp(1).^( -sigmaHx.*dt./m0);
Dbx_pml = (1-Dax_pml)./(sigmaHx.*dx);
Day_pml = exp(1).^( -sigmaHy.*dt./m0);
Dby_pml = (1-Day_pml)./(sigmaHy.*dx);
Daz_pml = exp(1).^( -sigmaHz.*dt./m0);
Dbz_pml = (1-Daz_pml)./(sigmaHz.*dx);

x  = linspace(0,Xm_nl,Nx)*lambda0;          
y  = linspace(0,Ym_nl,Ny)*lambda0;          
z  = linspace(0,Zm_nl,Nz)*lambda0;


[X,Y,Z] = meshgrid(y,x,z(1:end));

for t = 0:dt:Tmax
    % Update Electric Field
    [Ex, Ey, Ez] = updateElectricField(Ex, Ey, Ez, Hx, Hy, Hz, ...
    Ce, Npml, Nx, Ny, Nz, dx, dy, dz);

    % Update source
    Ex(floor(N_x_new/2), floor(N_y_new/2), floor(N_z_new/2)) = sin(2*pi*f0*t);

    % Update PML Electric
    [Exy, Exz, Eyx, Eyz, Ezx, Ezy, Ex, Ey, Ez] = updateElectricPML(Exy, Exz, Eyx, Eyz, ...
        Ezx, Ezy, Ex, Ey, Ez, Hx, Hy, Hz, Cax_pml, Cay_pml, Caz_pml, Cbx_pml, Cby_pml, ...
        Cbz_pml, Npml, Nx, Ny, Nz);

    % Update Magnetic Fields
    [Hx, Hy, Hz] = updateMagneticField(Hx, Hy, Hz, Ex, Ey, Ez, ...
    Cm, Npml, Nx, Ny, Nz, dx, dy, dz);

    % Update PML Magnetic
    [Hxy, Hxz, Hyx, Hyz, Hzx, Hzy, Hx, Hy, Hz] = updateMagneticPML(Hxy, Hxz, ...
        Hyx, Hyz, Hzx, Hzy, Hx, Hy, Hz, Ex, Ey, Ez, Dax_pml, Day_pml, Daz_pml, ...
        Dbx_pml, Dby_pml, Dbz_pml, Npml, Nx, Ny, Nz);


    slice(X,Y,Z,Ex(Npml+1:Npml+Ny, Npml+1:Npml+Ny, Npml+1:Npml+Ny) ...
        ,y(end)/2,x(end)/2,z(end)/2);
    axis([0 y(end) 0 x(end) 0 z(end)]);
    view([1 1 1]); 
    caxis([-.001 .001]); 
    shading interp; 
    drawnow;
end



