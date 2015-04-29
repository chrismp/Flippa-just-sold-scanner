-- JOIN ALL TABLES
SELECT *
FROM domains a 
INNER JOIN domaintlds b ON a.domainTLDId=b.id
INNER JOIN registrars c ON a.registrarId=c.id
INNER JOIN soldbytypes d ON a.soldById=d.id
INNER JOIN sellers e ON a.sellerId=e.id