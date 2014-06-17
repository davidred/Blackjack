require_relative 'deck'
require_relative 'hand'
require_relative 'player'
require_relative 'strategy'

class Blackjack
	$face_cards = ['J','Q','K']

	def deal_hands(deck,player,dealer)
		card_1 = deck.deal
		card_2 = deck.deal
		card_3 = deck.deal
		card_4 = deck.deal

		player.add_hand([card_1,card_3])
		dealer.add_hand([card_2,card_4])
	end

	def hit(player,deck,index=0)
		hand = player.hands[index]
		hand << deck.deal
		player.hands[index] = hand
	end

	def value(card)
      if $face_cards.include?(card[0])
        10
      elsif card[0]=='A'
        11
      else
        card.to_i
      end
    end

	 def score(hand)
     score = 0
     hand.each do |card|
       score+=value(card)
     end
     if score > 21 && !hand.select{|card| card.include?('A')}.empty?
       hand.select{|card| card.include?('A')}.length.times do
         score-=10
       end
     end
     score
     end

     def blackjack?(hand)
     	score = 0
     	hand.each do |card|
     		score += value(card)
     	end
     	if score == 21
     		true
     	else
     		false
     	end
     end

     def split?(hand)
       if hand[0][0] == hand[1][0]
       	 true
       else
       	 false
       end
     end

     def bust?(hand)
     	if score(hand) > 21
     		true
     	else
     		false
     	end
     end
end
