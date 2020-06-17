hidden_neurons = 25;


% input to numer kraju i dzie? od pocz?tku pandemii
% output to numer kraju i liczba potwierdzonych przypadków

Training_Input = zeros(3,1);
Training_Output  = zeros(2,1);
Covid_Prediction_Input(1,1) = 0;
Covid_Prediction_Output(1,1) = 0;
j = 1;
%countries_number = max(Daily_Stats,1);
% Stworzenie sieci, która by?aby w stanie przewidywa? rozwój pandemii w
% danym dniu jest niemo?liwe, uczenie przebiega zbyt wolno, a zwracane
% wyniki s? bardzo z?e. Wynika to najprawdopodobniej z prostoty struktury
% sieci, a tak?e, mo?e nawet przede wszystkim z tego, ?e pandemia w ka?dym
% kraju post?puje w inny sposób i stworzenie sieci, która b?dzie w stanie
% to dobrze obrazowa? na podstawie zaledwie dwóch parametrów jest
% nieosi?galne. Dla niektórych krajów mamy znacznie mniej danych ni? dla
% innych, co powoduje bardzo z?e zwracanie kraju.

%{
for i=1:size(Daily_Stats,1)
   if Daily_Stats(i,3) > 10
       training_input(1, j) = Daily_Stats(i,1);
       training_input(2,j) = Daily_Stats(i,2);
       training_output(1,j) = Daily_Stats(i,1);
       training_output(2,j) = Daily_Stats(i,3);
       j = j+1;
       %training_output(3,i) = Daily_Stats(i,4);
       %training_output(4,i) = Daily_Stats(i,5);
   end
end
%}

Collective_Results_Training = [];
Collective_Results_Prediction = [];
Performances_Training = zeros(1,1);
Performances_Prediction = zeros(1,1);
current_country_number = 1;
previous_country_number = 1;
number_of_valid_data = 0;

for i=1:size(Daily_Stats,1)
    current_country_number = Daily_Stats(i,1);
    if current_country_number ~= previous_country_number && size(Training_Input,2) > 2  && previous_country_number ~= 87
        
        max_day = Training_Input(2,size(Training_Input,2));
        
        Test_Days = linspace(max_day, max_day + 75, 26);
        
        
        %input_size = 2;
        %output_size = 2;


        net = feedforwardnet(hidden_neurons);
        net = configure(net,Training_Input,Training_Output);
        net.divideFcn='dividetrain';
        net.layers{1}.transferFcn='logsig';
        net.layers{2}.transferFcn='purelin';


        % view(net)
        net.IW{1} = rand(hidden_neurons, 2);
        net.b{1} =  rand(hidden_neurons, 1);
        net.LW{2,1} =  rand(1, hidden_neurons);
        net.b{2} =  rand(1, 1);

        net.trainParam.epochs = 10000;
        net.trainParam.goal = 10 ^ -7;
        net.trainParam.time=600;

        net = train(net,Training_Input,Training_Output);

        % Zaokr?glenie, nie mo?e by? cz??ci u?amkowej osoby
        Test_Train = round(net(Training_Input));

        perf_train = perform(net, Training_Output, Test_Train);
        
        Performances_Training(previous_country_number) = perf_train;
        
        Test_Prediction_Collective = [];
        
        previous_day_prediction = Training_Input(3, size(Training_Input, 2));
        
        
        %Collective_Reults_Training = [Collective_Results_Training Test_Train];
        for k=1:size(Test_Days,2)
            Test_Prediction = round(net([previous_country_number;Test_Days(k);previous_day_prediction]));
            previous_day_prediction = Test_Prediction(2);
            Test_Prediction_Collective = [Test_Prediction_Collective Test_Prediction];
        end

        %perf_prediction = perform(net, Covid_Prediction_Input, Test_Prediction);
        
        %Performances_Prediction(previous_country_number) = perf_prediction;
        
        Collective_Reults_Prediction = [Collective_Results_Prediction Test_Prediction];
        
        % Create two columns of data
        country_name = char(Countries(previous_country_number));
        % Create a table with the data and variable names
        % T = table(A, B, 'VariableNames', {'Day', 'Cases'} );
        Day = Training_Input(2,:)';
        Recoveries = Test_Train(2,:)';
        Previous = Training_Input(3,:)';
        Training = table(Day, Recoveries, Previous);
        country_name = strrep(country_name,'\',' ');
        filename = strcat('C:\Users\Pawe³\Desktop\Studia\Sieci neuronowe\projekt\SSN_Projekt\Recoveries_Pawel\',country_name,'_training.txt');
        % Write data to text file
        writetable(Training,filename,'Delimiter',' ');
        
        
        Day  = Test_Days';
        Recoveries = Test_Prediction_Collective(2,:)';
        Predictions = table(Day, Recoveries);
        country_name = strrep(country_name,'\',' ');
        filename = strcat('C:\Users\Pawe³\Desktop\Studia\Sieci neuronowe\projekt\SSN_Projekt\Recoveries_Pawel\',country_name,'_prediction.txt');
        % Write data to text file
        writetable(Predictions,filename,'Delimiter',' ');
        

    end 
    if current_country_number ~= previous_country_number
        Training_Input = zeros(3,1);
        Training_Output = zeros(2,1);
        j = 1;
    end
    if Daily_Stats(i,5) >= 11
        if mod(number_of_valid_data,3) == 0 
            Training_Input(1, j) = Daily_Stats(i,1);
            Training_Input(2,j) = Daily_Stats(i,2);
            Training_Input(3,j) = Daily_Stats(i-3, 5);
            Training_Output(1,j) = Daily_Stats(i,1);
            Training_Output(2,j) = Daily_Stats(i,5);
            j = j+1;
        end
        number_of_valid_data = number_of_valid_data + 1;
    end
    previous_country_number = current_country_number;    
end


Training_Performance = Performances_Training';

Performance = table(Training_Performance);
filename = strcat('C:\Users\Pawe³\Desktop\Studia\Sieci neuronowe\projekt\SSN_Projekt\Recoveries_Pawel\');
% Write data to text file
writetable(Performance,filename,'Delimiter',' ');



