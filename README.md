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

# Lessons learned
This is my first App and the development of it served as a learing experience. In that spirit here are a few things I learnt:

* Storing and managing user data on a Server, here [Parse.com](https://www.parse.com).
* Crash Reporting with [Crashlytics](https://fabric.io/), initially manual Symbolication.
* Integrating and using data from 3rd Party Services
	* [Spotify](https://developer.spotify.com/technologies/spotify-ios-sdk/)
	* [Last.fm](http://www.last.fm/api/intro)
	* [iTunes Search API](https://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html) (sometimes undocumented)
* Customizing and using UICollectionView and UITableView, and its Cells
* Concurrency is hard
* Building a custom View Controller container with interactive transitions
* Simple UI things sometimes mean hours of coding
* Storyboards only serve the simplest Applications
* Caching images using [FastImageCache](https://github.com/path/FastImageCache)
* Managing dependencies using [Cocoapods](http://cocoapods.org)
* Using Apples integrated [TestFlight](https://developer.apple.com/testflight/)
* Talking to the iPod Library using the Media Player Framework
* Using Push Notifications (after the Certificate-Hell)
* Smart Caching makes your App appear a lot faster
* Reading Blog posts doesn't write your App
* You'll write Bugs only your Testers will find
* Extending the NavBar is surprisingly hard
* Gesture recognizers require patience
* [Heroku is great!](https://github.com/simontaen/SpotifyTokenSwap)
* Don't rely on assumption, go and dig deeper ([LEColorPicker](https://github.com/luisespinoza/LEColorPicker) vs. [UIVisualEffectView](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIVisualEffectView/index.html))
* Focus on what matters
* Never assume your code is correct (even if its a [library you wrote](https://github.com/simontaen/LastFmFetchr) :))


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

## Star Icon

[Star Icon](http://iconfindr.com/1AwNDKX) by [Visual Pharm](http://icons8.com/).

## Swipe Left Hand Icon

[Swipe Left Hand Icon](http://iconfindr.com/17Xv0sI) by [Yannick Lung](http://www.yanlu.de).
