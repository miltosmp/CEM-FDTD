clc
clear

cylinder_options = [3, 1, 1, 0, 0]; % [x0, R, e_r, sigma_r, y0]
simulation_options = [10, 10, 10, 10*10^9]; % [X0, Y0, Tn, f0]
boundary = "No-boundary"; % Type of boundary condition
boundary_case = "full"; % boundaries only in the left side
PML_options = [8, 2, 10^(-6)]; % Only in use when boundary is PML


[Ez_m1, Hx_m1, Hy_m1] = CylinderScattering(cylinder_options, simulation_options, ...
    boundary, boundary_case, PML_options);

for k = 1:size(Ez_m1, 3)
    pcolor(Ez_m1(:, :, k));
    shading interp;
    drawnow;


end