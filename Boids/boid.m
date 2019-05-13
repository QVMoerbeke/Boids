classdef boid
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public) % validate every input
        dimNumber (1,1) double {mustBeNonnegative} = 521
        birdNumber (1,1) double {mustBeNonnegative} = 321
        speedLimit (1,1) double {mustBeNonnegative} = 30 %{mustBeBetween(speedLimit, [0,50])} = 30 
        centreOfMass (1,3) {mustBeNumeric} = 0
        velocityCentre (1,3) {mustBeNumeric} = 0
        predPos (1,3) {mustBeNumeric} = [0 0 0]        
        wind (1,3) {mustBeNumeric} = [0 0 0]  
        name = 'Calimero'
        distance = 0
        elevation = 0
    end
    
    properties (GetAccess = public)
        position = [0 0 0]
        velocity = [0 0 0]
    end
        
    properties (Access = protected)         
        perceivedCentre = 0 
        perceivedVelocity= 0
        danger = 0

        v1 = 0
        v2 = 0
        v3 = 0        

        w1 = 2 %4.5 bij w5 = 60
        w2 = 1 %1
        w3 = 4 %3 % 5 bij w4 = 0
        w4 = 1 %0.5
        w5 = 0 %60 %1.5        
        
        perching = false
        groundLevel = 70        
        perchTimer = 50
        landing = 0
        timeToAct = 50
    end
    
    properties (Constant)
        factorRule1 = 10 
        factorRule2 = 10
        factorRule3 = 8
        factorDanger = 1
        bounding = 5 %25 %1.3 bij exp % 3 bij w3 = 4 en w4 = 0 
    end
    
    methods
        function obj = boid(birdNumber,side,speedLimit,wind,hunter,windVelocity) %allow overloading, bird =?
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 6
                obj.birdNumber = birdNumber;
                obj.dimNumber = side;
                obj.speedLimit = speedLimit;
                if ~wind
                    obj.w4 = 0;
                else
                    obj.wind = windVelocity;
                end
                if ~hunter
                    obj.w5 = 0;
                end
            end
            obj.position = obj.dimNumber/2 + obj.dimNumber/2 * rand(1,3);
            obj.wind = ((rand(1,3) > 0.5)*2 - 1) .* obj.speedLimit/4 .* rand(1,3); %speedLimit/8 + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/2 .* rand(1,3);
            names = {'Calimero','Benjamin','Niels','Coco','Kiwi','Tweety','Sky','Angel','Pray'};
            obj.name = names{randi(numel(names))};
        end
        
        function mustBeBetween(a,b)
           if (a < b(1)) || (a > b(2))
                error(['Assigned value out of the range between',num2str(b(1)),num2str(b(2))])
           end
        end 

        function bird = move(flock,bird)
            perching = bird.perching; %#ok<*PROPLC>            
            if ~perching
                bird.v1 = rule1(bird);
                bird.v2 = rule2(flock,bird);
                bird.v3 = rule3(bird);
                
                bird.danger = dispersePredator(bird);

                w1 = bird.w1;
                w2 = bird.w2;
                w3 = bird.w3;
                w4 = bird.w4;
                w5 = bird.w5;
                
                bird.velocity = bird.velocity + w1*bird.v1 + w2*bird.v2 + w3*bird.v3 + w4*bird.wind + w5*bird.danger;
                bird.velocity = boundPosition(bird); %contains perching
                bird.velocity = limitVelocity(bird);
                bird = perch(bird);
                movement = zeros (2,3);
                movement(1,:) = bird.position;
                bird.position = bird.position + bird.velocity;
                movement(2,:) = bird.position;
                bird.distance = bird.distance + pdist(movement,'Euclidean');
                bird.elevation = bird.elevation + abs(bird.velocity(3));
                
            else
                bird = perch(bird);
            end   
        end
        
        function v1 = rule1(bird)
            perceivedCentre = (bird.centreOfMass - bird.position)/(bird.birdNumber-1);
            v1 = (perceivedCentre - bird.position)/(bird.factorRule1);  
        end 
        
        function v2 = rule2(flock,bird)
            others = vertcat(flock.position);
            pos = bird.position;
            distance = sqrt((others(:,1)-pos(1)).^2+(others(:,2)-pos(2)).^2+(others(:,3)-pos(3)).^2);    
            tooClose = (distance<bird.factorRule2 & distance~=0);           
            v2 = -[sum((others(:,1)-pos(1)).*tooClose),sum((others(:,2)-pos(2)).*tooClose),sum((others(:,3)-pos(3)).*tooClose)];  
        end
        
        function v3 = rule3(bird)
            perceivedVelocity = (bird.velocityCentre - bird.velocity)/(bird.birdNumber-1);
            v3 = (perceivedVelocity - bird.velocity)/(bird.factorRule3);
        end
        
        function wind = windy(bird) %helper subfunction
            speedLimit = bird.speedLimit; %flock(1).speedLimit;
            windStream = bird.wind;
            windStream = windStream + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/10 .* rand(1,3);
            windSpeed = norm(windStream);
            if windSpeed > speedLimit
               windStream = (windStream/windSpeed)*speedLimit;
            end
            wind = windStream;
        end
        
        function danger = dispersePredator(bird)
            danger = 1./(bird.position-bird.predPos+10)./bird.factorDanger;
        end
        
        function velocity = boundPosition(bird)
            
           x = bird.position(1);
           y = bird.position(2);
           z = bird.position(3);
           
           velocity = bird.velocity;
           vx = velocity(1);
           vy = velocity(2);
           vz = velocity(3);
           
           side = bird.dimNumber;
           halfway = side/2; % to determine sign
           
           if x < halfway
               steering = bird.bounding*((halfway-x)/bird.dimNumber)^2;
               %steering = bird.bounding/(1+exp(-(halfway-x))); %bird.bounding^(halfway - x); %correct with weights
               velocity(1) = vx + steering;
           else
               steering = bird.bounding*((halfway-x)/halfway)^2;
               %steering = bird.bounding/(1+exp(+(halfway-x))); %correct with weights
               velocity(1) = vx - steering;
           end
           
           if y < halfway
               steering = bird.bounding*((halfway-y)/bird.dimNumber)^2;
               %steering = bird.bounding/(1+exp(-(halfway-y))); %correct with weights
               velocity(2) = vy + steering;
           else
               steering = bird.bounding*((halfway-y)/bird.dimNumber)^2;
               %steering = bird.bounding/(1+exp(+(halfway-y))); %correct with weights
               velocity(2) = vy - steering;
           end
           
           if z < halfway
               steering = bird.bounding*((halfway-z)/bird.dimNumber)^2;
               %steering = bird.bounding/(1+exp(-(halfway-z))); %correct with weights
               velocity(3) = vz + steering;
           else
               steering = bird.bounding*((halfway-z)/bird.dimNumber)^2;
               %steering = bird.bounding/(1+exp(+(halfway-z))); %correct with weights
               velocity(3) = vz - steering;
           end
        end
        
        function bird = perch(bird)
           bird.perchTimer = bird.perchTimer - 1; 
           if (~bird.perching) && (bird.perchTimer <= 0) && bird.position(3) < bird.groundLevel
               bird.landing = bird.perchTimer;
               bird.perching = true;
               z = bird.position(3);
               bird.velocity(3) = -z; %to make it hover above its projection
           end 
           if (bird.perching == true) && (bird.perchTimer == (bird.landing - 5))
                bird.perchTimer = bird.timeToAct;
                bird.velocity = [20 20 20];
                bird.perching = false;
           end
        end
        
        function v = limitVelocity(bird)
            speed = norm(bird.velocity);
            if speed > bird.speedLimit
               v = (bird.velocity/speed)*bird.speedLimit;
            else
                v = bird.velocity;
            end       
        end
        
    end
end

