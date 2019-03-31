function load = get_load(input,year,month)
num= xlsread(input);
num = num(num(:,2)==year & num(:,3)==month,:);
load = [];
for k = 1:31
    try
        day_load = num(num(:,4)==k,5:end);
        load = [load, day_load];
    catch error
        break
    end
end
    
end