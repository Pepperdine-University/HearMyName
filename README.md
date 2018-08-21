# HearMyName
This application was created in an attempt to capture the proper pronunciation of people’s names. The goal was to make the recording process very easy on the user. In order to accomplish this we attempted to use HTML5’s new Audio features that allow you to record sound directly through the web browser. 

# Peculiarities
Unfortunately as the project evolved it became apparent that the new Audio features are still being implemented by the browser producers. As such, the app works best in Google Chrome and Firefox. The only mobile browser that it works with is Firefox for Android. As time goes on, more browsers should implement these features, making HearMyName more flexible. 

The second unfortunate discovery was that even through a standard was defined for how to handle Audio in a browser, different browsers choose to interpret that standard in their own way. For example: Firefox saves WAV files, however Chrome uses the OGG format. As such, I had to create different ways of handling the files based on the browser. Once the files are saved a server-side process ([FFMPEG](https://www.ffmpeg.org/)) converts them to MP3 format that can be played by any browser/device. 

The files are stored in the project directory called Userfiles and then converted into a child folder under the same directory called Converted. The Converted files are what is used by the app for playback. This was done in order to make file-access-server-permissions issues simpler. 

In order to make it easy for the listeners to pick out only the recordings relevant to them (for example a class for a professor, or a graduating class for a graduation prep) we introduced a Bulk Search on the Hear Names screen. Here you can paste a list of student IDs (Called CWID for Pepperdine) and the recording list will get instantly filtered to only include the people in your list. We are using the query string in order to implement the bulk search. This has two advantages over a method utilizing a database: 
1. You can save the list by bookmarking the link that is created below it. 
2. You can share the link with other people in order and they will be able to see the same exact search that you just ran!

If you include isNSO=true in the url when accessing the Profile page (where you record names), after clicking Save the user will be automatically logged out. This is useful during New Student Orientation when a lot of people need to record their names on the same computer. 

# Tech Details: 
The application used [Entity Framework](https://msdn.microsoft.com/en-us/library/aa937723(v=vs.113).aspx) to access the database. It hooks into a Microsoft SQL database named HearMyName. The CREATE script will be provided with this code, please create the DB before attempting to run the code. You can also probably recreate the db using the Entity Code-first approach (as you’re given a model with the code).
[NLog](http://nlog-project.org/) is used for nice, easy logging. Take a look at nlog.config for the setup. There is a wrapper for it with a static method that allows you to call it from anywhere in Helpers/logHelper.cs
The security is handled by [CAS](https://www.apereo.org/projects/cas) sso. Within the application this is used to get the current user’s info. This information is used for naming the recording files. 
You can define user roles and assign them to users in the UserRoles and AppUsers tables respectively. Right now the only special role is Admin (everyone else is just a user). Admins get to review recordings and mark them as reviewed.
