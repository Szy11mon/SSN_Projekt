T1 = readtable('Covid_Data_Basic_converted.csv');
T2 = readtable('Covid_Data_converted.csv');
T3 = cell(1,1);
T3{1} = '';
previous = '';
current = '';
current_number = 0;
previous_number = 0;
iter = 1;
for i=1:size(T1,1)
    current = char(T1{i,2});
    current_number = T1{i,4};
    if strcmp(current, previous) == 0 && strcmp(previous, '') ~= 1;
        idx = find(ismember(T3, previous));
        if idx
            T3{idx} = previous;
            T4(idx) = previous_number;
        else
            T3{iter} = previous;
            T4(iter) = previous_number; 
            iter = iter + 1;
        end
    end
    previous = current;
    previous_number = current_number;
        
end