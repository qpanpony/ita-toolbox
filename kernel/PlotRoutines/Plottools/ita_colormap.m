function rgb = ita_colormap
% enhancement of the artemis scale, increasing lightness with increasing value -> ideal for color and b&W plots


x = linspace(0,1,64);
rgb = artemis;

for idr = 1:20
    wb = sqrt(sum(rgb.^2,2))/sqrt(3);
    c_fact = wb./x.';
    c_fact(1) = 0;
    rgb = bsxfun(@rdivide,rgb,c_fact);
    rgb(1,:) = 0;
    %rgb = bsxfun(@rdivide,rgb ,max(max(rgb,1),[],2));
    
    wb = sqrt(sum(rgb.^2,2))/sqrt(3);
    
    for idx = 1:numel(x)
        if any(rgb(idx,:) > 1)
            num = max(rgb(idx,:)) - 1;
            rgb(idx,rgb(idx,:) > 1) = 1;
            rgb(idx,rgb(idx,:) > 1 & rgb(idx,:)>0) = rgb(idx,rgb(idx,:) > 1 & rgb(idx,:)>0) + num/sum(rgb(idx,:) > 1 & rgb(idx,:)>0);
        end
    end
    
    
    
    rgb(rgb<0) = 0;
    
end

end

