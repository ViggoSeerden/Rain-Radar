# Rain-Radar
rain go brrrr

In this app you will find a rain radar app where you can see the weather for the up & coming days.
You will also find a page where you can set alarms, and a page where you see songs that have a title or artistname which is related to the current weather.

## Code
In the RainRadar Folder you can see the WeatherManager, MusicManager and the Views folder.

### WeatherManager
In the WeatherManager folder can you find the LocationDataManager.swift, which ensures that it uses the location of the iPhone/iPad you are using. In the WeatherKitManager.swift is the code to fetch the data for the current weather and to fetch the data for the hourly weather for a couple of days.

### Views
In the Views folder there are four views: AlarmClockView, ContentView, MainView and MusicView.
In the AlarmClockView you can add a new alarm with a name and save that alarm.
In the ContentView you can see the current and hourly weatherdata which is fetched from the WeatherManager.
In the MainView is a NavigationView where you can switch between all Views.
In the MusicView you can see the songs based on the weather which are fetched from the fetchmusic() function.
