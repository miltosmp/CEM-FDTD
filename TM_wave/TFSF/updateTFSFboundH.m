function [Hx, Hy] = updateTFSFboundH(Hx_prev, Hy_prev, Ez_inc, tf_region_start, ...
    tf_region_end, dx, dy, dt)  

    Hx = Hx_prev;
    Hy = Hy_prev;
    m0=1.256637061436e-06;

    % Update Hy TFSF boundaries at xn
    Hy(tf_region_start(1), tf_region_start(2):tf_region_end(2)) = ...
        Hy(tf_region_start(1), tf_region_start(2):tf_region_end(2)) - ...
        dt/(m0*dy)*Ez_inc(tf_region_start(1), tf_region_start(2):tf_region_end(2));

    % Update Hy TFSF boundaries at xp
    Hy(tf_region_end(1), tf_region_start(2):tf_region_end(2)) = ...
        Hy(tf_region_end(1), tf_region_start(2):tf_region_end(2)) + ...
        dt/(m0*dy)*Ez_inc(tf_region_end(1), tf_region_start(2):tf_region_end(2));

    % Update Hx TFSF boundaries at yn
    Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_start(2)) + ...
        dt/(m0*dx)*Ez_inc(tf_region_start(1):tf_region_end(1), tf_region_start(2));

    % Update Hx TFSF boundaries at yp
    Hx(tf_region_start(1):tf_region_end(1), tf_region_end(2)) = ...
        Hx(tf_region_start(1):tf_region_end(1), tf_region_end(2)) - ...
        dt/(m0*dx)*Ez_inc(tf_region_start(1):tf_region_end(1), tf_region_end(2));

end