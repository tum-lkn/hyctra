%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hcytra is the simulation for PreBOTRA and DABTRA paper as in 
%H. M. Gursu; M. Vilgelm; W. Kellerer; M. Reisslein, "Hybrid Collision
%Avoidance-Tree Resolution for M2M Random Access," in IEEE Transactions on
%Aerospace and Electronic Systems , vol.PP, no.99, pp.1-1
% Please cite the paper in case you use the simulator in your work.
%Code by H. Murat Gürsu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "dist" is the distribution variable; 0 
% 1 is delta arrivals sets initial access to 1 for each user
% 2 is beta arrival distributes the users according to beta parameters
% 3 is poission arrivals distributes the users on a poisson based fashion
%--------------------------------------------------------------------
% "PB" is the Collision Avoidance parameter
%  0 no- prebackoff
%  1 prebackoff
%  2 dynamic Access Barring
%  3 PDFSA
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [coll_rat,drop_rat,suc_rat,mean_delay,tp_mean,mean_retx]=hyctra(numberuser,numberofpreambles,dist,PB,PBP,T_A,branchsize,retx)
simruntime=100000;
% Discrete time simulation requires a time limit. Should be adjusted for
% high number of users
ca_retx=zeros(1,numberuser);
ca_drop=zeros(1,numberuser);
ca_succ=zeros(1,numberuser);
ca_preamble=zeros(numberofpreambles,1);
ca_coll=zeros(numberofpreambles,simruntime);
ca_act=zeros(1,simruntime);
delaysuc=zeros(1,numberuser);
%Tree variables
ca_2=zeros(1,numberuser);
ca_pream_murat=zeros(simruntime,numberuser);
ca_time=zeros(numberofpreambles,1);
ca_pream_group=zeros(numberofpreambles,1);
ca_group=zeros(1,numberuser);
ca_tree=zeros((floor(numberofpreambles/branchsize)),simruntime);
%%taken from the table 3 of PDFSA paper for optimal gamme known N

accessbarring=0;
maxretx=retx;
ca_init=arrivaltrafficgenerate(numberuser,T_A,dist);
ca_init_0=ca_init;
throughput=zeros(1,simruntime);
ca=ca_init;
allusers=1:numberuser;
all_preambles=1:numberofpreambles;

if PB==0
    BOexponent=PBP;
elseif PB==1
    channelPBO=ceil(random('uniform',0,PBP*3,1,numberuser));
    ca_init=ca_init+channelPBO;   
    BOexponent=20;
elseif PB==2
    accessbarring=max(0,1-(54/numberuser));
    BOexponent=20;
elseif PB==3
    gamma=1.19;
    ro=1;
    accessbarring=1-(gamma*numberofpreambles)/(numberuser);
    %variable for state control
    state=0;
    BOexponent=20;
    timetocheck=ro;
    r_hist(state+1)=ro;
else
    BOexponent=20;
end


if branchsize<=1
    for i=1:simruntime

        %check the access list
        %every user roll dices 

        active_users=allusers(ca==i);
        user_roll=random('uniform',0,1,1,numberuser);
        barredguys=allusers(user_roll<accessbarring);

        %barred people selects the next slot.
        ca(intersect(active_users,barredguys))=i+1;

        %lets re adjust the active users
        active_users=allusers(ca==i);

        %select preamble on active users
        preamble_roll=ceil(random('uniform',0,numberofpreambles,1,numberuser));
        selected=preamble_roll(active_users);
        count_selection=histc(selected,all_preambles);

        %evaluate preamble results
        successes_pream=all_preambles(count_selection==1);
        successes=active_users(ismember(selected,successes_pream));
        collisions=all_preambles(count_selection>1);
        collided=active_users(ismember(selected,collisions));

        %increase retransmission counter
        ca_retx(collided)= ca_retx(collided) + 1;

        %drop the ones that exceeds the limit
        dropped= collided(ca_retx(collided) == maxretx);

        %backoff the ones that hasn't violated the limit
        non_dropped_collided = setdiff(collided,dropped);
        backoff_forallusers=ceil(random('uniform',0,BOexponent,1,numberuser));
        if PB==3
            ca(non_dropped_collided)= timetocheck+1;
        else
            ca(non_dropped_collided)= i + backoff_forallusers(non_dropped_collided);
        end
        % count drop, add collisions
        ca_drop(dropped)=1;
        ca_coll(collisions,i)=1;

        %count success
        count= length(successes);
        delaysuc(successes)=i-ca_init_0(successes);
        ca_succ(successes)=1;




    throughput(i)=count/numberofpreambles;    
        if (sum(ca_drop)/numberuser)+(sum(ca_succ)/numberuser)==1   
            break
        end
    %remove below code to remove DAB
        count2=sum((ca_init>(i+1)))+sum((ca>(i+1)));


        %%state machine for dynamic frame control
        if PB==3
            if state==0 && (i==timetocheck)
                prev_suc=sum(ca_succ);
                prev_col=sum(sum(ca_coll(:,1:i)));
                state =1;
                r=2;
                timetocheck=i+r;
                accessbarring_pdfsa = 1-(gamma*numberofpreambles)/(numberuser-prev_suc);
                r_hist(state+1)=r;
            elseif state > 0 && (i==timetocheck)
                state =state +1;
                sucs_in_state= sum(ca_succ) -prev_suc;
                prev_suc=sum(ca_succ);
                colls_in_state = sum(sum(ca_coll(:,1:i))) -prev_col;
                prev_col=sum(sum(ca_coll(:,1:i)));
                r= ceil(max(r*numberofpreambles - sucs_in_state,2*colls_in_state)/numberofpreambles);
                timetocheck=i+r;
                accessbarring_pdfsa = 1-(gamma*numberofpreambles)/(numberuser-prev_suc);
                r_hist(state+1)=r;
            end
        end

        if PB==2
            accessbarring=max(0,1-numberofpreambles/count2);
        elseif PB==3
            accessbarring=accessbarring_pdfsa;
        end
    end
