% Main script for flying the birds

clearvars
clear classes
close all

% Retrieve birthday
birthday_str = '06-06-97'; %input('Birthday (dd-mm-yyyy): '); %while
birthday = datetime(birthday_str,'InputFormat','dd-MM-yy');

geometry = geometry(birthday);
side = geometry.side;
amount = geometry.amount;

%amount = 5; %test value
speedLimit = 20; %input
windStream = speedLimit/8 + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/2 .* rand(1,3);
% Create this amount of birds and assign some properties
predPos = [100 100 100];
predator = predator(birthday,geometry,speedLimit,windStream,predPos); % veel hogere limiet nodig!
predPos = predator.position;

for i = 1:amount 
    bird(i)= boid2(amount,side,speedLimit,windStream,predPos);
end

bird.move

%bird(122)= boid(birthday,geometry,speedLimit,windStream);
%%
%
%bird(123) = predator(birthday,geometry,speedLimit,windStream);
%

% Move the birds: loop per vogel?
for i = 1:50 %pos pred en centre of mass doorgeven: eerst bepalen en aan beide doorgeven?
    %pc en pv

    bird.draw
    hold on
    predator.draw
    hold off
    drawnow    
    
    bird.pc =
    bird.pv =
    bird = bird.move;
    
    predator.pc=
    predator = predator.move
%     bird(1).position
%     bird(2).position
end


