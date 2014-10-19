# App definition statement

Passions shows you which Albums of your all time favorite Music Artists you are missing and can notify you when a new album gets released. 

# Feature overview

* Show a list of favorite artists stored on Parse
	* Show an initial set on first launch pulled from the iPod library
	* Name of artist and number of albums
	* Remove Artists using a swipe
	* Tapping on the Artist will show more infos about the artist

* Add artists from various sources
	* iPod Library (must be working only with that)
	* Last.fm
	* Spotify

* Add Artists using a modal view
	* Show name and plays (if available)
	* Tap to (un-)favorite
	* Mark already favorited Artists consistently between different sources
	* Search for an Artist
	* Allow settings to change ordering

* Show a collection view of your favorite artists albums, ordered by release date
	* overlay a color coded release date bubble
	* Tapping on the Album will show more infos about the album

* Interactively pan between favorite artists and albums collection
	* like on the home screen
	* use a transparent page control

* Get a push Notification when a new Album gets released
	* tapping the notification will show Album infos


# NewStuff.todo

## Functionality

* First launch experience
	* favorite 3 most played
		* this could get tricky with the artistNameCorrections
	* setup User/Installation

* show the album after a push notification arrives
	* send over the parseAlbum objectId
* Silent push after fav'ing an Artist (Status Processing) to update UI automatically

* Parse seems to just take a default date of today for the Albums sometimes (check Bruce and Beatles)
	* actually Spotify delivers shit data! (Track of my Years from Bryan Adams for example!)

* Switch Release Date to a real Date on Parse: https://www.parse.com/docs/js_guide#objects-types
	* https://www.parse.com/questions/javascript-query-using-greaterthan-createdat

## UI

* Try a TabBarController with a hidden tabBar replaced by a pageControl
* redesign FavArtist cell, maybe add Playcount?
* add a fancy control to (un-)fav the artist
* A guy rocking out when refreshing on pull-to-refresh
* Faster transition (see homescreen)
* segmented control and navbar hiding, as on AppStore Top Charts, hide when slide
* hairlines below extended nav bars and table view headers
* flickering when the transition gets aborted
* extended nav bar color when transitioning
* ReleaseDateView on Timeline (see examples)
* Either Transculency OR NavBar hiding. Both doesn't make sense. Hiding seems to be the better solution.
* Use Apple Example to hide Hairline
* Another point on the PageController to show that there is something more
* Hide status bar on timeline, it scrolls under it.
* tapping on a fav artists, the user might think it goes to the timeline (but it could just be b/c it did NOT go to ArtistInfo at that point)

# 2.0

* Ask User for matching when unclear, but don't code for exceptions
	* "I did my best but I still need your help to identify your favorite Artist"
* Animate the cell when an Artist has been favorited.
* Already favorited Artists passing in PASFavArtistsTVC (artistNames)
	* It could be improved by checking if self.objects actually did change
	* only then create a new artistNames array
* segmented control on Timeline, in NavBar which hides on swipe (this would also solve the status bar problem)
	* to filter results based on release date? Where do I get info on pre-releases?
	* to filter results and show all or only missing albums (this is the most interesting!)
	* change ordering: by release date, by artist.
* search for not in library artists to add (but consider all resources!) - number one feature request!

# Data communication with Parse

## Fav an Artist

* use a corrected name to query parse
	* if no correction exits, call LFM
* if empty create the artist using the corrected name
* add the artist to the users favArtists array
* before save on Parse
	* call spotify for the Artist
		* try to find an exact match by comparing the name
	* call background job "fetchFullAlbums"

# Background Jobs on Parse

## findNewAlbums

* Query for all Artists where totalAlbums DOES exist
* find new albums for the queried artists
	* fetch total albums of artist
	* if changed fetch all albums for artist (complete info), if no change return
		* see below...
		* return the artist and albums
	* find the newest album
		* use a default UTC for date 1000.1.1
		* for each album, normalize date to UTC and compare against the currently newest
		* return newest album
	* query all users where "favArtists" contains the current user
	* send a push to all installations of these users "installation"
	* save the artist and return
* set the status and return

## fetchFullAlbums

* Query for all Artists where totalAlbums DOES NOT exist
* call spotify to fetch all albums for artist (complete info)
	* fetch artists (simplified) albums, all
	* update totalAlbums if changed
	* process the simplified albums
		* fetch complete album info
		* create or update the album
			* query for the album using the spotify id
			* if empty create it
			* update and save the album
		* return the artist and albums
* save the artist
* set the status and return


# Helpful parse calls

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-REST-API-Key: Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "global" }, "data": { "alert": "Hello World on global!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-REST-API-Key: Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "allFavArtists" }, "data": { "alert": "Hello for all favorite Artists!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-Master-Key: Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7" \
-H "Content-Type: application/json" \
-d '{"plan":"paid"}' \
https://api.parse.com/1/jobs/findNewAlbums

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-Master-Key: Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7" \
-H "Content-Type: application/json" \
-d '{"i":"myTestInstallationId"}' \
https://api.parse.com/1/jobs/fetchFullAlbums

int middle = (int)(self.images.count / 2 - ((self.images.count % 2) / 2));


# Regarding UITableViewCell's imageView

https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html
http://stackoverflow.com/questions/3182649/ios-sdk-uiviewcontentmodescaleaspectfit-vs-uiviewcontentmodescaleaspectfill
imageView of UITableViewCell automatically resizes to image, mostly ignoring contentMode, this means
http://nshipster.com/image-resizing/ does not work


# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.