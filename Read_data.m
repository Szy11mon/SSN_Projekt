Data_Basic = readtable('Covid_Data_Basic_converted.csv');
Data = readtable('Covid_Data_converted.csv');
Countries = cell(1,1);
Days = ones(191);
Countries{1} = '';
previous_country = '';
current_country = '';
current_number_confirmed = 0;
previous_number_confirmed = 0;
day = 1;
country_number = 1;
iter = 1;

for i=1:size(Data_Basic,1)
    current_country = char(Data_Basic{i,2});
    current_country = strrep(current_country,'*','');
    current_number_confirmed = Data_Basic{i,4};
    if strcmp(current_country, previous_country) ~= 0 && strcmp(previous_country, '') ~= 1;
        idx = find(ismember(Countries, previous_country));
        if idx
            Stats_at_the_end(idx, 1) = previous_number_confirmed;
        else
            Countries{iter, 1} = previous_country;
            Stats_at_the_end(iter, 1) = previous_number_confirmed; 
            iter = iter + 1;
            country_number = iter;
        end
    end
    previous_country = current_country;
    previous_number_confirmed = current_number_confirmed;
end

for i=1:size(Data_Basic,1)
    current_country = char(Data_Basic{i,2});
    current_country = strrep(current_country,'*','');
    country_number = find(ismember(Countries, current_country));
    Daily_Stats(i,1) = country_number;
    Daily_Stats(i,2) = Days(country_number);
    Daily_Stats(i,3) = Data_Basic{i,4};
    Daily_Stats(i,4) = Data_Basic{i,5};
    Daily_Stats(i,5) = Data_Basic{i,6};
    Daily_Stats(i,6) = Data_Basic{i,7};
    Daily_Stats(i,7) = Data_Basic{i,8};
    Daily_Stats(i,8) = Data_Basic{i,9};
    Days(country_number) = Days(country_number) + 1;
        
end

Countries{iter,1} = previous_country;

% Dodanie nadmiarowego pola, pozwalaj?cego na analiz? ostatniego
% alfabetycznie kraju w tabeli w g?ównym programie
dummy_field_idx = size(Data_Basic,1) + 1;

    Daily_Stats(dummy_field_idx,1) = 1000;
    Daily_Stats(dummy_field_idx,2) = 1000;
    Daily_Stats(dummy_field_idx,3) = 1000;
    Daily_Stats(dummy_field_idx,4) = 1000;
    Daily_Stats(dummy_field_idx,5) = 1000;

Daily_Stats = sortrows(Daily_Stats,1);