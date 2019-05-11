classdef boid
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public) % validate every input
        birthday datetime = date
        geometry %?
        
        speed (1,1) double %{mustBePositive} = 0
        speedLimit %must be between
        velocity = [0,0,0]
        position (1,3) %?
        
        pc = 0
        pv = 0
        factorRule1 = 10
        factorRule2 = 20
        factorRule3 = 8
        
        wind = [0 0 0]
        danger = [0 0 0]
        
        v1 = 0
        v2 = 0
        v3 = 0

        w1 = 1
        w2 = 1
        w3 = 1
    end
    
    properties (Access = public) %private
        
    end
    
    properties (Dependent)
        amount
    end
    
    methods
        function obj = boid(birthday,geometry, speedLimit,windStream) %allow overloading, bird =?
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            % Add if nargin = 1
            % obj.birthday = birthday
            % Add if nargin = 3
            % Ask questions here?
            obj.birthday = birthday;
            obj.geometry = geometry;
            obj.position = obj.geometry * rand(1,3);
            obj.speedLimit = speedLimit;
            obj.speed = speedLimit * rand(); 
            
            % Initialise a random wind, which will be adjusted during the
            % loop
%             windStream = speedLimit/100 + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/2 .* rand(1,3);
            obj.wind = windStream;
        end
        
        function amount = get.amount(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            amount = 230 - (obj{1}.birthday.Day+obj{1}.birthday.Month+obj{1}.birthday.Year);
            if obj{1}.birthday.Year > 1999
                amount = amount + 2000;
            else
                amount = amount + 1900;
            end
        end
        
        function obj = move(obj) %obj is all objects?
            
            %obj.v1 = rule1(obj); % make this property?
            obj = rule1(obj);
            obj = rule2(obj);
            obj = rule3(obj);
            obj = windy(obj);
            
            %display(obj{1}.wind)
    
            for b = 1:obj{1}.amount % b = obj
                bird = obj{b};
%                 a = obj{b}.wind;
%                 c = obj{b}.speedLimit;
%                 bird.wind = windy(obj);

                w1 = obj{b}.w1; %#ok<*PROP>
                w2 = obj{b}.w2;
                w3 = obj{b}.w3;
                bird.velocity = bird.velocity + w1 * bird.v1 + w2*bird.v2 + w3*bird.v3 + 0.2 * bird.wind + bird.danger;
                bird.velocity = boundPosition(bird); %update similar to rule2
                bird.velocity = limitVelocity(bird);
                bird.position = bird.position + bird.velocity;
                
                obj{b} = bird;
            end
        end
        
        function obj = predator(obj)
            obj.velocity = -(obj.position - obj.danger)/10;
        end
        
        function obj = windy(obj)
%             windStream = wind + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/8 .* rand(1,3);
            windStream = obj{1}.wind;
            windStream = windStream + ((rand(1,3) > 0.5)*2 - 1) * obj{1}.speedLimit/16 .* rand(1,3);
            for b =1:obj{1}.amount
                obj{b}.wind = windStream;
            end
        end
        
        function obj = draw(obj)
            s  = obj{1}.geometry;
            positions = vertcat(obj.position);
            projection = positions;
            projection(:,3) = 0;
%             axes1 = axes('FontSize',10,'FontWeight','bold');
%             xlim  (axes1,[0 obj{1}.geometry]);
%             ylim  (axes1,[0 obj{1}.geometry]);
%             zlim  (axes1,[0 obj{1}.geometry]);
%             xlabel(axes1,'x (km)');
%             ylabel(axes1,'T (K)');
%             zlabel(axes1,'T (K)');
%             box   (axes1,'on');
%             grid  (axes1,'on');
%             hold  (axes1,'all');
            scatter3(positions(:,1),positions(:,2),positions(:,3),5,'filled');
            set(gca,'XLim',[0 s],'YLim',[0 s],'ZLim',[0 s])
            hold on
            scatter3(projection(:,1),projection(:,2),projection(:,3),3,'filled','gr');
        end
        
        function velocity = boundPosition(b)
            
           x = b.position(1);
           y = b.position(2);
           z = b.position(3);
           
           velocity = b.velocity;
           
           max = b.geometry - 50; %make space between border a property?
           min = 50;
           
           if x < min
               velocity(1) = 20; %another property
           elseif x > max
               velocity(1) = -20;
           elseif y < min
               velocity(2) = 20;
           elseif y > max
               velocity(2) = -20;
           elseif z < min
               velocity(3) = 20;
           elseif z > max
               velocity(3) = -20;
           end
        end
        
        function v = limitVelocity(b)
            b.speed = norm(b.velocity);
            if b.speed > b.speedLimit
               v = (b.velocity/b.speed)*b.speedLimit;
            else
                v = b.velocity;
            end       
        end
            
        function obj = rule1(obj)
            
            obj = centreOfMass(obj);
            
            for b = 1:obj{1}.amount
                obj{b}.v1 = (obj{b}.pc - obj{b}.position)/(obj{b}.factorRule1);
            end
            
%             obj.pc = centreOfMass(obj);
%             positions = vertcat(obj.position);
%             obj.v1 = (pc - positions)/obj{1}.factorRule1;
            
        end
        
        function obj = centreOfMass(obj)
%             positions = vertcat(obj.position);
%             c = sum(positions);
            c = 0;
            for b = 1:obj{1,1}.amount
                c = c + obj{1,b}.position;
            end
            
            % perceived centre of mass
%             pc = zeros(obj{1}.amount,3);
            for b = 1:obj{1}.amount
                obj{b}.pc = (c - obj{b}.position)/(obj{b}.amount-1);
                %display(obj{b}.pc)
            end
            
            
%             pc = pc/(obj{1}.amount-1); %make property?
            
%             x = positions(:,1);
%             y = positions(:,2);
%             z = positions(:,3);
        end
        
        function obj = rule2(obj)
            positions = zeros(2,3);
            for b = 1:obj{1}.amount
                positions(1,:) = obj{b}.position;
                c = 0;
                for i = 1:obj{1}.amount
                    if i ~= b
                        positions(2,:) = obj(i).position;
                        space = pdist(positions,'Euclidean');
                        if space < obj{b}.factorRule2 %some are bigger and other space? Make it property? 
                            c = c - (positions(2,:) - positions(1,:)); 
                        end
                    end
                end
                obj{b}.v2 = c;
            end
        end
        
        function obj = rule3(obj)
            obj = perceivedVelocity(obj);
            for b = 1:obj{1}.amount
                obj{b}.v3 = (obj{b}.pv - obj{b}.velocity)/(obj{b}.factorRule3);
            end
        end
        
        function obj = perceivedVelocity(obj)
            c = 0;
            for b = 1:obj{1}.amount
                c = c + obj{b}.velocity;
            end
            
%             velocities = vertcat(obj.velocity);
%             c = sum(velocities);

            for b = 1:obj{1}.amount
                obj{b}.pv = (c - obj{b}.velocity)/(obj{b}.amount-1);
            end
        end
    end
end

