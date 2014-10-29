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


# NewStuff.todo

## Parse
* Artist fetch could fail and the iTunes Id would be empty then.

## General Functionality
* Create Production Certificates for Push
* Simulate new album notification (for testing)

### Spotify Integration
* Fall back to Spotify if Music App does not seem to be used.
* Add Spotify as a Source (lot's of people don't use Music anymore)

### Suggestions
* Get Suggestions based on my Favorite Artists
* Maybe LastFm or even iTunes

## PageViewController Container
* flickering when the transition gets aborted

## Cells

## Adding
* Either Transculency OR NavBar hiding. Both doesn't make sense. Hiding seems to be the better solution, as on AppStore Top Charts, hide when slide.
* Timeout when faving - app stays in processing but then works again after quitting but does not update the ui correctly.
* Faving takes very long on the Device

## Fav Artists

## Timeline
* Try to highlight Deluxe/Special Editions (as the usually have the same Album Art)

## Artist and Album Info
* Design the Screens
	* iTunes Buy link
	* Couple of infos
	* Show Album Art in Big
	* "Show All Albums" Button from Artist Info show this Artists Albums in a Timeline
* Use a modal view, there is too much left-right if you use a NavController
* Opening App several times from a Push stacks the new Album Info views on top of each other.
* Use UIVisualEffectView for Album and Artist Info


# 2.0

* Try a TabBarController with a hidden tabBar replaced by a pageControl
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
* Background fetch for a new Album
* You might run into performance problems with _triggerAlbumFetching and fetchFullAlbums. If too many requests come in at the same time, I'll run out of background jobs. The job won't run, the user won't get a push when loading is done, and more importantly it could take until the next scheduled album fetch until the artist get its albums. We'll have to see how it turns out.
	* Faving Artists fast leads to "processing" for ever (no Jobs available), how to resolve?
* A guy rocking out when refreshing on pull-to-refresh
* Some Artist might not have Albums, like Jennifer Rostock (store region) or Garth Brooks (won't sell them on iTunes). Fall back to Spotify in that case.
* Albums "duplicate" check, more like "find different editions", when adding on Parse. This might work with a Stemmer (fix at the root problem) or hashing the image (fix the symptom).
	* Also this requires a data model change since you need to make a relation between Albums
* The ReleaseDate View flickers when scrolling. This must be an Apple Bug. You could try to capture an image or replicate it using "Album Colors" and a 60% opaque background
* Get Concerts and Events from your Fav. Artists
* How to I get logs from Test Devices (aka Remote Logging), PFAnalytics?
* Add LastFm as a Source

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

int middle = (int)(self.images.count / 2 - ((self.images.count % 2) / 2));

// http://bendodson.com/code/itunes-artwork-finder/index.html
curl -X GET \
-H "Accept: application/json" \
"http://playground.bendodson.com/itunes-artwork-finder/?query=Back+In+Black&entity=album&country=us"

# Regarding UITableViewCell's imageView

https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html
http://stackoverflow.com/questions/3182649/ios-sdk-uiviewcontentmodescaleaspectfit-vs-uiviewcontentmodescaleaspectfill
imageView of UITableViewCell automatically resizes to image, mostly ignoring contentMode, this means
http://nshipster.com/image-resizing/ does not work


# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.