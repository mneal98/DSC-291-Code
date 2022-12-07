%this adds texture to an image. this i am defining as the 2nd derivative of
%the each color channel added together. I will take the magnitude. this is estimated as just the del2
%function, then normalized to be between 0 and 255.
function [new_image]=add_texture(image)
    image=double(image);
    V=0;
    for I=1:3
        V=V+abs(del2(image(:,:,I)))/3;
    end
    %normalize
    V=255*(V-min(V(:)))/(max(V(:))-min(V(:)));
    
    new_image=cat(3,image,V);
end
        
        