hidden_neurons = 25;


% input to numer kraju i dzie? od pocz?tku pandemii
% output to numer kraju i liczba potwierdzonych przypadków

Training_Input = zeros(2,1);
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

for i=1:size(Daily_Stats,1)
    current_country_number = Daily_Stats(i,1);
    if current_country_number ~= previous_country_number && size(Training_Input,2) > 2 
        
        max_day = Training_Input(2,size(Training_Input,2));
        
        Test_Days = linspace(max_day, max_day + 75, 76);
        
        for k=1:size(Test_Days,2)
            Covid_Prediction_Input(1,k) = previous_country_number;
            Covid_Prediction_Input(2,k) = Test_Days(k);
        end
        
        
        %input_size = 2;
        %output_size = 2;


        net = feedforwardnet(hidden_neurons);
        net = configure(net,Training_Input,Training_Output);
        net.divideFcn='dividetrain';
        net.layers{1}.transferFcn='tansig';


        % view(net)
        net.IW{1} = rand(hidden_neurons, 1);
        net.b{1} =  rand(hidden_neurons, 1);
        net.LW{2,1} =  rand(1, hidden_neurons);
        net.b{2} =  rand(1, 1);

        net.trainParam.epochs = 10000;
        net.trainParam.goal = 10 ^ -3;
        net.trainParam.time=600;

        net = train(net,Training_Input,Training_Output);

        % Zaokr?glenie, nie mo?e by? cz??ci u?amkowej osoby
        Test_Train = round(net(Training_Input));

        perf_train = perform(net, Training_Output, Test_Train);
        
        Performances_Training(previous_country_number) = perf_train;
        
        Collective_Reults_Training = [Collective_Results_Training Test_Train];
        
        Test_Prediction = round(net(Covid_Prediction_Input));

        %perf_prediction = perform(net, Covid_Prediction_Input, Test_Prediction);
        
        %Performances_Prediction(previous_country_number) = perf_prediction;
        
        Collective_Reults_Prediction = [Collective_Results_Prediction Test_Prediction];
        
        % Create two columns of data
        country_name = char(Countries(previous_country_number));
        % Create a table with the data and variable names
        % T = table(A, B, 'VariableNames', {'Day', 'Cases'} );
        Day = Training_Input(2,:)';
        Cases = Test_Train(2,:)';
        Training = table(Day, Cases);
        country_name = strrep(country_name,'\',' ');
        filename = strcat('E:\AGH\SSN\Projekt\SSN_Projekt\New_deaths\',country_name,'_training.txt');
        % Write data to text file
        writetable(Training,filename,'Delimiter',' ');
        
        
        Day  = Test_Days';
        Cases = Test_Prediction(2,:)';
        Predictions = table(Day, Cases);
        country_name = strrep(country_name,'\',' ');
        filename = strcat('E:\AGH\SSN\Projekt\SSN_Projekt\New_deaths\',country_name,'_prediction.txt');
        % Write data to text file
        writetable(Predictions,filename,'Delimiter',' ');
        
        Training_Input = zeros(2,1);
        Training_Output = zeros(2,1);
        j = 1;
        
    end 
    if Daily_Stats(i,3) >= 10
        Training_Input(1, j) = Daily_Stats(i,1);
        Training_Input(2,j) = Daily_Stats(i,2);
        Training_Output(1,j) = Daily_Stats(i,1);
        Training_Output(2,j) = Daily_Stats(i,7);
        j = j+1;
    end
    previous_country_number = current_country_number;    
end


Training_Performance = Performances_Training';

Performance = table(Training_Performance);
filename = strcat('E:\AGH\SSN\Projekt\SSN_Projekt\New_deaths\Performance.txt');
% Write data to text file
writetable(Performance,filename,'Delimiter',' ');



