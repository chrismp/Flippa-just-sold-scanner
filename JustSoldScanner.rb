# encoding: UTF-8
[
	'open-uri',
	'mechanize',
	'json',
	'sequel'
].each{|g|
	require g
}

require_relative './models/init.rb'

agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

def trueFalse(string)
	returnVal = string==='true' ? true : false
	return returnVal
end

url = 'https://flippa.com'
def getListingsHash(agent, url, pageNumber)
	publicListings = '/v2/public-listings'

	getURLArray = []
	getParams = {
		'listing_format'=>'auction',
		'page'=>pageNumber,
		'status'=>'won',
		'type'=>'domain',
		'preset'=>'keyword'
	}
	getParams.each_pair{|param,val|
		urlString = [param,val.to_s].join('=')
		getURLArray << urlString
	}
	getURLString = getURLArray.join('&')
	searchURL = url+publicListings+'?'+getURLString

	p "OPENING #{searchURL}"
	responseJSON = agent.get(searchURL).body
	responseHash = JSON.parse(responseJSON)

	return responseHash
end

totalPages = getListingsHash(agent,url,1)['total_pages']

(1..totalPages.to_i).each{|pageNumber|
	recordsArray = getListingsHash(agent,url,pageNumber)['records']
	recordsArray.each{|record|
		id = record['id']
		domain = record['domain_host']
		currentPrice = record['current_price']
		domainTLD = record['domain_tld']
		startAt = Time.parse(record['start_at'])
		endAt = Time.parse(record['end_at'])
		title = record['title']
		bids = record['bid_count']
		bin = record['buy_it_now']
		watchers = record['watchers_count']
		revenueAverage = record['revenue_average']
		featuredAt = record['featured_at']===nil ? nil : Time.parse(record['featured_at'])
		bold = trueFalse(record['bold'])
		thumbnail = trueFalse(record['has_domain_row_thumbnail_url'])
		nda = trueFalse(record['has_nda'])
		highlight = trueFalse(record['highlight'])
		premium = trueFalse(record['premium'])
		privateSale = trueFalse(record['private_sale'])
		reserveMet = trueFalse(record['reserve_met'])
		ultraPremium = trueFalse(record['ultra_premium'])

		flippaURL = record['cannonical_web_url']
		p "OPENING #{flippaURL}"
		listingPage = agent.get(flippaURL)

		snapshotsFlow = listingPage.search('.Snapshots--flow')
		if(snapshotsFlow.length>0)
			snapshotsFlowValue = snapshotsFlow.search('.SnapshotFlow-value')
			domainAgeInfoArray = snapshotsFlowValue[0].text.split(' ')
			domainAgeValue = domainAgeInfoArray[0].to_i
			domainAgeTimeUnit = domainAgeInfoArray[1]
			domainAgeSeconds = domainAgeTimeUnit===nil ? nil :
				domainAgeTimeUnit.include?('year') ? domainAgeValue*365*24*60*60 :  
				domainAgeTimeUnit.include?('month') ? domainAgeValue*30*24*60*60 :  
				domainAgeTimeUnit.include?('week') ? domainAgeValue*7*24*60*60 :
				domainAgeTimeUnit.include?('day') ? domainAgeValue*24*60*60 :
				domainAgeTimeUnit.include?('hour') ? domainAgeValue*60*60 :
				domainAgeTimeUnit.include?('minute') ? domainAgeValue*60 :
				domainAgeValue
			registrar = snapshotsFlowValue[1].text.split(' ')[0]
		end

		sellersNotes = listingPage.search('.Listing-siteDescription').text.strip
		soldBy = listingPage.search('.ListingStatus-status--won')[0].text.gsub('Sold by','').strip
		sellerUsername = listingPage.search('a[context="SellerNameOnListing"]').text.strip
		sellerId = listingPage.search('a[context="SellerNameOnListing"]').attr('href').text.split('/')[-1]
		superSeller = listingPage.search('.Listing-sellerBadge--superSeller').length>0
		positiveFeedback = listingPage.search('.Feedback--listingSidebar').length>0 ? listingPage.search('.Feedback--listingSidebar').text.to_f : nil
		transactionsText = listingPage.search('.UserProfile-transactionsSummary--listingSidebar').length>0 ? listingPage.search('.UserProfile-transactionsSummary--listingSidebar')[0].text.strip : nil
		transactions = transactionsText===nil ? nil : transactionsText.to_i
		transactionSum = transactionsText===nil ? nil : transactionsText.split(/\n/)[-1].gsub(/\D/,'')

		if(Tld[:domainTLD=>domainTLD]===nil)
			newTLD = Tld.new
			newTLD.domainTLD = domainTLD
			newTLD.save
		end

		if(Registrar[:registrar=>registrar]===nil)
			newRegistrar = Registrar.new
			newRegistrar.registrar = registrar
			newRegistrar.save
		end

		if(SoldBy[:SoldBy=>soldBy]===nil)
			newSoldBy = SoldBy.new
			newSoldBy.soldBy = soldBy
			newSoldBy.save
		end

		if(Seller[:id=>sellerId]===nil)
			newSeller = Seller.new
			newSeller.id = sellerId
			newSeller.sellerUsername = sellerUsername
			newSeller.superSeller = superSeller
			newSeller.positiveFeedbackPercent = positiveFeedback
			newSeller.transactions = transactions
			newSeller.transactionSum = transactionSum
			newSeller.save
		end

		if(Domain[:id=>id]===nil)
			newDomain = Domain.new
			newDomain.id = id 
			newDomain.domain = domain
			newDomain.flippaURL = flippaURL.gsub(url+'/','')
			newDomain.currentPrice = currentPrice
			newDomain.startAt = startAt
			newDomain.endAt = endAt
			newDomain.title = title
			newDomain.bids = bids
			newDomain.bin = bin
			newDomain.watchers = watchers
			newDomain.revenueAverage = revenueAverage
			newDomain.featuredAt = featuredAt
			newDomain.bold = bold 
			newDomain.thumbnail = thumbnail
			newDomain.nda = nda
			newDomain.highlight = highlight
			newDomain.premium = premium
			newDomain.privateSale = privateSale
			newDomain.reserveMet = reserveMet
			newDomain.ultraPremium = ultraPremium
			newDomain.domainAgeSeconds = domainAgeSeconds
			newDomain.sellersNotes = sellersNotes
			newDomain.domainTLDId = Tld[:domainTLD=>domainTLD].id
			newDomain.registrarId = Registrar[:registrar=>registrar].id
			newDomain.soldById = SoldBy[:SoldBy=>soldBy].id
			newDomain.sellerId = Seller[:id=>sellerId].id
			newDomain.save
		end
	}
}

