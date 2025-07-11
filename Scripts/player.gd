extends Node
class_name Player

var cryptoBalance: float = 0
var cashBalance: float = 0
#Amount of cash in one crypto
var cryptoConversion: float = 100


func get_cash_balance() -> float:
	return cashBalance


func get_crypto_balance() -> float:
	return cryptoBalance


func set_cash_balance(newCashBalance: float):
	cashBalance = newCashBalance


func set_crypto_balance(newCryptoBalance: float):
	cryptoBalance = newCryptoBalance


#Used for charging or adding cash to balance
func cash_transaction(amount: float):
	cashBalance += amount


#Used for charging or adding crypto to balance
func crypto_transaction(amount: float):
	cryptoBalance += amount

#Convert crypto to cash
func crypto_to_cash(cryptoToConvert: float):
	cashBalance += cryptoToConvert * cryptoConversion


#Conver cash to crypto
func cash_to_crypto(cashToConvert: float):
	cryptoBalance += cashToConvert / cryptoConversion
