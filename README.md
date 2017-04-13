# hyctra

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hcytra is the simulation source code for PreBOTRA and DABTRA paper as in 
%Matlab is required to run the simulator
%H. M. Gursu; M. Vilgelm; W. Kellerer; M. Reisslein, "Hybrid Collision
%Avoidance-Tree Resolution for M2M Random Access," in IEEE Transactions on
%Aerospace and Electronic Systems , vol.PP, no.99, pp.1-1

%Code by H. Murat Gürsu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% "dist" is the distribution variable; 0 
% 1 is delta arrivals sets initial access to 1 for each user
% 2 is beta arrival distributes the users according to beta parameters
% 3 is poission arrivals distributes the users on a poisson based fashion
%--------------------------------------------------------------------
% "PB" is the Collision Avoidance parameter
%  0 no- prebackoff
%  1 prebackoff
%  2 dynamic Access Barring
%  3 PDFSA (Another hybrid protocol similar to "access barring + tree")
%---------------------------------------------------------------
% "PBP" is he prebackoff size parameter
%  it is also used for back-off in cases without prebackoff or AB
%------------------------------------------
%  "T_A" is the activation time of the beta distribution
%-------------------------------------------------------
% branchsize is the tree algorithm parameter for branching size
%  1 for non-tree algorithms
% >1 for any branchsize as wished
%------------------------------------
%  Other variables are self explanatory
% Outputs
% coll_rat = Ratio of collided slots to all slots used
% drop_rat = Ratio of dropped users to all users
% suc_rat = Ratio of accessed users to all users (should be 1 - drop_rat (sanity check))
% mean_delay = Mean delay of all successful users
% tp_mean = Ratio of succesful slots to all slots used
% mean_retx = Mean number of transmissions for each user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
