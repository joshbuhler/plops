# PLOpS

Pole-Line Operations Server

![](http://img.shields.io/badge/license-MIT-brightgreen.svg)
![](http://img.shields.io/badge/swift-5.1-brightgreen.svg)

---

A Vapor-powered application for runner operations at Pole-Line Pass for the Wasatch 100.


## Related Projects

### SerialPi
https://github.com/joshbuhler/SerialPi
PoC work for connecting to the W100 database via Swift.

### PlopsPrep
https://github.com/joshbuhler/plopsprep
PoC work for parsing log data as well as some runner predictions via CoreML.



## Notes
* https://medium.com/@jhheider/installing-vapor-and-swift-on-the-raspberry-pi-45a6c7baef35
* https://github.crookster.org/vapor-4-on-raspberry-pi-4-with-aarch64-swift-5.2/
* https://lickability.com/blog/swift-on-raspberry-pi-workshop/
* https://github.crookster.org/vapor-4-on-raspberry-pi-4-with-aarch64-swift-5.2/
* https://www.nickearl.net/2020/06/08/diy-wifi-router-access-point-with-raspberry-pi/
* https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/
* https://www.electronicwings.com/raspberry-pi/access-raspberry-pi-on-laptop-using-wi-fi



## Current Ideas - 2022.04.11

Build out the PLOpS web app first. I want a simple REST API that can be used for runner CRUD operations, and storage into a simple database. This will enable a minimum of two things:

1 - A simple web UI that can be used by aid station folks. They'll connect to our wifi, and hit the page to view the incoming runners. A basic vapor route will provide this. Another route could simply show the current list of runners at our station.
2 - Whatever service is running on the Pi to monitor axcall logs can simply use something like curl to POST data to the vapor app.

Eventually, a full web UI that can interact with the KISS terminal would be super. But the bare minimum above should be fine.


Print out a QR code with a link to the URL for the aid station folks.
https://www.qr-code-generator.com/


## Routes Needed

Initially, this will only return info about runners in the vapor side. Once we can ping axcall, we can be more full featured. Eventual goal is to duplicate the commands offered by the actual w100 system. But for now, these items should suffice.

/runner/all
	- GET
	- Provides a list of all runners currently logged.

/runner/<bib>
	- GET
	- Info about a runner based on bib number. Name, bib, other details.

/runner/<bib>/lastlocation
	- GET
	- Get the last known location of a runner 

/runner/create
	- POST
	- A JSON obj describing a runner to add to the system

/runner/<bib>
	- DELETE
	- A bib number of a runner to remove to the system

/runner/dnf
	- POST
	- A JSON obj describing a runner to flag as a DNF and when
		- { runner:Runner, time:1234, reason, where, how }
		- http://www.ke7bme.com/?page_id=14

/runner/dnf/all
	- GET
	- A list of all DNF runners



/checkpoint/all
	- GET
	- A list of all checkpoints
		- name
		- id ("a", "b", "c", etc.)
		- gps coords

/checkpoint/<id>
	- GET
	- Details about a specific checkpoint

/checkpoint/<id>/runners
	- GET
	- A list of runners currently checked in to the checkpoint

/checkpoint/<id>/inbound
	- GET
	- A list of runners currently inbound to the checkpoint
		- {
			timestamp:2123, // timestamp of request time
			runners:[ { runner:Runner, projected:2234 }]
		}

/checkpoint/<id>/checkin/
	- POST
	- A JSON obj describing which runner to checkin and when
		- { bib:123, time:1234 }

/checkpoint/<id>/checkout/
	- POST
	- A JSON obj describing which runner to checkout and when
		- { bib:123, time:1234 }

/temp
	- GET
	- Current temperature reported at the current station

	- Would like to auto-log the temp using the Pi. Could be neat to store a history and other weather info. Maybe even a big display for the runners & station staff