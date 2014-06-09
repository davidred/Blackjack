require_relative 'hand'

class Player
	attr_accessor :name, :balance

	def initialize
		@hands = []
	end

	def add_hand(hand)
		a_hand = Hand.new
		a_hand.hand = hand
		@hands << a_hand
	end

	def remove_hands
		@hands = []
	end

	def hands
		@hands
	end

	def name
		@name
	end

	def balance
		@balance
	end

	def get_balance
		puts "Your balance is now $#{@balance}"
	end

	def bet(bet)
		bet = bet.to_i
		bet.class
	 	if bet.to_i == @balance
	 		puts "This could be your last bet... good luck!"
	 		@balance -= bet.to_i
	 	else
	 		@balance -= bet.to_i
		end
	end

	def win(bet)
		@balance+=bet
	end
end