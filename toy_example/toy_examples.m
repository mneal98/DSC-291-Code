clc
clearvars
close all
load Data6.mat
data=XX;
clear XX;
%this does the toy example requested, using the data from hw4.

for I=1:length(data)
% for I=1
    figure
    d=data{I};
    %do Specrtal Clustering on the data with the group num
    W=im_to_graph(d,10);
    D=diag(1./sum(W));
    L=sparse(eye(size(W))-W*D);
    [u v]=eigs(L,3,'smallestabs');
    orig_labels=kmeans(u,group_num(I));
    subplot(3,1,1)
    for J=1:group_num(I)
        scatter(d(orig_labels==J,1),d(orig_labels==J,2))
        hold on
    end
    title('Original Graph')
    
    %then coarsen with EM
    [EM,cond_labels]=edge_matching(W);
    D=diag(1./sum(EM));
    L=sparse(eye(size(EM))-EM*D);
    [u v]=eigs(L,3,'smallestabs');
    labels=kmeans(u,group_num(I));
    %expand labels
    true_labels=zeros(length(W),1);
    for K=1:length(labels)
        true_labels(cellfun(@str2num,strsplit(cond_labels{K},', ')))=labels(K);
    end
    subplot(3,1,2)
    for J=1:group_num(I)
        scatter(d(true_labels==J,1),d(true_labels==J,2))
        hold on
    end
    %find the rand index
    RI=round(rand_index(orig_labels,true_labels),3);
    title(['EM, RI=',num2str(RI)])
    
    %then do it with mgc
    [GC,cond_labels]=graph_coarsener(W,floor(length(W)/2));
    D=diag(1./sum(GC));
    L=sparse(eye(size(GC))-GC*D);
    [u v]=eigs(L,3,'smallestabs');
    labels=kmeans(u,group_num(I));
    %expand labels
    true_labels=zeros(length(W),1);
    for K=1:length(labels)
        true_labels(cellfun(@str2num,strsplit(cond_labels{K},', ')))=labels(K);
    end
    subplot(3,1,3)
    for J=1:group_num(I)
        scatter(d(true_labels==J,1),d(true_labels==J,2))
        hold on
    end
    RI=round(rand_index(orig_labels,true_labels),3);
    title(['GC, RI=',num2str(RI)])
    
        
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf,['example_',num2str(I),'.jpg']);
end
