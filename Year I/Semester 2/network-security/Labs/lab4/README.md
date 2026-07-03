# lab4

## 1.

c) Identify a client and an Access Point (AP). Find the corresponding MAC addresses.

```
Client: Apple_82:36:3a (00:0d:93:82:36:3a)
AP: CiscoLinksys_82:b2:55 (00:0c:41:82:b2:55)
```

d) Identify the broadcast messages sent by the AP. Which is the SSID? Which is the beacon interval?

```
SSID: Coherer
BI: 100
```

e) Search for HTTP traffic. Find and follow a TCP or HTTP stream. Name a website the client
visits.

```
http://www.google.com/search?q=%22land+shark%22+candygram&start=0&ie=utf-8&oe=utf-8&client=firefox-a&rls=org.mozilla:en-US:official
http://en.wikipedia.org/wiki/Landshark
```

## 2.

b) Find the values of the two nonces further used in the key agreement.

```
WPA Key Nonce: 3e8e967dacd960324cac5b6aa721235bf57b949771c867989f49d04ed47c6933
WPA Key Nonce: cdf405ceb9d889ef3dec42609828fae546b7add7baecbb1a394eac5214b1d386
```

c) Find the value of the GTK.

```
GTK: ee22041a83853263474c38811352282071c122359b7c35a7e7d034f3cd6ac565
```

d) Which of the four frames is integrity protected?

```
2nd, 3rd and 4th.
```

e) Which of the four frames contains encrypted data? Why?

```
The 3rd frame contains encrypted data because the AP sends the GTK encrypted.
```

f) Find the values of the two EAPOL keys Key Confirmation Key (KCK) and Key Encryption Key (KEK). What are these used for?

```
[KCK: b1cd792716762903f723424cd7d16511]
[KEK: 82a644133bfa4e0b75d96d2308358433]

KCK - used for integrity check
KEK - used to encrypt the GTK in the 3rd frame
```
