function Hz = updateTFSFboundH(Hz_prev, Ex_inc, Ey_inc, tf_region_start, ...
    tf_region_end, dx, dy, dt)

    Hz = Hz_prev;
    m0 = 1.256637061436e-06;

    % Update Hz TFSF boundaries at xn
    Hz(tf_region_start(1), tf_region_start(2):tf_region_end(2)) = ...
        Hz(tf_region_start(1), tf_region_start(2):tf_region_end(2)) + ...
        dt/(m0*dy)*Ey_inc(tf_region_start(1), tf_region_start(2):tf_region_end(2));

    % Update Hz TFSF boundaries at xp
    Hz(tf_region_end(1), tf_region_start(2):tf_region_end(2)) = ...
        Hz(tf_region_end(1), tf_region_start(2):tf_region_end(2)) - ...
        dt/(m0*dy)*Ey_inc(tf_region_end(1), tf_region_start(2):tf_region_end(2));

    % Update Hz TFSF boundaries at yn

    % Update Hz TFSF boundaries at yp


end