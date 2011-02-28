Calculating cache hits ratio for SatelliteServer by log analysis

by Dolf Dijkstra,  Posted 24-Oct-08

Recently I needed to analyze the cache hit ratio on Satellite Server.

Without any additional debug log settings it is currently not possible to get some numbers.

If you accept the (temporary) overhead of the additional logging you can get some rough numbers.

You need to enable
com.fatwire.logging.cs.satellite.cache=DEBUG
com.fatwire.logging.cs.satellite.host=DEBUG
com.fatwire.logging.cs.satellite.request=DEBUG
com.fatwire.logging.cs.satellite=DEBUG

If you look at the log you will see for instance this sequence:

1. [2008-10-22 21:20:56.723][CS.SATELLITE.REQUEST][DEBUG] New request for blob: ?blobcol=urldata&blobheader=text/css&blobkey=filevalue&blobtable=MungoBlobs&blobwhere=autosuggest.css&ssbinary=true
2. [2008-10-22 21:20:56.723][CS.SATELLITE][DEBUG] Attempting to return bytes for: blob: ?blobcol=urldata&blobheader=text/css&blobkey=filevalue&blobtable=MungoBlobs&blobwhere=autosuggest.css&ssbinary=true
3. [2008-10-22 21:20:56.723][CS.SATELLITE.CACHE][DEBUG] Fetched from cache 'blobtable=MungoBlobs&blobcol=urldata&blobwhere=autosuggest.css&blobkey=filevalue'

Line 1 is the http request for a blob
Line 2 is to get the content, either from cache or from ContentServer
Line 3 indicates that the content was retrieved from cache

Now a sequence for when a pagelet was not cached:

1. [2008-10-22 21:21:05.021][CS.SATELLITE.REQUEST][DEBUG] New request for page: ?<url removed>

<some lines removed for clarity>

2. [2008-10-22 21:20:56.720][CS.SATELLITE][DEBUG] Attempting to return bytes for: page: ?<url removed>

3. [2008-10-22 21:20:56.720][CS.SATELLITE.HOST][DEBUG] Requesting from Content Server (via HttpAccess): page: ?<url removed>

4. [2008-10-22 21:20:56.728][CS.SATELLITE.CACHE][DEBUG] Caching 'pagename=<removed>' with key 'pagename=<removed>' and expiry 'Sat Oct 20 21:20:56 CEST 2018'

5. [2008-10-22 21:20:56.746][CS.SATELLITE.CACHE][DEBUG] Released from cache 'pagename=<removed>', use count: 0

Line 1 is the http request for a blob
Line 2 is to get the content, either from cache or from ContentServer
Line 3 indicates that the content was retrieved from ContentServer
Line 4 tells us that the content is added to the cache
Line 5 tells us that another object was release from cache. In this case (after more analysis) it showed that their cache size was set to low and objects were added and removed from cache all the time.

To get to some usefull statistics we could use grep and wc to get some numbers.

As you can see from the previous sequences there are some strings that we can grep on that mark different events.

These are the lines to grep on. grep 'New request for page' futuretense.txt | wc -l
grep 'New request for blob' futuretense.txt | wc -l
grep 'Attempting to return bytes for: page:' futuretense.txt | wc -l
grep 'Attempting to return bytes for: blob:' futuretense.txt | wc -l
grep 'Fetched from cache' futuretense.txt | wc -l
grep 'Requesting from Content Server' futuretense.txt | wc -l
grep 'Caching ' futuretense.txt | wc -l
grep 'Released from cache' futuretense.txt | wc -l

This was the output from the sample futuretense.txt that I analyzed.

A: The http requests
'New request for page' 20,166
'New request for blob' 238,799

These two numbers added are the total number of http requests served by this SatelliteServer servlet.

238,799/20,166 = 11.8 is the blob to page ratio. That is the number of images etc that are loaded on a page.

B: Getting content from cache or CS
'Attempting to return bytes for: page:' 721,207
'Attempting to return bytes for: blob:' 238,799
The numbers for the blobs match, but for pages it is much higher. Why? Because a page is composed of multiple pagelets. This means that for page mulitple pagelets need to be retrieved from either cache or ContentServer.

C: Either fetched from cache or from ContentServer
'Fetched from cache' 601,903
This means that 358,103 (712k+238k-601k) objects are not fetched from cache.
'Requesting from Content Server' 379,950
This means that 580,056 (712k+238k-379k) objects were not requested from contentserver.

D: Cache management
'Caching ' 294,615
This means that of the 379k requests to ContentServer only 294k objects were added to the cache. All other objects were not meant to be cached, the uncached pagelets (assuming all blobs should be cached). If we now compare that number with the 20166 requests for full pages, we can see that there are more then 1 uncached pagelet per page. Even if they would be using an uncached wrapper for all pages then there are still other pagelets that are not cached. This needs to be a well understood situation from a cache and site design perspective.

'Released from cache' 217,879
This is another interesting marker. These are the objects purged from cache. While this test was running there were no publishes done and all expiration times were long so no objects were removed from cache either based on their time expiration or because new content was published. For this customer it meant clearly that their cache_max number was too low.

I wrote a small script that gets the relevant parameters from the log file

Invoke it with the log file as argument.

for instance cache-hit.sh futuretense.txt 