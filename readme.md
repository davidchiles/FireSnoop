# FireSnoop

An attempt to figure out the bluetooth protocol for FireChat.

## How-to Install

```
git clone https://github.com/davidchiles/FireSnoop.git
cd ./FireSnoop
pod install

```

## The Protocol (in progress)

There's a counter ... and that's about it.

### Counters

- First byte is always a counter 
	- if the first byte >128 then it's a start of message and then the second byte is number of following packets.
	- if second byte <128 then it's a following packet to complete a message.
	- All bytes after counter and number of packets is the payload (json in this case)	.
	
#### Example (Hex)

```
1st Packet: 8102...(payload)
2nd Packet: 02...(payload)
3rd Packet : 03...(payload)
4th Packet : 8400...(payload)
```
So in this case the first packet's counter is 81, in Hex, which is 129 in decimal and `129%128` is 1. That looks to be how the counter works. The counter goes from 0 to 128 (may be off by one) then for starting packets 128 is added to it.

But the counter increments on every message sent.

The number of packets that make up the first message is 3 including the first one because of the second byte. So far it looks like the max number of packets is 256 and the max packet size looks to be 132 bytes. So max payload size is 256*132-257 = 33,535 bytes

Then by the 4th packet a new message has come in that fits completely in the packet. We can tell the counter is at 4.


### JSON

This is the dictionary that makes up a firechat message that is then packetized.

```
{
	"name": "User's full name",
	"user": "Some username",
	"t": the time the message is created?
	likes: [ ],
	"h": true/false,
	"uuid": "some unique identifier",
	msg: "The actual messae",
	"firechat": "Nearby"
	"st": the time the message is sent?
}

```