function [state, reinf] = getState( x, v_x, theta, v_theta )
% To tell the current state, if state = -1 means fail.

degree = pi/180;
% determine if a state exists
if (x < -0.15)||(x > 0.15)||(theta < -12*degree)||(theta > 12*degree)
    state = -1;
    reinf = -1;
    return
end

% set reinf
reinf = -0.5; 

% determine state w.r.t. position of cart
if x < -0.15
    state = 1;
elseif x <= 0.15
    state = 2;
else
    state = 3;
end
% determine state w.r.t. velocity of cart
if v_x < -0.15
elseif v_x <= 0.15
    state = state + 3;
else
    state = state + 6;
end
% determine state w.r.t. position of pole
if theta < -8*degree
elseif theta < -4*degree
    state = state + 9;
elseif theta < 0
    state = state + 18;
    reinf = reinf + 0.75;
elseif theta < 4*degree
    state = state + 27;
    reinf = reinf + 0.75;
elseif theta < 8*degree
    state = state + 36;
else
    state = state + 45;
end
% determine state w.r.t. velocity of pole
if v_theta < -50*degree
elseif v_theta < -1*degree
    state = state + 54;
elseif v_theta < 1*degree
    state = state + 108;
    reinf = reinf + 0.75;
elseif v_theta < 50*degree
    state = state + 162;
else
    state = state + 216;
end

end