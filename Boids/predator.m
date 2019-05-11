classdef predator<boid2
    %PREDATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hunting = 1
        % overwrite some of the properties (weights)
        % higher speed
        % hunting
    end
    
    methods
         function pred=predator(birthday,geometry,speedLimit,windStream,predPos) %
            pred@boid2(birthday,geometry,speedLimit,windStream,predPos);
%             if nargin == 4 % if no input, fall back to default constructor
%                 thisTarget.deltaAoA = deltaAoA;
%             end  
         end
         
         function obj = move(obj)
%              
%              if not hunting gewoon overnemen met andere gewichten?
%                  obj@move(...)
         end
    end
    
end

