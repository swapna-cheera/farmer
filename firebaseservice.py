import time
import firebase_admin
import serial
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
cred = credentials.Certificate("/home/pi/firebase/serviceAccountKey.json")  # Update with the correct path
firebase_admin.initialize_app(cred)

# Access Firestore
db = firestore.client()

def send_data_to_firestore(moisture, temperature, waterlevel):
    """
    Sends a new document with sensor data to the 'sensorsdata' collection.
    """
    doc_ref = db.collection("sensorsdata").document()  # Automatically generates a new document ID
    doc_ref.set({
        'motor': True,
        'solenoidvalve': 0,
        'soilmoisture': moisture,
        'temperaturehumidity': temperature,
        'waterlevelindicator': waterlevel,
        'timestamp': firestore.SERVER_TIMESTAMP  # Automatically set the server-side timestamp
    })
    print("New document created in 'sensorsdata' collection!")

def read_sensor_data(ser):
    """
    Reads and parses sensor data from the serial connection in the format '61-75-958'.
    """
    try:
        ser.write(b"Read sensor data\n")  # Send a command to Arduino (if required)
        line = ser.readline().decode('utf-8').strip()  # Read and decode serial data
        
        # Assuming the data format is: "61-75-958"
        parts = line.split("-")
        if len(parts) == 3:
            moisture = int(parts[0])      # First part is moisture
            temperature = int(parts[1])   # Second part is temperature
            waterlevel = int(parts[2])    # Third part is water level
            return moisture, temperature, waterlevel
        else:
            raise ValueError("Unexpected data format")
    except Exception as e:
        print(f"Error reading sensor data: {e}")
        return None, None, None

def main(interval_minutes):
    """
    Reads sensor data and sends it to Firestore at regular intervals.
    
    :param interval_minutes: Time interval in minutes between each data send
    """
    ser = serial.Serial("/dev/ttyACM0", 9600, timeout=1)
    ser.reset_input_buffer()
    
    while True:
        try:
            moisture, temperature, waterlevel = read_sensor_data(ser)
            if moisture is not None:
                send_data_to_firestore(moisture, temperature, waterlevel)
        except Exception as e:
            print(f"Error: {e}")
        
        print(f"Waiting for {interval_minutes} minutes...")
        time.sleep(interval_minutes * 60)  # Convert minutes to seconds

# Run the script with a 5-minute interval
if __name__ == "__main__":
    main(interval_minutes=5)  # Change to 10 for 10-minute intervals
