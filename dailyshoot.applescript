to getShortUrl()
	
	set myUrl to "/photos/maradatscha/"
	set shortUrl to "http://flic.kr"
	set mySlug to do shell script "curl http://www.flickr.com/photos/maradatscha/ | grep -m 1 photo_container"
	
	set urlLength to count of characters in myUrl
	set urlOff to offset of myUrl in mySlug
	
	set urlNumb to get ((characters (urlOff + urlLength) through -1 of mySlug) as text)
	
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/"
	set urlNumb to (text item 1 of urlNumb) as text
	set AppleScript's text item delimiters to ASTID
	
	set mySlug to do shell script "curl http://www.flickr.com/photos/maradatscha/" & urlNumb & " | grep -m 1 " & shortUrl
	
	set urlLength to count of characters in shortUrl
	set urlOff to (offset of shortUrl in mySlug)
	
	set urlNumb to get ((characters (urlOff + urlLength) through -1 of mySlug) as text)
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "\""
	set urlNumb to (text item 1 of urlNumb) as text
	set AppleScript's text item delimiters to ASTID
	
	set shortUrl to shortUrl & urlNumb
	
	return shortUrl
end getShortUrl


on open filelist
	set returnVal to display dialog "Please enter your Flickr-email Subject" default answer "todays dailyshoot Tags: dailyshoot"
	set ok to the button returned of returnVal
	if ok is not "OK" then
		return
	end if
	set flickrSubject to the text returned of returnVal
	
	set returnVal to display dialog "Please enter your Tweet" default answer "@dailyshoot "
	set ok to the button returned of returnVal
	
	if ok is not "OK" then
		return
	end if
	set myTweet to the text returned of returnVal
	
	-- get old short url
	set oldUrl to getShortUrl()
	
	repeat with file_ in filelist
		tell application "Finder"
			set theAttachment to POSIX path of file_
		end tell
		tell application "Mail"
			set theMessage to make new outgoing message with properties {visible:true, subject:flickrSubject, content:"This is a small test of my dailyshoot script
			"}
			tell theMessage
				make new to recipient at end of to recipients with properties {name:"Flickr", address:"flickr@maradatscha-ds.posterous.com"}
			end tell
			tell content of theMessage
				make new attachment with properties {file name:theAttachment} at after last paragraph
			end tell
			
			send theMessage
		end tell
	end repeat
	delay 100
	
	set newUrl to getShortUrl()
	
	repeat while oldUrl = newUrl
		delay 10
		set newUrl to getShortUrl()
		
	end repeat
	
	
	set startDate to "15/11/2009"
	set daysSinceStart to ((current date) - (date startDate)) div days as integer
	set hashTag to "#ds" & daysSinceStart
	
	
	
	tell application "Twitterrific"
		post update myTweet & " " & newUrl & " " & hashTag
	end tell
	
	
	
end open
