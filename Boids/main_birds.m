% Main script for flying the birds
% mustBeBetween
% weights
% predator bij birds zetten met {}
% Code kuisen

clearvars
clear classes
close all

% Set standard values to be used 
speedLimit = 5;
wind = true;
windFactor = 1;
hunter = true;

% Variables for the video storage
time = 500;
set(gcf,'Units','normalized','OuterPosition',[0 0 1 1])

% Ask to input own data or standard values
inputData = 'n'; %input('Own data? (y/n): ','s');
while ~ismember(inputData,'ynYN')
    inputData= input('Invalid input! Own data? (y/n): ','s');
end
data = false;
if ismember(inputData,'yY')
    data = true;
end

% Create geometry and retrieve properteis for bird creation
geometry = geometry(data);
dimNumber = geometry.dimNumber;
birdNumber = geometry.birdNumber;

% Ask for data if own values are wanted to be used
if data 
    % Retrieve speed limit for the birds
    speedLimit = input('Speed limit (0-50): ');
    while (speedLimit < 0) || (speedLimit > 50)
        warning('Invalid input!')
        speedLimit = input('Speed limit (0-50): ');
    end

    % Ask for predator
    inputHunter= input('Predator? (y/n): ','s');
    while ~ismember(inputHunter,'ynYN')
        inputHunter= input('Invalid input! Predator? (y/n): ','s');
    end
    if ~ismember(inputHunter,'nN')
        hunter = false;
    end
    
    %Ask for wind
    inputWind = input('Windy conditions? (y/n): ','s');
    while ~ismember(inputWind,'ynYN')
        inputWind= input('Invalid input! Wind? (y/n): ','s');
    end
    if ~ismember(inputWind,'nN')
        wind = false;
    end
end

% Initialise the wind velocity
windVelocity = ((rand(1,3) > 0.5)*2 - 1) * speedLimit/windFactor .* rand(1,3);
windSpeed = norm(windVelocity);
if windSpeed > speedLimit
   windVelocity = (windVelocity/windSpeed)*speedLimit;
end

% Create a predator based on the input data
predator = predator(birdNumber,dimNumber,speedLimit,wind,hunter,windVelocity);

% Create the birds of the flock based on the input data
for b = 1:birdNumber 
    flock(b)= boid(birdNumber,dimNumber,speedLimit,wind,hunter,windVelocity);
end

% Let the birds fly over the time period
for t = 1:time
    % warming up
    
    %Retrieve centre of mass and velocity and wind variation
    positions = vertcat(flock.position);
    centreOfMass = sum(positions);
    velocities = vertcat(flock.velocity);
    centreOfVelocity = sum(velocities);
    
    % Move the predator
    if hunter
        predator.centreOfMass = centreOfMass;
        predator.velocityCentre = centreOfVelocity; 
        predator = move(flock,predator); %andere functie met move in
    end
    
    % Move all the birds
    b = 1;
    for bird = flock
        if hunter
            bird.predPos = predator.position;
        end
        bird.centreOfMass= centreOfMass;
        bird.velocityCentre = centreOfVelocity;
        bird = move(flock,bird);
        flock(b) = bird;
        b = b+1;
    end
    
    % Draw predator
    position = vertcat(predator.position);
    projection = position;
    projection(:,3) = 0;
    scatter3(position(:,1),position(:,2),position(:,3),9,'filled');
    set(gca,'XLim',[0 dimNumber],'YLim',[0 dimNumber],'ZLim',[0 dimNumber])
    hold on
     scatter3(projection(:,1),projection(:,2),projection(:,3),3,'filled','gr');

    % Draw the flock and store frames for the video
    positions = vertcat(flock.position);
    projection = positions;
    projection(:,3) = 0;
    scatter3(positions(:,1),positions(:,2),positions(:,3),7,'filled');
    set(gca,'XLim',[0 dimNumber],'YLim',[0 dimNumber],'ZLim',[0 dimNumber])
    scatter3(projection(:,1),projection(:,2),projection(:,3),3,'filled','gr');
    hold off
    drawnow 
    
    % Store frames for video
    F(t) = getframe(gcf);
    %pause(0.1)
end

video = VideoWriter('Quinten_boids.avi','MPEG-4');
video.FrameRate = 30;
open(video)
writeVideo(video,F)
close(video)

% Rank the distance and elevation
rankingDist = cell(birdNumber,2); %make it structure
distances = vertcat(flock.distance);
[~,id]=ismember(distances,sort(distances,'descend'));

for i = 1:birdNumber
    rankingDist{i,1} = id(i);
    id = rankingDist(i,1);
    rankingDist{i,2} = flock(id(i)).name;   
end
