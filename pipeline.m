%this is the pipeline. it takes each image, runs the coarsening methods (or
%not), then does spectral clustering, all +/- texture and luminance for the
%six conditions.
%the results of each will be saved as a reshaped image indicating which
%group each pixel got assigned to, stored in the variable "final_data"

%I have the number of pixels set here to be 500 just so it's fast. for the
%project it was set to 20k.
num_pixels=500;
%images location:
images_folder=dir('originals\*.jpg');
final_data=cell(10,6);
for I=1:length(images_folder)
    %first load the image in
    im=double(imread([images_folder(I).folder,'\',images_folder(I).name]));
    %find the new scale to use. I will aim for 20K pixels. this finds the
    %approximate new number of pixels if a certain scale is used.
    count=numel(im)/3./[1:100].^2;
    [u v]=min(abs(count-num_pixels));
    im=im(1:v:end,1:v:end,:);
    
    %now make a new image with texture and intensity
    im_TI=im;
    im_TI=add_texture(im_TI);
    lumosity=(max(im_TI,[],3)+min(im_TI,[],3))/2;
    im_TI=cat(3,im_TI,lumosity);
    
    
    %this next section makes all the necessary graphs, named in
    %accordance with the report, C CTI  GC GCTI EM EMTI
    
    %store the original image size before reshaping
    shape=size(im);
    im=reshape(im,[],3);
    im_TI=reshape(im_TI,[],5);
    K=10;
    %feed into KNN graph with bandwidth tuning
    C=im_to_graph(im,K);
    %coarsen by half. recall that the labels cell say which nodes were
    %fused to make each new supernode.
    [GC, labels_GC]=graph_coarsener(C,floor(length(C)/2));
    %repeat with TI
    CTI=im_to_graph(im_TI,K);
    %coarsen by half
    [GCTI, labels_GCTI]=graph_coarsener(CTI,floor(length(CTI)/2));
    
    %and then the same for edge matching
    [EM, labels_EM]=edge_matching(C);
    [EMTI, labels_EMTI]=edge_matching(CTI);
    
    
    
    
    %now that we have all the reduced graphs, let's do the spectral
    %clustering and make the new images showing the clusters. This will be
    %like the above, with a lot of repetition.
    num_groups=6;
    colors=jet(num_groups);
    %first up, C
    D=diag(1./sum(C));
    L=sparse(eye(size(C))-C*D);
    [u v]=eigs(L,10,'smallestabs');
    %then do kmeans on the eigenvectors
    labels=kmeans(real(u),num_groups);
    %then assign a color based on the labels
    new_image=colors(labels,:);
    %reshape to be an image
    new_image=reshape(new_image,shape);
    %then save the results in final_data
    final_data{I,1}=new_image;
    
    %it gets repetive past here. 
    %repeat for CTI:
    D=diag(1./sum(CTI));
    L=sparse(eye(size(CTI))-CTI*D);
    [u v]=eigs(L,10,'smallestabs');
    labels=kmeans(real(u),num_groups);
    new_image=colors(labels,:);
    new_image=reshape(new_image,shape);
    final_data{I,2}=new_image;
    
    %repeat for EM
    D=diag(1./sum(EM));
    L=sparse(eye(size(EM))-EM*D);
    [u v]=eigs(L,10,'smallestabs');
    labels=kmeans(real(u),num_groups);
    %only difference is we must now unpack the condensed labels.
    true_groups=zeros(length(im),1); %these are the per pixel labels
    for J=1:length(labels)
        true_groups(cellfun(@str2num,strsplit(labels_EM{J},', ')))=labels(J);
    end
    %then assign colors as before.
    new_image=colors(true_groups,:);
    new_image=reshape(new_image,shape);
    final_data{I,3}=new_image;
    
    %repeat for EMTI
    D=diag(1./sum(EMTI));
    L=sparse(eye(size(EMTI))-EMTI*D);
    [u v]=eigs(L,10,'smallestabs');
    labels=kmeans(real(u),num_groups);
    true_groups=zeros(length(im),1);
    for J=1:length(labels)
        true_groups(cellfun(@str2num,strsplit(labels_EMTI{J},', ')))=labels(J);
    end
    new_image=colors(true_groups,:);
    new_image=reshape(new_image,shape);
    final_data{I,4}=new_image;
    
    %repeat for GC
    D=diag(1./sum(GC));
    L=sparse(eye(size(GC))-GC*D);
    [u v]=eigs(L,10,'smallestabs');
    labels=kmeans(real(u),num_groups);
    true_groups=zeros(length(im),1);
    for J=1:length(labels)
        true_groups(cellfun(@str2num,strsplit(labels_GC{J},', ')))=labels(J);
    end
    new_image=colors(true_groups,:);
    new_image=reshape(new_image,shape);
    final_data{I,5}=new_image;
    
    %repeat for GCTI
    D=diag(1./sum(GCTI));
    L=sparse(eye(size(GCTI))-GCTI*D);
    [u v]=eigs(L,10,'smallestabs');
    labels=kmeans(real(u),num_groups);
    true_groups=zeros(length(im),1);
    for J=1:length(labels)
        true_groups(cellfun(@str2num,strsplit(labels_GCTI{J},', ')))=labels(J);
    end
    new_image=colors(true_groups,:);
    new_image=reshape(new_image,shape);
    final_data{I,6}=new_image;
    
    %and that's it. go to the comparison figure and truth rand_index for
    %further analysis.
    I
end