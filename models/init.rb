## LOCAL DB
DB = Sequel.connect(
	:adapter => 'mysql',
	:user => ARGV[0],
	:password => ARGV[1],
	:host => ARGV[2]
	:database => ARGV[3]
)

DB.create_table? :DomainTLDs do 
	primary_key :id
	varchar :domainTLD, :unique=>true
end

DB.create_table? :Registrars do 
	primary_key :id
	varchar :registrar, :unique=>true
end

DB.create_table? :SoldByTypes do 
	primary_key :id
	varchar :soldBy, :unique=>true
end

DB.create_table? :Sellers do 
	primary_key :RowId
	Integer :id, :unique=>true, :index=>true
	varchar :sellerUsername, :unique=>true
	Boolean :superSeller
	Float :positiveFeedbackPercent
	Integer :transactions
	Float :transactionSum
end

DB.create_table? :Domains do 
	primary_key :RowId
	Integer :id, :unique=>true
	varchar :domain
	varchar :flippaURL
	Float :currentPrice
	Datetime :startAt, :index=>true
	Datetime :endAt, :index=>true
	varchar :title
	Integer :bids, :index=>true
	Integer :bin, :index=>true
	Integer :watchers, :index=>true
	Integer :revenueAverage, :index=>true
	Datetime :featuredAt
	Boolean :bold
	Boolean :thumbnail
	Boolean :nda
	Boolean :highlight
	Boolean :premium
	Boolean :privateSale
	Boolean :reserveMet
	Boolean :ultraPremium
	Integer :domainAgeSeconds, :index=>true
	Text :sellersNotes, :full_text_index=>true
	foreign_key :domainTLDId, :DomainTLDs, :index=>true
	foreign_key :registrarId, :Registrars, :index=>true
	foreign_key :soldById, :SoldByTypes, :index=>true
	foreign_key :sellerId, :Sellers, :key=>:id, :index=>true
end

require_relative 'classes.rb'