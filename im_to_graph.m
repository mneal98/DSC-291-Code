function [W] = im_to_graph(im, K)
%K= #nearet neighbours. it will increase this number if its too low and
%there are isolated points.
%im = image vector, typically n by 3. more channels are fine, but the rows
%should correspond to pixels.

    still_running=1;
    while still_running
     
        [knn, dists]=knnsearch(im,im,'K',K);
        sigma=median(dists,2);
        knn=reshape(knn',[],1);
        dists=reshape(dists',[],1);
        index=floor(1:1/K:length(knn)/K+1);
        index(end)=[];
        %convert dists to RBF values
        S=sigma(index).*sigma(knn);
        similarity=exp(-(dists.^2)./(S+.0001)); %+.001 in case S is 0
        %I set the minimum similarity to be some tiny non-zero amount, so
        %that all connections have some representation.
        similarity(similarity<10^-6)=10^-6;
        %make the sparse matrix
        W=sparse(index,knn,similarity);
        %symmetrify
        try
            W=(W+W')/2;
        catch
            K=K+1
            continue
        end
        %remove diagonal
        W=W-diag(diag(W));
        %if there is at least one node with no connections, increase K and try
        %again
        still_running=any(sum(W)==0);
        K=K+1;
    end
end

