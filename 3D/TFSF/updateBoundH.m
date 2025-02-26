function [Hx, Hy, Hz] = updateBoundH(Hx_p, Hy_p, Hz_p, Ex_i, Ey_i, Ez_i, ...
    tf_region_start, tf_region_end, dx, dy, dz, dt)

    Hx = Hx_p;
    Hy = Hy_p;
    Hz = Hz_p;

    m0=1.256637061436e-06;

    % Update H TFSF boundaries at xn
    Hy(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hy(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) - ...
        dt/(m0*dy)*Ez_i(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3));

    Hz(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hz(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) + ...
        dt/(m0*dz)*Ey_i(tf_region_start(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3));

    % Update H TFSF boundaries at xp
    Hy(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hy(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) + ...
        dt/(m0*dy)*Ez_i(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3));

    Hz(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hz(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3)) - ...
        dt/(m0*dz)*Ey_i(tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3):tf_region_end(3));

    % Update H TFSF boundaries at yn
    Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3)) + ...
        dt/(m0*dx)*Ez_i(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3));

    Hz(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3)) = ...
        Hz(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3)) - ...
        dt/(m0*dz)*Ex_i(tf_region_start(1):tf_region_end(1), tf_region_start(2), tf_region_start(3):tf_region_end(3));

    % Update H TFSF boundaries at yp
    Hx(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3)) - ...
        dt/(m0*dx)*Ez_i(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3));

    Hz(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3)) = ...
        Hz(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3)) + ...
        dt/(m0*dz)*Ex_i(tf_region_start(1):tf_region_end(1), tf_region_end(2), tf_region_start(3):tf_region_end(3));

    % Update H TFSF boundaries at zn
    Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3)) - ...
        dt/(m0*dx)*Ey_i(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3));

    Hy(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3)) = ...
        Hy(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3)) + ...
        dt/(m0*dy)*Ex_i(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_start(3));

    % Update H TFSF boundaries at zp
    Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3)) + ...
        dt/(m0*dx)*Ey_i(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3));

    Hy(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3)) = ...
        Hy(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3)) - ...
        dt/(m0*dy)*Ex_i(tf_region_start(1):tf_region_end(1), tf_region_start(2):tf_region_end(2), tf_region_end(3));

end