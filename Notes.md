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
	* Allow settings to change ordering (Alphabetical, Playcount)

* Show a collection view of your favorite artists albums, ordered by release date
	* overlay a color coded release date bubble
	* Tapping on the Album will show more infos about the album

* Interactively pan between favorite artists and albums collection
	* like on the home screen
	* use a transparent page control

* Get a push Notification when a new Album gets released
	* tapping the notification will show Album infos

# App Description

Passions lets you track your favorite Aritsts and sends you Notifications when one of them releases a new Album. You can browse available Albums of your favorite Artists ordered by release date and tap on "iTunes" to get redirected to the iTunes Store if you want to listen to the Album, get more Information or buy the Album. You can add Artists from your Music Library or your Spotify Account.


# NewStuff.todo

## Parse
* Artist fetch could fail and the iTunes Id would be empty then.
* The store is always US (leads to iTunes link to items unavailable to the current User)

## General Functionality
* add properly sized images

### Spotify Integration

## PageViewController Container

## Cells

## Adding
* review displaying the alert controller

## Fav Artists

## Timeline

## Artist and Album Info

## App Icon
* Maybe only one color, like omnifocus, but keep the spotlight

# 1.1 (?)
* Dynamic Row height for bigger devices (5 and up, 6 and up)
* search for not in library artists to add (but consider all resources!) - **number one feature request**!

# 2.0

* Try a TabBarController with a hidden tabBar replaced by a pageControl
* Ask User for matching when unclear, but don't code for exceptions
	* "I did my best but I still need your help to identify your favorite Artist"
* Animate the cell when an Artist has been favorited.
* segmented control on Timeline, in NavBar which hides on swipe (this would also solve the status bar problem)
	* to filter results based on release date? Where do I get info on pre-releases?
	* to filter results and show all or only missing albums (this is the most interesting!)
	* change ordering: by release date, by artist.
* Background fetch for a new Album
* You might run into performance problems with _triggerAlbumFetching and fetchFullAlbums. If too many requests come in at the same time, I'll run out of background jobs. The job won't run, the user won't get a push when loading is done, and more importantly it could take until the next scheduled album fetch until the artist get its albums. We'll have to see how it turns out.
	* Faving Artists fast leads to "processing" for ever (no Jobs available), how to resolve?
* A guy rocking out when refreshing on pull-to-refresh
* Some Artist might not have Albums, like Jennifer Rostock (store region) or Garth Brooks (won't sell them on iTunes). Fall back to Spotify in that case.
* Albums "duplicate" check, more like "find different editions", when adding on Parse. This might work with a Stemmer (fix at the root problem) or hashing the image (fix the symptom).
	* Also this requires a data model change since you need to make a relation between Albums
* Get Concerts and Events from your Fav. Artists
* Add LastFm as a Source
* Get Suggestions based on my Favorite Artists (Maybe LastFm or even iTunes). But the app is NOT a discovery Service.
* Local Notification on release day of an album?
* Use https://github.com/CanvasPod/Canvas
* Try to highlight Deluxe/Special Editions (as the usually have the same Album Art)
* flickering when the transition gets aborted (this is in the Container)

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
-d '{"i":"T1y1GybQNl"}' \
https://api.parse.com/1/jobs/fetchFullAlbums

// http://bendodson.com/code/itunes-artwork-finder/index.html
curl -X GET \
-H "Accept: application/json" \
"http://playground.bendodson.com/itunes-artwork-finder/?query=Back+In+Black&entity=album&country=us"

# Regarding UITableViewCell's imageView

https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html
http://stackoverflow.com/questions/3182649/ios-sdk-uiviewcontentmodescaleaspectfit-vs-uiviewcontentmodescaleaspectfill
imageView of UITableViewCell automatically resizes to image, mostly ignoring contentMode, this means
http://nshipster.com/image-resizing/ does not work