else
%Tree resolution need a different follow up on the backlogged users
    for i=1:simruntime      
        for j=1:numberuser
                 if ca_init(j)==i
                    if accessbarring>random('uniform',0,1)
                        ca_init(j)=i+1;
                    else
                        ca_act(i)=ca_act(i)+1;
                        pream=ceil(random('uniform',10^-5,54));
                        ca_pream_murat(i,j)=pream;
                        if ca_preamble(pream)==0
                            ca_preamble(pream)=j; 
                        %if collided backoff and increase retx counter
                        elseif ca_preamble(pream)>0
                            %collided(channelaccesspreamble(pream))=1;
                            %collided(j)=1;
                            ca_coll(pream,i)=1;
                            ca_retx(j)=ca_retx(j)+1;
                           [ca_time(pream),ca_pream_group(pream),ca_tree]=allocatenode(ca_tree,PBP);
                            if ca_retx(j)==maxretx
                                ca_drop(j)=1;
                            %if not then back-off
                            else
                                ca_2(j)=ca_time(pream);
                                ca_group(j)=ca_pream_group(pream);
                            end
                            ca_retx(ca_preamble(pream))=ca_retx(ca_preamble(pream))+1;

                            if ca_retx(ca_preamble(pream))==maxretx
                                ca_drop(ca_preamble(pream))=1;
                            else
                                ca_2(ca_preamble(pream))=ca_time(pream);
                                ca_group(ca_preamble(pream))=ca_pream_group(pream);
                            end
                            ca_preamble(pream)=-1;
                            %if collided backoff and increase retx counter
                        else
                            ca_retx(j)=ca_retx(j)+1;
                            if ca_retx(j)==maxretx
                                ca_drop(j)=1;
                            %if not then back-off
                            else
                                ca_2(j)=ca_time(pream);
                                ca_group(j)=ca_pream_group(pream);
                            end
                        end
                    end
                 end   

        end
        %check the access list
        for k=1:numberuser
                 if ca_2(k)==i

                        ca_act(i)=ca_act(i)+1;
                        pream=ceil(random('uniform',10^-5,branchsize))+branchsize*(ca_group(k)-1);
                        ca_pream_murat(i,k)=pream;
                        if ca_preamble(pream)==0
                            ca_preamble(pream)=k;
                        %if collided backoff and increase retx counter
                        elseif ca_preamble(pream)>0
                            %collided(channelaccesspreamble(pream))=1;
                            %collided(j)=1;
                            ca_coll(pream,i)=1;
                            ca_retx(k)=ca_retx(k)+1;
                            %if max retx reached drop
                            [ca_time(pream),ca_pream_group(pream),ca_tree]=allocatenode(ca_tree,i);
                            if ca_retx(k)==maxretx
                                ca_drop(k)=1;
                            %if not then back-off
                            else
                                ca_2(k)=ca_time(pream);
                                ca_group(k)=ca_pream_group(pream);
                            end
                            ca_retx(ca_preamble(pream))=ca_retx(ca_preamble(pream))+1;

                            if ca_retx(ca_preamble(pream))==maxretx
                                ca_drop(ca_preamble(pream))=1;
                            else
                                ca_2(ca_preamble(pream))=ca_time(pream);
                                ca_group(ca_preamble(pream))=ca_pream_group(pream);
                            end
                            ca_preamble(pream)=-1;
                            %if collided backoff and increase retx counter
                        else
                            ca_retx(k)=ca_retx(k)+1;
                            if ca_retx(k)==maxretx
                                ca_drop(k)=1;
                            %if not then back-off
                            else
                                ca_2(k)=ca_time(pream);
                                ca_group(k)=ca_pream_group(pream);
                            end
                        end


                 end

        end
        ca_time=zeros(numberofpreambles,1);
        ca_pream_group=zeros(numberofpreambles,1);

    count=0;
        for l=1:numberofpreambles
            if ca_preamble(l)>0
                delaysuc(ca_preamble(l))=i-ca_init_0(ca_preamble(l));
                count=count+1;
                ca_succ(ca_preamble(l))=1;
            end
        end

    throughput(i)=count/numberofpreambles;
    ca_preamble=zeros(54,1);     
        if (sum(ca_drop)/numberuser)+(sum(ca_succ)/numberuser)==1   
            break
        end


    count2=1;
    for x=1:numberuser
        if ca_init(x)==i+1
            count2=count2+1;
        end
    end


        if PB==2
            accessbarring=max(0,1-(54/count2));
        end
    end      
end
coll_rat=mean(sum(ca_coll(:,1:i))/numberofpreambles);
drop_rat=sum(ca_drop)/numberuser;
suc_rat=sum(ca_succ)/numberuser;
mean_delay=mean(delaysuc);
tp_mean=mean(throughput(1:i));
mean_retx=mean(ca_retx);


% Type hold to see how different protocols behave on CDFs
cdfplot(delaysuc);
