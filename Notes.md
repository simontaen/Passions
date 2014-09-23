# App definition statement

Passions shows you which Albums of your all time favorite Music Artists you are missing and can notify you when a new album gets released. 

# Code.todo

* Draw the UI for the App FIRST!
	* Because you focus on solving the wrong problems if you don't!
* Stop focusing on the current problem of have weird sorting and stuff. What you do might seem simple but is really not. Since this is not what is should look like, more a playground, STOP FOCUSING ON SOLVING IT.
* Why don't you access the Music Library and show what is there in the way you would like it?
	* Need to access Music Library anyway.
	* Interface can be "prototyped" with the existing metadata of the files, just show existing albums.
	* You'll get a feel for what you need (generally and which data needs to persist).
	* The music library is the staring point for defining what you like and showing what you have. You need LFM and other services mainly for upcoming albums, only (very much) later for defining taste (if at all). My point is you'll NOT just persist complete API data. You'll only use SOME of the data from APIs (upcoming albums, more artist infos, buy options), which means you'll very likely have your own data model.


# Implementation detail

* Initial set of favourite artists can be pulled from iPod Libray
* Manually remove/add/edit favourite artists
* You can work in a mode where you JUST work on the favourite artists from your library.
* Background fetch to query albums info sources for new album releases

# CoreData

I'm getting too detail focused again... Performance DOES NOT MATTER in this early stage of development. For my dataset it MAY NEVER MATTER. It's probably the best way to use `UIManagedDocument` the way they teach it in CS193P. It's the fast track to iCloud and requires very little insight.


# Data flow for Parse

## Push Notification for new Albums

* Query for fav. Artists
	* if empty create them
	* before save: call LFM for all Albums and the name correction (http://www.last.fm/api/show/artist.getTopAlbums)
	* Save delivered Albums and save Artist with the corrected name

* Add Users to Artist to remember that the user has favorited the Artist
	* as an array on Artist, maybe you can create an index on this (modifying fav. Artists)



* Background Job on Parse
	* fetch Albums for all Artists
	* compare against saved Albums, save new ones
	* if a new Album is release, send a push notification to all "users" of the artist

* Receive push notification

## Check Discography

* Query for all Albums for parse id for Artist
	* if empty create them
	* before save: call LFM for name correction (http://www.last.fm/api/show/album.getInfo)


## Artist Infos

* Fetch more infos for parse id for Artist


# Helpful parse calls

curl -X POST \
-H "X-Parse-Application-Id: nCQQ7cw92dCJJoH1cwbEv5ZBFmsEyFgSlVfmljp9" \
-H "X-Parse-REST-API-Key: 5iM8ff4mv3rHgq7iXQQEFgVXldqDHZOegM36qcyx" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "global" }, "data": { "alert": "Hello World on global!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nCQQ7cw92dCJJoH1cwbEv5ZBFmsEyFgSlVfmljp9" \
-H "X-Parse-REST-API-Key: 5iM8ff4mv3rHgq7iXQQEFgVXldqDHZOegM36qcyx" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "allFavArtists" }, "data": { "alert": "Hello for all favorite Artists!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nCQQ7cw92dCJJoH1cwbEv5ZBFmsEyFgSlVfmljp9" \
-H "X-Parse-Master-Key: 5iM8ff4mv3rHgq7iXQQEFgVXldqDHZOegM36qcyx" \
-H "Content-Type: application/json" \
-d '{"plan":"paid"}' \
https://api.parse.com/1/jobs/findNewAlbums

curl -X POST \
-H "X-Parse-Application-Id: nCQQ7cw92dCJJoH1cwbEv5ZBFmsEyFgSlVfmljp9" \
-H "X-Parse-Master-Key: 5iM8ff4mv3rHgq7iXQQEFgVXldqDHZOegM36qcyx" \
-H "Content-Type: application/json" \
-d '{}' \
https://api.parse.com/1/jobs/fetchSimplifiedAlbums



# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.