class Player
	attr_accessor :name, :balance, :bets, :moves, :win_or_loss

	def initialize(hands=[],balance=1000, bets=[], moves=[], win_or_loss=[])
	  @hands = hands
	  @balance = balance
	  @bets = bets
	  @moves = moves
	  @win_or_loss = win_or_loss
	end

	def add_hand(hand)
	  @hands << hand
	end

	def add_move(move)
	  @moves << move
	end

	def add_bet(bet)
	  @bets << bet
	end

	def show(hand)
      cards = ""
      hand.each do |card|
        cards += card+" "
      end
      cards[0..-2].split(" ")
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

	def bet(bet)
	  bet = bet.to_i
	  @balance -= bet 
	end

	def win(bet)
	  @balance+=bet
	end
end