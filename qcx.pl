#!/usr/bin/perl

# QuadrigaCX Perl Wrapper
#   This script is meant to be a collection of functions For the
#   bitcoin exchange QuadrigaCX, https://www.quadrigacx.com to
#   ease the writing of bots in Perl. In the current state,
#   version 1.0 not everything is deserialized yet. Version 1.1
#   will deserialize everything into cleaned variables for
#   proper use in scripts. If this script helps you in writing
#   a bot for QuadrigaCX, please donate to help me eat and code.
# Alice Miyako - http://www.miyako.pro
# Donate: 1foxypuyuoNp5n1LNCCCCmjZ4RAXntQ8X

use WWW::Mechanize; # Generic HTTP(S)
use Digest::SHA qw(hmac_sha512_hex); # HMAC Sha256 Hex Encryption
use Digest::SHA qw(hmac_sha256_hex); # HMAC Sha512 Hex Encryption
use JSON;
use Data::Dumper;
use strict;
use Term::ANSIColor;
use POSIX qw(strftime);

# Init quadrigacx API
our $qcx_apikey		= "";
our $qcx_clientid	= "";
our $qcx_secret		= "";
our $qcx_signature	= "";

# Balance Prototypes
our ($qcx_bal_cad_res,
$qcx_bal_xau,
$qcx_bal_eth_av,
$qcx_bal_usd,
$qcx_bal_btc_res,
$qcx_bal_btc_av,
$qcx_bal_eth,
$qcx_bal_cad,
$qcx_bal_usd_av,
$qcx_bal_cad_av,
$qcx_bal_eth_res,
$qcx_bal_fee,
$qcx_bal_xau_res,
$qcx_bal_btc,
$qcx_bal_usd_res,
$qcx_bal_fee_eth,
$qcx_bal_fee_usd,
$qcx_bal_fee_cad,
$qcx_bal_fee_etc,
$qcx_bal_xau_av)	= qcxBalance();

# Get user balances
sub qcxBalance() {
	our ($qcx_bal_cad_res,
	$qcx_bal_xau,
	$qcx_bal_eth_av,
	$qcx_bal_usd,
	$qcx_bal_btc_res,
	$qcx_bal_btc_av,
	$qcx_bal_eth,
	$qcx_bal_cad,
	$qcx_bal_usd_av,
	$qcx_bal_cad_av,
	$qcx_bal_eth_res,
	$qcx_bal_fee,
	$qcx_bal_xau_res,
	$qcx_bal_btc,
	$qcx_bal_usd_res,
	$qcx_bal_fee_eth,
	$qcx_bal_fee_usd,
	$qcx_bal_fee_cad,
	$qcx_bal_fee_etc,
	$qcx_bal_xau_av)	= qcxBalance_think();
}

# ticker prototypes
our ($qcx_tick_ask, $qcx_tick_bid, $qcx_tick_last) = "";

# Get the current prices
# qcxTicker(string book);
# qcxTicker("btc_usd"); get the ask, bid and last of btc/usd
# qcxTicker("eth_btc"); get the ask, bid and last of eth/btc
sub qcxTicker($) {
	our ($qcx_tick_bid, $qcx_tick_ask, $qcx_tick_last) = qcxTicker_think("$_[0]");
}

# balance think function, returns balances
sub qcxBalance_think() {
	sleep 1;
	print "Getting Balance...\n";
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/balance";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		# print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
		return ($qcx_json->{'cad_reserved'},
		$qcx_json->{'xau_balance'},
		$qcx_json->{'eth_available'},
		$qcx_json->{'usd_balance'},
		$qcx_json->{'btc_reserved'},
		$qcx_json->{'btc_available'},
		$qcx_json->{'eth_balance'},
		$qcx_json->{'cad_balance'},
		$qcx_json->{'usd_available'},
		$qcx_json->{'cad_available'},
		$qcx_json->{'eth_reserved'},
		$qcx_json->{'fee'},
		$qcx_json->{'xau_reserved'},
		$qcx_json->{'btc_balance'},
		$qcx_json->{'usd_reserved'},
		$qcx_json->{'fees'}->{'eth_btc'},
		$qcx_json->{'fees'}->{'btc_usd'},
		$qcx_json->{'fees'}->{'btc_cad'},
		$qcx_json->{'fees'}->{'eth_cad'},
		$qcx_json->{'xau_available'});
	}
}

