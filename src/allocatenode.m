function [time,group,ca_tree]=allocatenode(ca_tree,i)
time=0;
group=0;
for z=(i+1):length(ca_tree(1,:))
    for w=1:length(ca_tree(:,1))
        if ca_tree(w,z)==0
           time=z;
           group=w;
           ca_tree(w,z)=1;
           break;
        end
    end
    if time~=0 && group~=0
      break;
    end
end