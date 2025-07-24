#!/bin/bash
set -e

echo "=== Installing dependencies ==="
sudo apt update
sudo apt install -y git cmake g++ libusb-1.0-0-dev python3-pip

echo "=== Cloning Lightpack source ==="
#git clone https://github.com/psieg/Lightpack.git ~/lightpack
cd ~/lightpack/Software/Lightpack

echo "=== Building Lightpack ==="
mkdir -p build
cd build
cmake ..
make -j2

echo "=== Installing Lightpack binary ==="
sudo cp Lightpack /usr/local/bin/lightpack

echo "=== Testing Lightpack detection ==="
/usr/local/bin/lightpack --list-devices || echo "⚠️  No device found (check USB connection)"

echo "=== Installing Flask for REST API ==="
pip3 install flask

echo "=== Creating REST API script ==="
cat <<EOF > ~/lightpack_api.py
from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route("/color", methods=["POST"])
def color():
    r = request.json.get("r", 0)
    g = request.json.get("g", 0)
    b = request.json.get("b", 0)
    subprocess.run(["/usr/local/bin/lightpack", f"--set-leds={r},{g},{b}"])
    return {"status": "ok", "color": [r, g, b]}

app.run(host="0.0.0.0", port=8080)
EOF

echo "=== Creating systemd service for autostart ==="
cat <<EOF | sudo tee /etc/systemd/system/lightpack-api.service > /dev/null
[Unit]
Description=Lightpack REST API
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/lightpack_api.py
User=pi
WorkingDirectory=/home/pi
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "=== Enabling and starting service ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable lightpack-api.service
sudo systemctl start lightpack-api.service

echo "=== Done ==="
echo "You can now POST to http://<raspberrypi>:8080/color with JSON like:"
echo '  { "r": 255, "g": 140, "b": 0 }'

