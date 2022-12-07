clc
clearvars
close all
folder=dir('originals\*.jpg'); %wherever you stored the images
folder(contains({folder.name},'figure'))=[];
load final_data.mat %this is the folder with the results stored from the pipeline
titles={'C','CTI', 'EM','EMTI','GC','GCTI'};
indeces=[2 3 5 6 8 9];


%make sure the number of pixels is consistent!!
num_pixels=500;
for I=1:length(folder)
    figure
    name=folder(I).name(1:end-4);
    im=imread([folder(I).folder,'\',name,'.jpg']);
    %keep the size consistent
    count=numel(im)/3./[1:100].^2;
    [u, v]=min(abs(count-num_pixels));
    im=im(1:v:end,1:v:end,:);
    subplot(3,3,4)
    imshow(im)
    for J=1:6
        subplot(3,3,indeces(J))
        imshow(final_data{I,J})
        title(titles{J})
    end
    set(gcf, 'Position', get(0, 'Screensize'));
    saveas(gcf,['figures\',name,'_figure.jpg']);
end