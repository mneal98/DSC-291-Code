%Graph Coarsening with Preserved Spectral Properties
%algorithm 1, MGC
function [coursened_graph,labels]=graph_coarsener(W,n)
  
    N=length(W);
    labels=strsplit(num2str(1:N))';
    %do the metric between nodes, dij= || wi/di-wj/dj||1, wj=vector
    
    for K=1:n

        
        if K==1
            %only make the full node-distance matrix on iteration 1
            %make the connection distribution matrix W2
            D=sum(W);
            W2=sparse(W*diag(1./D));
            %find the node-node distances
            dij=squareform(pdist(W2','cityblock'));
            %add a large value to self similarities so they are ignored
            dij=dij+5*eye(size(W));
            %do some rounding and make sparse. most of d is 2, so max 2-d
            %is the same as min d and is sparse
            dij=round(dij,5);
            dij=sparse(2-dij);
        else
            %now update dij by updating all the rows and columns that had an entry in
            %the combined node. these nodes had 1 or 2 values change, so their
            %distances changed.
            %but we need to update the index. index(2) was deleted, so all values after
            %that need to be shifted back one.
            ind1(ind1==index(2))=[];
            ind1(ind1>index(2))=ind1(ind1>index(2))-1;
            %add in the effected node if it wasnt already 
            ind1=unique([index(1);ind1]);
            %remove the removed node from dij
            dij(index(2),:)=[];
            dij(:,index(2))=[];
            %and now ind1 is just the ones we need to update.
            D=sum(W);
            W2(:,ind1)=sparse(W(:,ind1)*diag(1./D(ind1)));
            %make a matrix of all the new dists then sub them in
            z=zeros(length(W),length(ind1));
            for I=1:length(ind1)
                v=2-vecnorm(W2-W2(:,ind1(I)),1);
                v(ind1(I))=-3;
                z(:,I)=v;
            end
            z=round(z,6);
            for I=1:length(ind1)
                dij(ind1(I),:)=z(:,I);
                dij(:,ind1(I))=z(:,I);
            end



        end


        %find the smallest distance
        [~, v]=max(dij(:));
        %this just converts between indexing conventions. 
        [row, column]=ind2sub(size(W),v);
        index=sort([row,column]);
        %keep track of which nodes had non-zero weights associated with these
        %merged nodes so we can edit their distances later
        ind1=find(W(:,index(1))+W(:,index(2)));
        %make the new combined weights for the combined node, then delete the
        %values corresponding to the other node
        z=W(:,index(1))+W(:,index(2));
        W(:,index(1))=z;
        W(index(1),:)=z;
        W(:,index(2))=[];
        W(index(2),:)=[];
        
        W2(:,index(1))=z/sum(z);
        W2(index(1),:)=z/sum(z);
        W2(:,index(2))=[];
        W2(index(2),:)=[];




        labels{index(1)}=[labels{index(1)},', ',labels{index(2)}];
        labels(index(2))=[];
        
        %every so often, round dij to ensure as many things are 0 as
        %possible. if i don't do this, dij becomes less and less sparse and
        %execution time balloons per cycle.
        if mod(K,200)==0
            dij=round(dij,5);
            
        end
        
    end
    coursened_graph=W;
end