# Get the list of user transactions
# qcxUTransactions(int offset, int limit, string sort, string book);
# qcxUTransactions(0, 0, asc, btc_usd); no offset or limit, ascending order, btc/usd
# qcxUTransactions(1, 3, desc, btc_cad); offset by 1, limit 3, descending order, btc/cad
sub qcxUTransactions($$$$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/user_transactions";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'offset' => "$_[0]", 'limit' => "$_[1]", 'sort' => "$_[2]", 'book' => "$_[3]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Get user deposit address
# currently broken! -> JSON allow_nonref
sub qcxDeposit() {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/bitcoin_deposit_address";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'offset' => "$_[0]", 'limit' => "$_[1]", 'sort' => "$_[2]", 'book' => "$_[3]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Withdraw user currency
# currently broken! -> JSON allow_nonref
# qcxWithdraw(string currency, float amount, string address);
# qcxWithdraw("BTC", 0.5, "1foxypuyuoNp5n1LNCCCCmjZ4RAXntQ8X"); withdraw 0.5 bitcoin to  1foxypuyuoNp5n1LNCCCCmjZ4RAXntQ8X, please donate so I can eat.
sub qcxWithdraw($$$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/bitcoin_deposit_address";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'offset' => "$_[0]", 'limit' => "$_[1]", 'sort' => "$_[2]", 'book' => "$_[3]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Buy Limit Order
# qcxBuyLimit(float amount, float price, string book);
# qcxBuyLimit(1.5, 450.55, btc_usd); buy 1.5 bitcoin at 450.55$ on pair BTC/USD
sub qcxBuyLimit($$$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/buy";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'amount' => "$_[0]", 'price' => "$_[1]", 'book' => "$_[2]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Sell Limit Order
# qcxSellLimit(float amount, float price, string book);
# qcxSellLimit(1.5, 450.55, btc_usd); sell 1.5 bitcoin at 450.55$ on pair BTC/USD
sub qcxSellLimit($$$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/sell";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'amount' => "$_[0]", 'price' => "$_[1]", 'book' => "$_[2]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Buy Market Order
# qcxBuyMarket(float amount, string book);
# qcxBuyMarket(1.5, btc_usd); buy 1.5 bitcoin at market price on pair BTC/USD
sub qcxBuyMarket($$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/buy";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'amount' => "$_[0]", 'book' => "$_[1]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Sell Market Order
# qcxSellMarket(float amount, string book);
# qcxSellMarket(1.5, btc_usd); sell 1.5 bitcoin at market price on pair BTC/USD
sub qcxSellMarket($$) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/sell";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'amount' => "$_[0]", 'book' => "$_[1]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Ticker think function, returns prices
sub qcxTicker_think($) {
	sleep 1;
	our $qcx_api_url = "https://api.quadrigacx.com/public/info";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->get($qcx_api_url); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		# print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
		our $qcx_ticker = $qcx_json->{"$_[0]"}; # Json decodes to an arrayref$
		 return (sprintf("%.8f", $qcx_ticker->{'buy'}),
		 sprintf("%.8f", $qcx_ticker->{'sell'}),
		 sprintf("%.8f", $qcx_ticker->{'rate'}));
	}
}

# Get Order Book
# qcxOrderBook(string book, intbool group);
# qcxOrderBook("btc_usd", 1); show all orders for BTC/USD grouped by price
# qcxOrderBook("btc_cad", 0); show all orders for BTC/CAD without grouping
sub qcxOrderBook($$) {
	our $qcx_api_url = "https://api.quadrigacx.com/v2/order_book?book=$_[0]&group=$_[1]";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->get($qcx_api_url); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Get Transactions
# qcxTransactions(string book, string time);
# qcxTransactions("btc_usd", hour); show all transactions for BTC/USD in the last hour
# qcxTransactions("btc_cad", minute); show all transactions for BTC/CAD in the last minute
sub qcxTransactions($$) {
	our $qcx_api_url = "https://api.quadrigacx.com/v2/transactions?book=$_[0]&time=$_[1]";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->get($qcx_api_url); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Get user's open orders
# qcxOrders(string book);
# qcxOrders("btc_usd");
sub qcxOrders($) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/private/orders";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'book' => "$_[0]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Cancel a user order
# qcxCancelOrder(string orderid);
# qcxCancelOrder("as1r1oqgnxpcf5jaijwtndw1d4s1s412w3uyrkfei4rx9b8su4mhiiiwnbxffzic");
sub qcxCancelOrder($) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/private/cancel";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'id' => "$_[0]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Lookup an order
# qcxLookupOrder(string orderid);
# qcxLookupOrder("as1r1oqgnxpcf5jaijwtndw1d4s1s412w3uyrkfei4rx9b8su4mhiiiwnbxffzic");
sub qcxLookupOrder($) {
	our $nonce = time;
	$qcx_signature = uc(hmac_sha256_hex("$nonce" . "$qcx_clientid" . "$qcx_apikey", $qcx_secret));
	our $qcx_api_url = "https://api.quadrigacx.com/v2/lookup_order";
	our $qcx_client = WWW::Mechanize->new();
	our $qcx_connected = eval { $qcx_client->post($qcx_api_url, ['key' => "$qcx_apikey", 'nonce' => "$nonce", 'signature' => "$qcx_signature", 'id' => "$_[0]"]); };
	if (! $qcx_connected) { error_qcx(); } # Catch connection error
	else { # Set values when connection is successful
		our $qcx_content = $qcx_client->content;
		# print "Actual Response:\n" . Dumper($qcx_content) . "\n";
		our $qcx_json = decode_json( $qcx_content );
		print "Pretty Response:\n" . Dumper($qcx_json) . "\n";
	}
}

# Error if unable to establish a connection
sub error_qcx() {
 # do nothing
print "error: api failed to connect!\n";
}

qcxTransactions("btc_cad", "hour"); 