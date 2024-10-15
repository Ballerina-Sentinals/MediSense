// import ballerina/io;
// import ballerina/task;
// import ballerina/time;

// public type Reminder record {|
//     int reminderId;
//     string reminderName;
//     time:Civil startDate;
//     int dateCount;
// |};

// //Function to calculate the difference in milliseconds between two Civil times
// public function getMillisecondsDifference(time:Civil startTime, time:Civil endTime) returns int {
//     return int(time:diff(startTime, endTime).toMillis());
// }

// Function to calculate the delay from the current time to the next occurrence of the alarm
// public function calculateInitialDelay(time:Civil startTime) returns int {
//     time:Utc currentTime = time:utcNow();
//     time:Civil now = time:utcToCivil(currentTime);

//     time:Civil nextOccurrence;

//      Check if the alarm time is today or tomorrow
//     if (now.hour < startTime.hour || (now.hour == startTime.hour && now.minute < startTime.minute)) {
//         // Alarm will trigger later today
//         nextOccurrence = { year: now.year, month: now.month, day: now.day, hour: startTime.hour, minute: startTime.minute };
//     } else {
//         nextOccurrence = { year: now.year, month: now.month, day: now.day + 1, hour: startTime.hour, minute: startTime.minute };
//     }

//     Use the new function to get the difference in milliseconds
//     return getMillisecondsDifference(now, nextOccurrence);
// }

// // Function to schedule the recurring alarm
// public function setRecurringAlarm(time:Civil startTime, int daysToRepeat) {
//     Calculate the initial delay for the first occurrence
//     int initialDelay = calculateInitialDelay(startTime);
    
//      Set the interval to 24 hours (in milliseconds)
//     int interval = 86400000; // 24 hours in milliseconds

//      Set up a counter to stop after the specified number of days
//     int count = 0;

//      Define the timer configuration
//     task:TimerConfiguration timerConfig = {
//         initialDelayInMillis: initialDelay,
//         intervalInMillis: interval
//     };

//      Create the timer to trigger the alarm every day
//     task:Timer timer = new(function () {
//         if (count < daysToRepeat) {
//             io:println("Alarm triggered for day ", count + 1);
//             count += 1;
//         } else {
//             // Stop the timer after the required number of repetitions
//             timer.stop();
//             io:println("Alarm stopped after ", daysToRepeat, " days.");
//         }
//     }, timerConfig);

//     io:println("Alarm is set to start at ", startTime.hour, ":", startTime.minute, " and repeat for ", daysToRepeat, " days.");
// }

