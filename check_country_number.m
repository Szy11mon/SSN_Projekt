previous_country_number = 1;
for i=1:size(Daily_Stats,1)
    country_name = char(Countries(previous_country_number));
    current_country_number = Daily_Stats(i,1);
    if strcmp (country_name,'Poland') 
        italy_number = Daily_Stats(i,1);
    end
    previous_country_number = current_country_number;
end