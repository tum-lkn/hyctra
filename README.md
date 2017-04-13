# hyctra
Requirements:
Matlab


hcytra is the simulation source code for PreBOTRA and DABTRA paper as in 
H. M. Gursu; M. Vilgelm; W. Kellerer; M. Reisslein, "Hybrid Collision
Avoidance-Tree Resolution for M2M Random Access," in IEEE Transactions on
Aerospace and Electronic Systems , vol.PP, no.99, pp.1-1

Contibutors:
H. Murat Gürsu

# Inputs:
1. "dist" is the distribution variable:
  * 1 is delta arrivals sets initial access to 1 for each user
  * 2 is beta arrival distributes the users according to beta parameters
  * 3 is poission arrivals distributes the users on a poisson based fashion


2. "PB" is the Collision Avoidance parameter
  * 0 no- prebackoff
  * 1 prebackoff
  * 2 dynamic Access Barring
  * 3 PDFSA (Another hybrid protocol similar to "access barring + tree")


3. "PBP" is he prebackoff size parameter
it is also used for back-off in cases without prebackoff or AB


4. "T_A" is the activation time of the beta distribution


5. branchsize is the tree algorithm parameter for branching size
  * 1 for non-tree algorithms
  * \> for any branchsize as wished


6. Other variables are self explanatory


# Outputs
1. coll_rat = Ratio of collided slots to all slots used
2. drop_rat = Ratio of dropped users to all users
3. suc_rat = Ratio of accessed users to all users (should be 1 - drop_rat (sanity check))
4. mean_delay = Mean delay of all successful users
5. tp_mean = Ratio of succesful slots to all slots used
6. mean_retx = Mean number of transmissions for each user



