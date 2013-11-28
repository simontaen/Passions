# Code.todo

* Draw the UI for the App FIRST!
	* Because you focus on solving the wrong problems if you don't!
* Stop focusing on the current problem of have weird sorting and stuff. What you do might seem simple but is really not. Since this is not what is should look like, more a playground, STOP FOCUSING ON SOLVING IT.
* add the change to AFNetworking


# This is far off

Peter Steinberger recommends using `objc_msgSend` instead of performSelector in his [UIKonf 2013 talk](https://www.youtube.com/watch?v=psPNxC3G_hc) (last minute) after a call to `respondsToSelector`. It's faster and you don't get the nasty ARC warnings. This means I could do a ViewController generalization like I tried in the Stanford "6 - CoreDataSPot" project without `#pragma clang diagnostic push` in `prepareForSegue`.