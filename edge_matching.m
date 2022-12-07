%Convolutional Neural Networks on Graphs
%with Fast Localized Spectral Filtering,
%"graph coarsening" section.

%This coarsens by going over each node one by one and finding it's closest
%neighbour as measued by max(Wij/(Di+Dj)) from its unmarked neighbors. 
%the node and its match are then merged. an edge is marked after going 
%through this process. this cuts the graph basically in half
function [new_graph, labels]=edge_matching(W)
    tic
    counter=0;
    
    N=length(W);
    labels=strsplit(num2str(1:N))';
    marked=false(N,1);
    D=sum(W,2);
    
    while any(~marked)

        %start loop. run while any nodes are not marked
        ind=find(~marked,1);

        %gather information about its connections, ignoring 0 entries and marked
        %nodes
        connections=W(:,ind).*(~marked);
        neighbors=find(connections);
        connections=connections(neighbors);
        degrees=D(neighbors);
        %make the "distance" vector
        Dij=connections./(D(ind)+degrees);
        %then find the minimum
        [~,match]=max(Dij);
        %if all of this node's neighbors are marked, continue to the next node.
        if isempty(match)
            marked(ind)=1;
            continue
        end

        match=neighbors(match);

        %then merge the nodes. add weights, delete.
        new_weights=W(:,ind)+W(:,match);
        new_weights([ind,match])=0; %remove self connections
        W(:,ind)=new_weights;
        W(ind,:)=new_weights;
        W(:,match)=[];
        W(match,:)=[];
        D(ind)=sum(new_weights);
        D(match)=[];
        %mark edge
        marked(ind)=1;
        marked(match)=[];

        labels{ind}=[labels{ind},', ',labels{match}];
        labels(match)=[];
        
        %stats
        counter=counter+1;
        if mod(counter,1000)==0
            counter
            toc
        end
    end
    new_graph=W;
end

