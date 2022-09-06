# PLOpS

Pole-Line Operations Server

![](http://img.shields.io/badge/license-MIT-brightgreen.svg)
![](http://img.shields.io/badge/swift-5.1-brightgreen.svg)

---

A Vapor-powered application for runner operations at Pole-Line Pass for the Wasatch 100.


## Startup Checklist

1. Power up Pi
2. Connect LAN port to LAN1 of Luxul router
3. Verify that Pi has an IP of 192.168.0.133 using `ifconfig`
4. Start PLOpS
	5. `cd ~/projects/plops/plops`
	6. `vapor run serve --hostname 192.168.0.133` OR `.build/release/run` (best results w/ first one)
	7. Startup message will show in command-line
	8. Visit `http://192.168.0.133:8080` in browser.
9. Bind ax.25 ports
	10. `sudo kissattach /dev/serial0 1 10.1.1.1`
11. Start axlisten
	12. `sudo axlisten -a`
13. Connect to Race System
	14. `axcall 1 AC7BR-4` (Pick an appropriate callsign from the list below.)
	15. `connect RACE`
	16. `chkpt=l`
	17. Once connected, start log:
		18. `~o 2022_log.log`
	19. Tail log in new tab to verify:
		20. `tail -f ~/2022_log.log`
21. Connect to system wifi "Pole Line Pass"
22. Visit `http://192.168.0.133:8080` in browser.

## Known Callsigns

* W0HU-6
* KE7BME-2
* KE7BME-3
* K2WVC-1
* K2WVC-3
* K2WVC-6
* W0HU-5
* KD6OAT-7
* AC7BR-3
* AC7BR-4
* AC7BR-10
* KD0J-7

## Troubleshooting

- List processes using ports:
	+ `sudo lsof -i :8080`
	+ `kill <processID>`

- building toolbox
	+ https://github.com/vapor/toolbox/issues/371
	+ so u can try to compile it using this command : swift build -c release --disable-sandbox
and then move to the /usr/local/bin using this command : mv .build/release/vapor /usr/local/bin

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



## Current Ideas

### 2022.08.26

Current state of things:
	- Jyn app can monitor a log file and update every X seconds on macOS. On Raspbian, the FileHandles don't seem to read the file if it's updated outside of the app. Not sure why.
	- There is a StationStatus struct that can be used with the `/checkpoints/m/incomingrunners` route. Idea here was to have Jyn posting to the route, and have the db updated with that.
	- Vapor is running on the new pi, using postgres. Need to ensure that postgres is running:
		+ https://pimylifeup.com/raspberry-pi-postgresql/
		+ `psql`
	- Start the server, specifying the hostname connections can be made at:
		+ https://docs.vapor.codes/advanced/server/
		+ `vapor run serve --hostname 192.168.1.124:8080`
		+ `vapor run serve --hostname kc6bsa.local`
		+ `ctrl-c` to shut it down

TODO:
	- Read the log file based on a route. Thinking that maybe instead of using Jyn, I can use parts of it instead. When the route for the station status is hit, just load the log file, and find the most recent temperature and runner info, instead of trying to keep a running log.
	- Jyn currently looks for any incoming runners. So, if we try to look at who's incoming to another station, that could throw things off. Plan for that.
	- If loading the log on a route call, use a throttle - only load it up if it's been more than x minutes since the last update. Maybe can add a `forceRefresh` param to the route or something.
	- Startup script to get the radio stuff, vapor, and the wifi up and running.
	- Connecting to the station wifi should default to the plops status page.
		+ https://en.wikipedia.org/wiki/Captive_portal
		+ https://github.com/Splines/raspi-captive-portal
		+ https://github.com/pihomeserver/Kupiki-Hotspot-Script
		+ https://github.com/tretos53/Captive-Portal
	- Get the pi working w/ the radio.
	
Eventually:
	- Add a map with pins for runner estimates. We know when they left, when we expect them, so we could interpolate their position on the course, and drop an estimated pin.
	- http://download.geofabrik.de/north-america/us/utah.html
	- https://download.bbbike.org/osm/
	- https://github.com/magellium/osmtilemaker


### 2022.04.11

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