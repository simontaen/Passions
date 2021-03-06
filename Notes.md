# NewStuff.todo

## Parse
* Artist fetch could fail and the iTunes Id would be empty then (maybe a cleanup job?)
* The store is always US (leads to iTunes link to items unavailable to the current User)
	* Setup an artist and album (must run on all...) refresh job
* Implement a mechanism to delete old and unused accounts
* Duplicate Artists on Parse: How to clean up?
* A Job that cleans up Artists with missing iTunesId (Problems with escaping Names?)
* Jet and Joss Stone: Why do they have the same Artist Artwork
* Encoding Issues with Artist Name: Beyoncé was Beyonc
* How do you recover from artists that stay in processing? (like Die Toten Hosen)

## General Functionality
* Colors are not properly used when album infos are shown after a push

## Spotify Integration

## PageViewController Container

## Cells

## Adding
* Why does the nav bar switch so late on adding screens

## Fav Artists
* Color matching row for each artist

## Timeline

## Artist and Album Info

## App Icon


# Marketing and Promotion

* Social Network announcements
* Friends announcements
* update Lastfm and Spotify profile
* create promotional website
* Enable Git-Flow
	* http://yakiloo.com/getting-started-git-flow/
* Migrate iTunes Connect Test Users
* setup a redirect link like: http://zonesapp.net/download


# 1.1 (?)

* Link to iTunes like Overcast with an inapp modal (web?-)view
* Dynamic Row height for bigger devices (5 and up, 6 and up)
* Custom font?
* search for not in library artists to add (but consider all resources!) - **number one feature request**!
* alert when trying to logout on spotify (accidentally triggering sucks)
* Maybe hide the control after a few moments (it's in the way always)
* sometimes the pageControl indicator seems not to update properly
* PASArtistTvCell must extend to end of cell when no star is available
* For albums bought, go to music app instead of store
	* This seems to be technically hard to do
* Turn album cover for tracklist
* Play Track preview
* Maybe another Source: http://www.musik-sammler.de/


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
	* http://www.songkick.com/developer/
	* http://www.bandsintown.com/api/overview
	* http://api.setlist.fm/docs/index.html
	* http://developer.rdio.com
* Add LastFm as a Source
* Get Suggestions based on my Favorite Artists (Maybe LastFm or even iTunes). But the app is NOT a discovery Service.
* Local Notification on release day of an album?
* Use https://github.com/CanvasPod/Canvas
* Try to highlight Deluxe/Special Editions (as the usually have the same Album Art)
* flickering when the transition gets aborted (this is in the Container)
* Whishlist and/or don't forget (remember me) list
* Remove stuff you don't want to see


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


# Albums feed (Passions) - Initial thoughts and notes

"Passions keeps tells you about Albums and Events of your favorite bands."

Remember the time when you were you and always exactly knew when your favorite Bands next Album will be release? And remember how life happened and your favorite Band doesn't get the same attention as before? Ever find yourself asked the question "Have you heard the new Song from that Band you like?" and you go "They have a new Album???"

This Service has one purpose: tell you when new albums will be released. You enter your artists and the Service will reach out to you (Twitter, Facebook, Email, RSS) when a new Album will be released (once before release and once one the release date -> with option to pre-order/buy). You can import your Artists from iTunes or connect your Account to Last-FM, maybe a plaintext file too (this will show the user a list, where he can select Artists from).

* Amazon wish list integration
* Passbook integration (for tickets?)
* Buying stuff (iTunes, ...)
