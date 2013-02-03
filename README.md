#Project 3 (Own Project). iPitbul

##Problem
**iPitbul** is the utility application that helps control of Pitbul Security GSM Alarm Systems via SMS or Call.

##Customer
Owners of Pitbul Security GSM Alarm Systems.

##Usage
Remotely, using **iPitbul**, user is able to:
                 
**DO:**

- *arm*
- *disarm*
- *turn on alarm*
- *turn off alarm*
- *replenish balance*

**REQUEST:**

- *balance*
- *current alarm status*
- *current power status*
- *software version*
- *IMEI*
- *GSM level in percentage*

***
##Behaviour
####UML Use Case Diagram
![Use Case Diagram](https://raw.github.com/moleksyuk/osx-project-3/master/Docs/UseCaseDiagram.png)
####UML Activiy Diagram
![Activiy Diagram](https://raw.github.com/moleksyuk/osx-project-3/master/Docs/ActivityDiagram.png)


`Check Configuration` - during each start of the application it should check whether it is configured or not.
In case when the application is **NOT CONFIGURED** a user should see `Settings View`. There user have to specify *phone number* & *password* required to correct managment of GSM Alarm System. These settings can be changed in any time from `Main View` via *Settings Button* on toolbar.

`Main View` - contains all available commands for managment of Pitbul Security GSM Alarm Systems devided in two sections:

- **Managment**
	- *Phone Number*
	- *Arm*
	- *Disarm*
- **Service Functions**
	- *Balance*
	- *Current alarm status*
	- *Current power status*
	- *Software version*
	- *IMEI*
	- *GSM level in percentage*
	- *Turn on alarm*
	- *Turn off alarm*
	- *Replenish balance*

`Execute Command` - clicking on *Phone Number* makes a call. Clicking on one of other commands opens SMS Window with predefined *Phone Number* and *Appropriate Message Body*.

`About View` - contains information about version, author etc. On this view user can `Rate Application`, `Tell Friends` about application via email and contact with support team via `Email Support`.

**iPitbul** must support 3 languages:

- English
- Ukrainian
- Russian

---
##And more…

[Yuml](http://yuml.me/) code for UML Use Case Diagram

````
[Customer]-(Run Application)
(Run Application)>(Check User's Settings)
[Customer]-(Open Main View)
(Open Main View)<(Open Settings View)
(Open Main View)<(Open About View)
(Open Main View)<(Execute Command)
(Execute Command)>(Use User's Settings)
(Open Settings View)<(Change User's Settings)
(Open About View)<(Lagal & Privacy)
(Open About View)<(Rate Application)
(Open About View)<(Tell Friends)
(Open About View)<(Email Support)
````


[Yuml](http://yuml.me/) code for UML Activity Diagram

````
(start)->(Check Configuration)-><a>-CONFIGURED>[Main View],
<a>-NOT CONFIGURED>[Settings View]->(Set/Change Settings)->[Main View],
[Main View]->[Settings View],
[Main View]->(Execute Command)->(end),
[Main View]->[About View]->[Main View],
[About View]->(Rate Application)->(end),
[About View]->(Tell Friends)->(end),
[About View]->(Legal & Privacy)->(end),
[About View]->(Email Support)->(end)
````