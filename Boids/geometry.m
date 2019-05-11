classdef geometry
    %GEOMETRY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        birthday datetime = date
    end
    
    properties (Dependent)
        amount
        side
    end
        
    methods
        function obj = geometry(birthday)
            obj.birthday = birthday;
        end
        
        function amount = get.amount(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            amount = 230 - sum(obj(1).birthday.Day+obj.birthday.Month+obj.birthday.Year);
            if obj.birthday.Year > 1999
                amount = amount + 2000;
            else
                amount = amount + 1900;
            end
        end
        
        function geometry = get.side(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            birthday = obj.birthday;
            geometry = 630 - sum(birthday.Day+birthday.Month+birthday.Year);
            if obj.birthday.Year > 1999
                geometry = geometry + 2000;
            else
                geometry = geometry + 1900;
            end
        end
    end
    
end

