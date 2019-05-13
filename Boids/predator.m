classdef predator<boid
    %PREDATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
         function pred = predator(birdNumber,dimNumber,speedLimit,wind,hunter,windVelocity) %
            pred@boid(birdNumber,dimNumber,speedLimit,wind,hunter,windVelocity);
            if nargin == 6 % use 7 for windvel apart?
                pred.speedLimit = 5*speedLimit; %2 bij 50
            else
                pred.speedLimit = 5*pred.speedLimit;
            end
            pred.position = [0 0 0];
            pred.w1 = 5;
            pred.w2 = 0;
            pred.w3 = 0;
            pred.w5 = 0;
            pred.perchTimer = 20;
            pred.timeToAct = 20;
            pred.groundLevel = 180;
         end      
    end
    
end

