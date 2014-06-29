SUITS = ['H','D','S','C']
CARDS = ['A','2','3','4','5','6','7','8','9','J','Q','K']


class Deck
	attr_reader :deck

	def initialize(deck = make_deck)
		@deck = deck
		@cut_card = 'c'
	end

	def make_deck(numdecks = 6)
		@deck = []
		@cut_card = 'c'
		numdecks.times do 
			SUITS.each do |suit|
				CARDS.each do |card|
					@deck << card+suit
				end
			end
		end
		@deck = @deck.shuffle
		cut
	end

	def cut
		rand_index = ((@deck.length*0.2).to_i..(@deck.length*0.8).to_i).to_a.sample	
		@deck.insert(rand_index,@cut_card)
	end

	def deal
		cut = false
		card = @deck.pop
		if card == @cut_card
			puts "cut card has been dealt"
			cut=true 
			card = @deck.pop
			make_deck
		end
		card
	end
end