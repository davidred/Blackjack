require_relative 'hand'

class Strategy

	FACE_CARDS = ['J','Q','K']
	DEALER_SHOWS = {'2'=>0,'3'=>1,'4'=>2,'5'=>3,'6'=>4,'7'=>5,'8'=>6,'9'=>7,'10'=>8,'A'=>9}
	HAND_SCORE = {'8'=>0,'9'=>1,'10'=>2,'11'=>3,'12'=>4,'13'=>5,'14'=>6,'15'=>7,'16'=>8,'17'=>9,'18'=>10,'19'=>11}
	SPLITS = {'2'=>0,'3'=>1,'4'=>2,'5'=>3,'6'=>4,'7'=>5,'8'=>6,'9'=>7,'10'=>8,'A'=>9}
	STANDARD_STRATEGY = [
						 ['h','h','h','h','h','h','h','h','h','h'],							 
						 ['h','d','d','d','d','h','h','h','h','h'],
						 ['d','d','d','d','d','d','d','d','h','h'],
						 ['d','d','d','d','d','d','d','d','d','h'],
						 ['h','h','s','s','s','h','h','h','h','h'],
						 ['s','s','s','s','s','h','h','h','h','h'],
						 ['s','s','s','s','s','h','h','h','h','h'],
						 ['s','s','s','s','s','h','h','h','h','h'],
						 ['s','s','s','s','s','h','h','h','h','h'],
						 ['s','s','s','s','s','s','s','s','s','s'],
						 ['s','s','s','s','s','s','s','s','s','s'],
						 ['s','s','s','s','s','s','s','s','s','s']
						]
	SOFT_STRATEGY = [
					 ['h','h','h','h','h','h','h','h','h','h'],							 
					 ['h','d','d','d','d','h','h','h','h','h'],
					 ['d','d','d','d','d','d','d','d','h','h'],
					 ['d','d','d','d','d','d','d','d','d','h'],
					 ['h','h','s','s','s','h','h','h','h','h'],
					 ['h','h','h','d','d','h','h','h','h','h'],
					 ['h','h','h','d','d','h','h','h','h','h'],
					 ['h','h','d','d','d','h','h','h','h','h'],
					 ['h','h','d','d','d','h','h','h','h','h'],
					 ['h','d','d','d','d','h','h','h','h','h'],
					 ['s','d','d','d','d','s','s','h','h','h'],
					 ['s','s','s','s','s','s','s','s','s','s']
					]
	SPLIT_STRATEGY = [
					  ['p','p','p','p','p','p','h','h','h','h'],
					  ['p','p','p','p','p','p','h','h','h','h'],
					  ['h','h','h','p','p','h','h','h','h','h'],
					  ['d','d','d','d','d','d','d','d','d','h'],
					  ['p','p','p','p','p','h','h','h','h','h'],
					  ['p','p','p','p','p','p','h','h','h','h'],
					  ['p','p','p','p','p','p','p','p','p','p'],
					  ['p','p','p','p','p','s','p','p','s','s'],
					  ['s','s','s','s','s','s','s','s','s','s'],
					  ['p','p','p','p','p','p','p','p','p','p']
					 ]

	def get_move(hand,dealer_shows,counter)
		if hand.score <= 8
			row = '8'
		elsif hand.score >= 17
			row = '17' 
		else 
			row = hand.score.to_s
		end

		FACE_CARDS.include?(dealer_shows[0]) ? dealer_shows = '10' : dealer_shows = dealer_shows[0]
		
		if counter == 1 && hand.hand[0][0]==hand.hand[1][0]
			row = FACE_CARDS.include?(hand.hand[0][0]) ? '10' : hand.hand[0][0]
			move = SPLIT_STRATEGY[SPLITS[row]][DEALER_SHOWS[dealer_shows]]
			#puts "split strategy says #{move}, (#{row},#{dealer_shows})"
		elsif hand.ace?
			row = '19' if hand.score >= 19
			move = SOFT_STRATEGY[HAND_SCORE[row]][DEALER_SHOWS[dealer_shows]]
			#puts "soft strategy says #{move}, (#{row},#{dealer_shows})"
		else
			move = STANDARD_STRATEGY[HAND_SCORE[row]][DEALER_SHOWS[dealer_shows]]
			#puts "standard strategy says #{move}, (#{row},#{dealer_shows})"
		end

		if move == 'd' && counter != 1
			move = 'h'
		end
		move
	end	

	def right_move (hand,dealer_shows)
		if hand.score <= 8
			row = '8'
		elsif hand.score >= 17
			row = '17' 
		else 
			row = hand.score.to_s
		end

		FACE_CARDS.include?(dealer_shows[0]) ? dealer_shows = '10' : dealer_shows = dealer_shows[0]
	


		if hand.ace?
			row = '19' if hand.score >= 19
			puts "The right move is #{SOFT_STRATEGY[HAND_SCORE[row]][DEALER_SHOWS[dealer_shows]]}"
		elsif hand.hand[0][0] == hand.hand[1][0]
			row = FACE_CARDS.include?(hand.hand[0][0]) ? '10' : hand.hand[0][0]
			puts "The right move is #{SPLIT_STRATEGY[SPLITS[row]][DEALER_SHOWS[dealer_shows]]}"
		else
			puts "The right move is #{STANDARD_STRATEGY[HAND_SCORE[row]][DEALER_SHOWS[dealer_shows]]}"
		end
	end	

	def get_bet(table_min,table_max)
		table_min
	end
end
		