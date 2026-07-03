from scapy.all import Ether, IP, UDP, BOOTP,DHCP,  sendp, RandMAC
import time
import random
from datetime import datetime, timedelta


SIMULATED_DAYS = 3
REAL_TIME_DURATION_MIN = 30
INTERFACE = "eth0"
OUTPUT_CSV = "normal_traffic_log.csv"

total_intervals = SIMULATED_DAYS * 24 * 2
interval_real_time_sec = (REAL_TIME_DURATION_MIN * 60) / total_intervals

simulated_time = datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)


def send_dhcp_discover():
	mac = RandMAC()
	packet = 	Ether(dst="ff:ff:ff:ff:ff:ff")/ \
			IP(src="0.0.0.0", dst="255.255.255.255")/ \
			UDP(sport=68, dport=67)/ \
			BOOTP(chaddr=mac)/ \
			DHCP(options=[("message-type", "discover"), "end"])
	sendp(packet, iface=INTERFACE, verbose=0)
	return mac


for interval in range(total_intervals):
	if 8 <= simulated_time.hour < 18:
		num_requests = random.randint(0, 30)
		macs = []
		for _ in range(num_requests):
			mac = send_dhcp_discover()
			macs.append(mac)
			time.sleep(random.uniform(0.1, 1))
	simulated_time += timedelta(minutes=30)
	time.sleep(interval_real_time_sec)

