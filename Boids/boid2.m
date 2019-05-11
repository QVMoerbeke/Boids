classdef boid2
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public) % validate every input
        birthday datetime = date
        geometry %?
        amount
        
        speed (1,1) double %{mustBePositive} = 0
        speedLimit %must be between validateattributes( number1, { 'numeric' }, { '>=', 1, '<=', 100 } )
        velocity = [0,0,0]
        position (1,3) %?
        
        pc = 0
        pv = 0
        factorRule1 = 10
        factorRule2 = 20
        factorRule3 = 8
        
        wind = [0 0 0]
        danger = [0 0 0]
        predPos = [0 0 0]
        
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
        
    end
    
    methods
        function obj = boid2(amount,side,speedLimit,windStream,predPos) %allow overloading, bird =?
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            % Add if nargin = 1
            % obj.birthday = birthday
            % Add if nargin = 3
            obj.amount = amount;
            obj.geometry = side;
            obj.position = obj.geometry * rand(1,3);
            obj.speedLimit = speedLimit;
            obj.speed = speedLimit * rand();
            obj.predPos = predPos;
            % Initialise a random wind, which will be adjusted during the
            % loop
%             windStream = speedLimit/100 + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/2 .* rand(1,3);
            obj.wind = windStream;
        end
        
        function obj = move(obj) %obj is all objects?
            for b = 1:obj(1).amount % b = obj
                bird = obj(b);
                bird = rule1(obj,bird);
                bird = rule2(obj,bird);
                bird = rule3(bird);
                bird = windy(bird);
                bird = predator(bird);

                w1 = bird.w1; %#ok<*PROP>
                w2 = bird.w2;
                w3 = bird.w3;
                bird.velocity = bird.velocity + w1 * bird.v1 + w2*bird.v2 + w3*bird.v3 + 0 * bird.wind+ 0.2 *bird.danger;
                bird.velocity = boundPosition(bird); %update similar to rule2
                bird.velocity = limitVelocity(bird);
                bird.position = bird.position + bird.velocity;
                
                obj(b) = bird;
            end
        end
        
        function bird = rule1(obj,bird)
%             obj = centreOfMass(obj);
            positions = vertcat(obj.position);
            c = sum(positions);
            pc = (c - bird.position)/(bird.amount-1);
            bird.v1 = (pc - bird.position)/(bird.factorRule1);
%             for b = 1:obj(1).amount
%                 obj(b).v1 = (obj(b).pc - obj(b).position)/(obj(b).factorRule1);
%             end
            
%             obj.pc = centreOfMass(obj);
%             positions = vertcat(obj.position);
%             obj.v1 = (pc - positions)/obj(1).factorRule1;
            
        end % centre of mass al meegeven? Niet hele bird telkens teruggeven?
        
        function obj = centreOfMass(obj)
            positions = vertcat(obj.position);
            c = sum(positions);
            
            % perceived centre of mass
%             pc = zeros(obj(1).amount,3);
            for b = 1:obj(1).amount
                obj(b).pc = (c - obj(b).position)/(obj(b).amount-1);
                %display(obj(b).pc)
            end
            
            
%             pc = pc/(obj(1).amount-1); %make property?
            
%             x = positions(:,1);
%             y = positions(:,2);
%             z = positions(:,3);
        end
        
        function bird = rule2(obj,bird)
            c = 0;
            positions = zeros(2,3);
            positions(1,:) = bird.position;
            for b = 1:bird.amount
                positions(2,:) = obj(b).position;
                space = pdist(positions,'Euclidean');
                if space < bird.factorRule2 && space ~= 0 %some are bigger and other space? Make it property? 
                    c = c - (positions(2,:) - positions(1,:)); 
                end              
            bird.v2 = c;
            end
            
%             for b = 1:obj(1).amount
%                 positions(1,:) = obj(b).position;
%                 c = 0;
%                 for i = 1:obj(1).amount
%                     if i ~= b
%                         positions(2,:) = obj(i).position;
%                         space = pdist(positions,'Euclidean');
%                         if space < obj(b).factorRule2 %some are bigger and other space? Make it property? 
%                             c = c - (positions(2,:) - positions(1,:)); 
%                         end
%                     end
%                 end
%                 obj(b).v2 = c;
%             end
        end
        
        function bird = rule3(obj, bird)
            bird.pv = perceivedVelocity(obj);
            bird.v3 = (bird.pv - bird.velocity)/(bird.factorRule3);
 
%             for b = 1:obj(1).amount
%                 obj(b).v3 = (obj(b).pv - obj(b).velocity)/(obj(b).factorRule3);
%             end
        end
        
        function obj = perceivedVelocity(obj)
            velocities = vertcat(obj.velocity);
            c = sum(velocities);

            for b = 1:obj(1).amount
                obj(b).pv = (c - obj(b).velocity)/(obj(b).amount-1);
            end
        end
        
        function bird = predator(bird)
            bird.danger = -(bird.predPos-bird.position)/10;
        end
        
        function bind = windy(bind)
%             windStream = wind + ((rand(1,3) > 0.5)*2 - 1) * speedLimit/8 .* rand(1,3);
            windStream = bird.wind;
            windStream = windStream + ((rand(1,3) > 0.5)*2 - 1) * bind.speedLimit/16 .* rand(1,3);
            bind(b).wind = windStream;
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
            
        
        
        
        function obj = draw(obj)
            s  = obj(1).geometry;
            positions = vertcat(obj.position);
            projection = positions;
            projection(:,3) = 0;
%             axes1 = axes('FontSize',10,'FontWeight','bold');
%             xlim  (axes1,[0 obj(1).geometry]);
%             ylim  (axes1,[0 obj(1).geometry]);
%             zlim  (axes1,[0 obj(1).geometry]);
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
        
        

    end
end

