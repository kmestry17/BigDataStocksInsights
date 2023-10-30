import requests
import json
import csv
import socket
import time

# Configuration data
config = {
    "symbols": ["AAPL", "IBM", "GOOGL", "MSFT", "TSLA"],
    "api_key": "GQD1G61PZKAQ06KD",
    "url": "https://www.alphavantage.co/query",
    "port": 12345,
    "max_line_length": 511
}

# Function to send data to the specified port in chunks
def send_data_to_port(data, port, max_line_length):
    data_str = json.dumps(data)
    print("Data length:", len(data_str))
    chunks = [data_str[i:i + max_line_length] for i in range(0, len(data_str), max_line_length)]
    print("Total chunks: %d" % len(chunks))
    for i, chunk in enumerate(chunks, 1):
        print("Sending data chunk %d/%d to localhost:%s" % (i, len(chunks), port))
        print("Chunk length:", len(chunk))
	
        updateSocket = socket.socket()
        host = socket.gethostname()
        port = 12345
        updateSocket.connect((host, port))
        updateSocket.send(chunk + "\n")
    
print("Data sent successfully")

# Function to convert JSON data to CSV format
def convert_to_csv(data):
    csv_data = []
    for key, value in data.items():
        if isinstance(value, dict):
            row = [key] + value.values()
            csv_data.append(row)

    return csv_data

# Function to fetch stock data and send it to the specified port
def fetch_stock_data():
    for symbol in config["symbols"]:
        print("Fetching data for %s" % symbol)
        params = {
            "function": "TIME_SERIES_DAILY",
            "symbol": symbol,
            "interval": "1min",
            "apikey": config["api_key"]
        }
        response = requests.get(config["url"], params=params)
        data = response.json()

        # Print the first 10 lines of data received
        print("First 10 lines of data received:")
        for line in json.dumps(data, indent=2).split('\n')[:10]:
            print(line)

        # Convert data to CSV format
        csv_data = convert_to_csv(data)

        # Print the first 10 lines of converted data
        print("\nFirst 10 lines of converted data:")
        for row in csv_data[:10]:
            print(row)

        # Send data in chunks to port
        send_data_to_port(csv_data, config["port"], config["max_line_length"])

        # Data sent notification
        print("Data sent to port, now waiting for 60 seconds!")
        time.sleep(60)  # Wait for 1 minute

if __name__ == '__main__':
    fetch_stock_data()
