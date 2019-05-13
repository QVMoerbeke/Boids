classdef geometry
    %GEOMETRY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        birthday datetime = date
    end
    
    properties (Dependent)
        birdNumber
        dimNumber
    end
        
    methods
        function obj = geometry(data)
            if nargin == 1
                if data
                    birthday = "";
                    tf = false;
                    while ~tf
                        birthday_str = input('Birthday (dd-mm-yyyy): ','s');
                        try
                            birthday = datetime(birthday_str,'InputFormat','dd-MM-yy');
                        catch
                            warning('Invalid input!')
                        end
                        tf = isdatetime(birthday);
                    end 
                else
                    birthday_str = '06-06-97'; 
                    birthday = datetime(birthday_str,'InputFormat','dd-MM-yy');
                end
                obj.birthday = birthday;
            end
        end
        
        function birdNumber = get.birdNumber(obj)
            % Obtain the birdNumber of birds through the following formula
            birdNumber = 230 - sum(obj(1).birthday.Day+obj.birthday.Month+obj.birthday.Year);
            if obj.birthday.Year > 1999
                birdNumber = birdNumber + 2000;
            else
                birdNumber = birdNumber + 1900;
            end
        end
        
        function geometry = get.dimNumber(obj)
            % Obtain the dimNumber of the cube through the following formula
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

