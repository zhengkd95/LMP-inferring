function y = rmse(y1,y2)
    y0 = y1(:)-y2(:);
    y = sqrt(mean(y0.^2));
end