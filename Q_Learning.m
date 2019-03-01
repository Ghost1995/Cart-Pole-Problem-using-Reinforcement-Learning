function Q = Q_Learning( )
% It is the main q-learning algorithm for Cartpole problem
    
noise = [0.01 0 5*pi()/180 0]; % magnitude of noise added to choice
y = 0.5;  % discount factor for future reinforcement
epsilon = 0.5; % exploration rate
M = 0.1; % mass of cart
m = 0.05; % mass of the pole
g = 9.81; % acceleration due to gravity
l = 1.2192; % length of pole
Force = 0.007; % external force
T = 0.01; % Update time interval

% Define global variable
num_box = [3 3 6 5]; % Number of states per measurement
NUM_BOX = prod(num_box); % Total Number of States
aCounter = ones(NUM_BOX,2); % learning rate parameter
Q = zeros(NUM_BOX,2);

% reset cart
cur_action = 0; % 0 means no action been taken
x = normrnd(0,noise(1)); % the location of cart
v_x = 0; % the velocity of cart
theta = normrnd(0,noise(3)); % the angle of pole
v_theta = 0; % the velocity of pole angle
[cur_state,~] = getState(x, v_x, theta, v_theta);

% Initialize figure
Frames(5000*1000) = struct('cdata',[],'colormap',[]);
h = figure; % this figure is cart-pole
axis([-0.5 0.5 0 2]);
frame = 0;

success = 0; % Initialize number of successes
trial = 0;
best = 0;
while success < 1000
    pre_state = cur_state;
    pre_action = cur_action; % Action: 1 is push left. Action: 2 is push right
    [cur_state,reinf] = getState(x, v_x, theta, v_theta);
    if pre_action % Update Q value. If previous action been taken
        if cur_state == -1  % Current state is failed
            predicted_value = 0; % fail state's value is zero
        else
            cur_action = epsilonGreedy(Q(cur_state,:),epsilon); % use e-greedy policy to set Q
            predicted_value = Q(cur_state,cur_action);
        end
        aCounter(pre_state,pre_action) = aCounter(pre_state,pre_action) + 1;
        a = 1/aCounter(pre_state,pre_action);
        Q(pre_state,pre_action) = (1-a)*Q(pre_state,pre_action) + a*(reinf + y*predicted_value);
    else
        cur_action = epsilonGreedy(Q(cur_state,:),epsilon); % use e-greedy policy to set Q
    end
    if cur_action == 1 % push left
        F = -1*Force;
    else % push right
        F = Force;
    end
    
    % Update the cart-pole state
    a_theta = (cos(theta)*(F - m*sin(theta)*(l*(v_theta^2) - g*cos(theta))))/((M + m*(sin(theta)^2))*l);
    a_x = (F + m*sin(theta)*(g*cos(theta) - l*(v_theta^2)))/(M + m*(sin(theta)^2));
    v_theta = v_theta + a_theta*T;
    theta = theta + v_theta*T;
    v_x = v_x + a_x*T;
    x = x + v_x*T;
    % draw new state
    figure(h);
    X = [x, x+l*sin(theta)];
    Y = [0.0015, 0.0015+l*cos(theta)];
    hold on
    obj = rectangle('Position',[x-0.015,0,0.03,0.003],'facecolor','b');
    obj2 = line(X,Y);
    if F > 0
        obj3 = plot(x-0.015,0.0015,'r>');
    else
        obj3 = plot(x+0.015,0.0015,'r<');
    end
    hold off
    frame = frame + 1;
    Frames(frame) = getframe(h);
    pause(0.01)
    delete(obj)
    delete(obj2)
    delete(obj3)
    % get new box
    [state,reinf] = getState(x,v_x,theta,v_theta);
    if state == -1 % if fail
        aCounter(pre_state,pre_action) = aCounter(pre_state,pre_action) + 1;
        a = 1/aCounter(pre_state,pre_action);
        Q(pre_state,pre_action) = (1-a)*Q(pre_state,pre_action) + a*reinf;
  	    % reset cart
        cur_action = 0; % 0 means no action been taken
        x = ((-1)^randi(2))*rand*noise(1); % the location of cart
        v_x = 0; % the velocity of cart
        theta = ((-1)^randi(2))*rand*noise(3); % the angle of pole
        v_theta = 0; % the velocity of pole angle
        cur_state = getState(x, v_x, theta, v_theta);
        trial = trial + 1;
        epsilon = 0.5 + (0.01 - 0.5)*(trial/10^5);
        if success > best
            best = success;
        end
        success = 0;
        figure(h);
        title(strcat('Trials  ',num2str(trial),', Best success : ',num2str(best)));
    elseif (reinf == 1)
        success = success + 1;
        figure(h);
        title(strcat('Trials  ',num2str(trial),', Success : ',num2str(success)));
    end
end
figure(h);
title(['Success at ' num2str(trial) ' trials']);

v = VideoWriter('Video.mp4');
open(v)
writeVideo(v,Frames(1:frame));
close(v)

end