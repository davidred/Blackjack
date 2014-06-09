SUITS = ['♥','♦','♠','♣']
CARDS = ['A','2','3','4','5','6','7','8','9','J','Q','K']


class Deck
	def initialize()
		@cut_card = 'c'
		@numdecks = 6
        @collection=[]
		@numdecks.times do 
			SUITS.each do |suit|
				CARDS.each do |card|
					@collection << card+suit
				end
			end
		end
		@collection = @collection.shuffle
		cut
	end

	def cut
		rand_index = ((@collection.length*0.2).to_i..(@collection.length*0.8).to_i).to_a.sample	
		@collection.insert(rand_index,@cut_card)
	end

	def reshuffle
		@collection = []
		@numdecks.times do
			SUITS.each do |suit|
				CARDS.each do |card|
					@collection << card+suit
				end
			end
		end
		@collection = @collection.shuffle
		cut
	end

	def deal
		cut = false
		if @collection.pop == @cut_card
			cut=true 
			throwout_card = @collection.pop
			card = @collection.pop
		else
			card = @collection.pop
		end
		if cut == true
			reshuffle
		end
		card
	end
end