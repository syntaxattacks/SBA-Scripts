# test comment
#test 2
get-aduser -Filter * -properties samaccountname, displayname, company, mail, department | select samaccountname, displayname, company, mail, department | export-csv "\\8hTQR12\c$\Software\adusers.csv"