class Tld < Sequel::Model
	set_dataset :DomainTLDs
end

class Registrar < Sequel::Model
	set_dataset :Registrars
end

class SoldBy < Sequel::Model
	set_dataset :SoldByTypes
end

class Seller < Sequel::Model
	set_dataset :Sellers
end

class Domain < Sequel::Model
	set_dataset :Domains 
end