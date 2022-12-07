%this just finds the rand index of the truth masks vs the various spectral
%clustering results
clc
clearvars
load final_data.mat %data stored from the pipeline
%C CTI EM EMTI GC GCTI
d=dir('truth_masks\*.jpg'); %wherever truth masks are stored
rand_scores=zeros(10,6);


%make sure the number of pixels is consistent!!
num_pixels=500;
for I=1:length(d)
    im=imread([d(I).folder,'\',d(I).name]);
    count=numel(im)/3./[1:100].^2;
    [u, v]=min(abs(count-num_pixels));
    im=im(1:v:end,1:v:end,:);
    truth=im;
    
    truth=reshape(truth,[],3);
    [~,~,true_labels]=unique(truth,'rows');
    for J=1:6
        data=final_data{I,J};
        data=reshape(data,[],3);
        [~,~,labels]=unique(data,'rows');
        rand_scores(I,J)=rand_index(labels,true_labels);
    end
        

end
