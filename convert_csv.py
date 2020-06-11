import csv

with open('COVID_Data.csv', newline='') as csvread:
    csvreader = csv.reader(csvread, delimiter=' ', quotechar='|')
    with open('Covid_Data_converted.csv', 'w', newline='') as csvwrite:
        csvwriter = csv.writer(csvwrite, delimiter=' ', escapechar=" ", quoting=csv.QUOTE_NONE)
        for row in csvreader:
            row_value = ' '.join(row)
            to_write = row_value.replace("\"", "").replace("Bahamas, The", "Bahamas").replace(" ", "\\")
            to_write = [to_write]
            csvwriter.writerow(to_write)
