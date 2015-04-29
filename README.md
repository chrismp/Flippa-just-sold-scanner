# Flippa.com "Just Sold" scanner
This Ruby script gets info from [Flippa.com](http://Flippa.com)'s completed auctions and puts it in a MySQL database. Just fill in the relevant MySQL info in `launcher.cmd` and run that file to launch the script. 

The script uses Flippa's '[public-listings](https://flippa.com/v2/public-listings)' API, which returns a JSON string of domain auction datapoints like domain name, bids, highest bid, etc.