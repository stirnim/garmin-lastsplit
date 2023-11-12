# About

Last Split - a Garmin [Connect IQ](https://developer.garmin.com/connect-iq/overview/) data field.

# Goal

Last Split displays the pace of the last km or mile (depending on your watch setting) at any time during an activity. It is useful to pace yourself evenly on a flat course. I use it to together with the built-in current and average pace.

You can think of it as if you had Auto Laps enabled but instead of only showing you the pace (or time) after each lap you can look at it at any time during an activity.

Restrictions: the slowest pace it can record is 15:00 minutes per km or mile.

Last Split stores the "fastest pace" over a km or mile in the FIT file. This information is then shown in the Garmin Connect activity summary.

# Implementation

This app implements a [SimpleDataField](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/SimpleDataField.html). The layout and font size of the data field is handled automatically by Garmin.

The screenshots below use the Last Split app in the "4 Field B" layout on a Garmin Forerunner 945:

![0](./screenshot/0.png)

# Installation

This app is on the Garmin [Connect IQ store](https://apps.garmin.com/en-US/apps/54f85cc9-a908-4a04-8642-f71663de200f).

## Side Loading

You can also build it for your watch yourself and install it using [App Side Loading](https://developer.garmin.com/connect-iq/programmers-guide/getting-started). Copy the compiled binary to the USB mounted Garmin watch into the directory `GARMIN/Apps`. On macos you can use [Android File Transfer](https://www.android.com/filetransfer/) as macos lacks good MTP (Media Transfer Protocol) support.

Or use the latest pre-built [binary](./build/garminlastsplit.prg) for Garmin Forerunner 965.

Note: side loaded apps don't show data from FIT files in the activity summary in the app or on the web.

# Version History

- 2023-11-10, Add support for more devices. Indicate supported language (ENG) (0.0.2)
- 2020-06-01, Fix unit in FIT activity (0.0.1)
- 2020-05-17, Initial release (0.0.0)
