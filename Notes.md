# App definition statement

Passions shows you which Albums of your all time favorite Music Artists you are missing and can notify you when a new album gets released. 

# Feature overview

* Show a list of favorite artists stored on Parse
	* Show an initial set on first launch pulled from the iPod library
	* Name of artist and number of albums
	* Remove Artists using a swipe
	* Tapping on the Artist will show the Artists Albums (see below)

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

* Interactively pan between favorite artists and albums collection
	* like on the home screen
	* use a transparent page control


# NewStuff.todo

## Functionality

* First launch experience
* show the album after a push notification arrives
	* send over the parseAlbum objectId


## UI

* A-Z scrubber
	* rethink the A-Z scrubber, should it always show the complete alphabet?
	* the scrubber seems to blocks the pan gesture
* Try a TabBarController with a hidden tabBar replaced by a pageControl
* rework the pageControl look


# 2.0

* Ask User for matching when unclear, but don't code for exceptions
	* "I did my best but I still need your help to identify your favorite Artist"
* Show more infos about the Album when clicking on the Album Art

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
-H "X-Parse-REST-API-Key: gsJjdh7QYmQri2oZMiFJgbFiKYnPJY2kDolqfo3T" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "global" }, "data": { "alert": "Hello World on global!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-REST-API-Key: gsJjdh7QYmQri2oZMiFJgbFiKYnPJY2kDolqfo3T" \
-H "Content-Type: application/json" \
-d '{ "where": { "channels": "allFavArtists" }, "data": { "alert": "Hello for all favorite Artists!" }}' \
https://api.parse.com/1/push

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-Master-Key: gsJjdh7QYmQri2oZMiFJgbFiKYnPJY2kDolqfo3T" \
-H "Content-Type: application/json" \
-d '{"plan":"paid"}' \
https://api.parse.com/1/jobs/findNewAlbums

curl -X POST \
-H "X-Parse-Application-Id: nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ" \
-H "X-Parse-Master-Key: gsJjdh7QYmQri2oZMiFJgbFiKYnPJY2kDolqfo3T" \
-H "Content-Type: application/json" \
-d '{}' \
https://api.parse.com/1/jobs/fetchSimplifiedAlbums


# Regarding UITableViewCell's imageView

https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html
http://stackoverflow.com/questions/3182649/ios-sdk-uiviewcontentmodescaleaspectfit-vs-uiviewcontentmodescaleaspectfill
imageView of UITableViewCell automatically resizes to image, mostly ignoring contentMode, this means
http://nshipster.com/image-resizing/ does not work


# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.