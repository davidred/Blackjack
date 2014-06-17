require 'json'
require 'redis'

def get_connection
	begin
		if ENV.has_key?("REDISCLOUD_URL")
			connection = Redis.new(url: ENV["REDISCLOUD_URL"])
		else
			connection = Redis.new
		end
	ensure
		connection.quit
	end
end

def find_game(id)
	redis = get_connection
	game = JSON.parse(redis.get(id), symbolize_names: true)
	redis.quit
	return game
end

def save_game(id, player, dealer, deck, balance, bets, moves, win_or_loss)
	redis = get_connection
	redis.setex(id, 3600, {player: player, dealer: dealer, deck: deck, balance: balance, bets: bets, moves: moves, win_or_loss: win_or_loss, created: Time.now}.to_json)
	redis.quit
end

def check_dup(id)
	redis = get_connection
	if redis.exists(id) == true
		redis.quit
		return true
	end
	redis.quit
	return false
end

