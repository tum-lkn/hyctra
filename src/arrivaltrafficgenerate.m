function channelaccessinit=arrivaltrafficgenerate(numberuser,T_A,distribution)

% Distribution decides the arrival type
% 1 is delta arrivals sets initial access to 1 for each user
% 2 is beta arrival distributes the users according to beta parameters
% 3 is poission arrivals distributes the users on a poisson based fashion


if distribution == 1 
    channelaccessinit=ones(1,numberuser);

elseif distribution == 2
    %T_A=2500;
    %The activation time is important depending on the number of users

    channelaccessinit=ceil(random('beta',3,4,1,numberuser)*T_A);
 
elseif distribution == 3
    %T_A=2500;
    %The activation time is important depending on the number of users

    channelaccessinit=ceil(random('poisson',50,1,numberuser));        
               
end

%prebackingoffthedistributions
%assumption is a backingoff period is given and the device selects a slot
%uniformly within this given time after he is activated.

end



