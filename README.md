# timers

Allows players to create arbitrary timers.

## Commands
`add`: Adds a new timer
* Syntax: `/timer add [duration] [label] [[repetitions]]`
* * Will add a timer based on given parameters
* `[duration]`: Required - Specifies seconds by default
* * Also accepts duration strings formatted as "#h#m#s"
* `[label]`: Required - Specifies a text label
* * If spaces are used, must be enclosed in quotes
* `[repetitions]`: Optional - Specifies repeating timers
* Examples
* * `/timer add 3m15s "Monster Respawn"`
* * `/timer add 21h "HNM Respawn" 30m 30m 30m`
* * `/timer add 21h "HNM Respawn" 30m x3`

`tod`: Adds a ToD timer
* Syntax: `/timer tod [time] [duration] [label] [[repetitions]]`
* * Will add a ToD timer based on given parameters
* `[time]`: Required - Specifies the time of death
* `[duration]`: Required - Specifies seconds by default
* * Also accepts duration strings formatted as "#h#m#s"
* `[label]`: Required - Specifies a text label
* * If spaces are used, must be enclosed in quotes
* `[repetitions]`: Optional - Specifies repeating timers
* Examples
* * `/timer tod 8:45am 3m15s "Monster Respawn"`
* * `/timer tod 8:45:37 21h "HNM Respawn" 30m 30m 30m`
* * `/timer tod 8:45:37 21h "HNM Respawn" 30m x3`
* **A known limitation of this system involves use cases where the ToD is greater than 1 day old. There is currently no setup for adding a date to the ToD specified. If the current time is 12:00pm and a ToD of 12:01pm is specified, the assumption is the ToD was 23 hours 59 minutes ago.**

`list`: List existing timers
* Syntax: `/timer list`

`remove`: Removes a specific timer
* Syntax: `/timer remove [name]`
* * Will remove a specified timer
* `[name]`: Required - the name of the timer to remove

`extend`: Add time to an existing timer
* Syntax: `/timer extend [name] [duration]`
* * Will extend a timer by a specified duration
* `[name]`: Required - the name of the timer to extend
* `[duration]`: Required - the amount of time to add

`clear`: Clears all timers
* Syntax: `/timer clear`

`profile`: Create or load a timer preset profile
* Syntax: `/timer profile [load|new|list] [[name]]`
* * Load a saved profile or create a new profile
* * `name` is required when creating a profile or loading a profile

`config`: Set addon configuration options
* Syntax: `/timer config [option] [value]`
* * Options are listed at the bottom of this readme
  
## Profiles
Profiles are a way of storing timers with specific names. This allows quick creation of timers with spawn windows and repeating spawn times. The primary purpose for utilizing multiple profiles is to allow for variations in private servers. Profiles are stored in the *[AshitaRoot]/config/timers/presets* directory.

Example:
```json
[
  {
    "name": "behemoth",
    "alias": ["kb", "king behemoth"],
    "duration": "21h",
    "repetitions": ["30m", "x7"]
  },
  {
    "name": "fafnir",
    "alias": ["nidhogg"],
    "duration": "21h",
    "repetitions": ["30m", "x7"]
  },
  {
    "name": "adamantoise",
    "alias": ["aspid", "aspidochelone"],
    "duration": "21h",
    "repetitions": ["30m", "x7"]
  }
]
```
With this configuration loaded, you can quickly add a respawn timer for any of these HNMs with the following commands:
* `/timer add kb` Will create a series of timers labeled "behemoth"
* `/timer tod fafnir 10:30pm` will create a series of timers labeled "fafnir" based on a ToD of 10:30pm.

## Configuration Options
Options are stored in the *[AshitaRoot]/config/timers/config.json* file. Not every value listed in the file has an implementation. Options may be set with the command `/timer config [option] [value]`. Current valid options are listed below, with default values in bold.

| Option | Values | Notes |
| :---: | :---: | --- |
| autohide | **true** \| false | Sets whether or not the timer window hides automatically when all timers are finished
| notifyonfinish | true \| **false** | Sets whether or not to play a sound when a timer ends
| sortdirection | asc \| **desc** | Sets whether timers are listed in ascending or descending order
| maxvisible | integer (**10**) | Sets the maximum number of visible timers
| width | integer (**500**) | Sets the width of the timer window
