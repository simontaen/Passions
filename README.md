Passions
========

# App Description

Passions lets you track your favorite Artists and sends you Notifications when one of them releases a new Album. You can browse available Albums of your favorite Artists ordered by release date and tap on "iTunes" to go to the iTunes Store if you want to listen to the Tracks, get more Information or buy the Album. You can add Artists from your Music Library or your Spotify Account.

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



# Code Stuff

* Custom Page View Controller Container with interactive Transitions based on [this](http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions) Blog post.


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



# Artwork Attribution

## App Icon by Nina Meier

App Icon made by Nina Meier from <a href="http://www.ninji.ch" title="Nina Meier">www.ninji.ch</a>

## Album and Artist Placeholder

<div>Icons made by Freepik from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>