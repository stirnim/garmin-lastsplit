using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.FitContributor;
using Toybox.Math;
using Toybox.System;

class LastSplitView extends WatchUi.SimpleDataField {

    // the display value (string)
    hidden var mValue;
    // the distance we want to track
    hidden var distance;
    // number of seconds it took to cover the distance
    hidden var time;
    // the max. time the distance needs to be covered in
    const timeframe = 900;
    // array we track the distance and seconds
    hidden var distanceWindow;
    hidden var lastElapsedDistance;
    // Fit
    hidden var fastestTime;
    hidden var fitSummaryfastestTime;


    function initialize() {
        SimpleDataField.initialize();
        mValue = "--:--";
        var watchSettings = System.getDeviceSettings();
        if (watchSettings.distanceUnits == System.UNIT_METRIC) {
            distance = 1000;
        } else {
            distance = 1609.344;
        }
        time = 0;
        // create an empty array of fixed size
        distanceWindow = new [timeframe];
        // initialize the distanceWindow array
        for( var i = 0; i < timeframe; i += 1 ) {
            distanceWindow[i] = 0;
        }
        lastElapsedDistance = 0;
        fastestTime = 0;
        label = WatchUi.loadResource(Rez.Strings.label);
        
        // FIT nativeNum from Profile.xlsx [1]
        // Tab "Messages", Section "ACTIVITY FILE MESSAGES", Category "Session": enhanced_avg_altitude 126, m/s
        // [1] https://www.thisisant.com/resources/fit-sdk/
        fitSummaryfastestTime = createField(WatchUi.loadResource(Rez.Strings.fitSummaryDataName), 1, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_SESSION,
              :units => WatchUi.loadResource(Rez.Strings.fitSummaryDataUnit),
              :nativeNum => 126 });
    }


    // compute() is called every 1 second.
    // a simulation has shown that this is correct. at worst it may be delayed by 1 ms.
    // this has a neglectable effect.
    function compute(info) {
        if(info has :elapsedDistance and info has :timerTime and info has :timerState){
            if(info.elapsedDistance != null and info.timerTime != null){

                // only measure during active activity
                if (info.timerState == 3) {
                    // we keep track of the distance covered during the last "timeframe" seconds
                    var slotDistance = info.elapsedDistance - lastElapsedDistance;
                    lastElapsedDistance = info.elapsedDistance;
                    
                    // shift "window" by one
                    // reverse loop through the array; this throws away the last stored distanceWindow value
                    for( var i = timeframe - 1; i >= 1; i-- ) {
                        distanceWindow[i] = distanceWindow[i-1];
                    }
                    distanceWindow[0] = slotDistance;

                    // calculate the time it took to cover the "distance"
                    var countDistance = 0;
                    for( var i = 0; i < timeframe; i++ ) {
                        countDistance = countDistance + distanceWindow[i];
                        if (countDistance >= distance) {
                            time = i+1;
                            // Fit Summary: new fastest pace detected
                            if (fastestTime == 0 or time < fastestTime) {
                                fastestTime = time;
                            }
                            // break loop as we found the time it took to cover the "distance"
                            break;
                        }
                    }
                }
                
                if (info.elapsedDistance > distance) {
                    // show last split pace
                    mValue = timeToString(time);
                } else if (info.elapsedDistance > 0 and info.timerTime > 3) {
                    // show avg. pace until lap distance reached
                    mValue = timeToString(Math.round(info.timerTime / info.elapsedDistance / 1000 * distance).toLong());
                    //mValue = ((distance - info.elapsedDistance) / 1000).format("%0.2f");
                }
                System.println(Lang.format("At $1$ in $2$", [info.elapsedDistance.format("%d"), timeToString(info.timerTime / 1000)]));
            } else {
                mValue = "--:--";
            }
        }
        return mValue;
    }

    
    function onTimerStop() {
        // Fit Session - write fastest pace
        // round time in m/s to 3 digits after decimal point
        var fastestPace = 0.0;
        if (fastestTime > 0) {
            fastestPace = Math.round(1.0 / fastestTime * distance * 1000) / 1000;
        }
        System.println(Lang.format("Write Summary $1$", [fastestPace]));
        fitSummaryfastestTime.setData(fastestPace);
    }

    function timeToString(time){
        var seconds = time % 60;
        var minutes = (time / 60) % 60;
        var hours = time / 60 / 60;
        if (hours > 0) {
            return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        } else {
            return minutes.format("%d") + ":" + seconds.format("%02d");
        }
    }

}
