# Code.todo

* Draw the UI for the App FIRST!
	* Because you focus on solving the wrong problems if you don't!
* Stop focusing on the current problem of have weird sorting and stuff. What you do might seem simple but is really not. Since this is not what is should look like, more a playground, STOP FOCUSING ON SOLVING IT.
* Why don't you access the Music Library and show what is there in the way you would like it?
	* Need to access Music Library anyway.
	* Interface can be "prototyped" with the existing metadata of the files, just show existing albums.
	* You'll get a feel for what you need (generally and which data needs to persist).
	* The music library is the staring point for defining what you like and showing what you have. You need LFM and other services mainly for upcoming albums, only (very much) later for defining taste (if at all). My point is you'll NOT just persist complete API data. You'll only use SOME of the data from APIs (upcoming albums, more artist infos, buy options), which means you'll very likely have your own data model.


# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.