class Hand
   attr_accessor :hand

   $face_cards = ['J','Q','K']
   
   def initialize(hand=[])
     @hand = hand
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

   def add_card(card)
      @hand << card
   end

   def bust?
      if score > 21
         true
      else
         false
      end
   end

   def blackjack?
      if score == 21 && @hand.length == 2
         true
      else
         false
      end
   end

   def ace?
     if @hand.select{|card| card.include?('A')}.empty?
       false
     else
       true
     end
   end

   def show
     cards = ""
     @hand.each do |card|
       cards += card+" "
     end
     cards[0..-2]
   end

   def score
     score = 0
     @hand.each do |card|
       score+=value(card)
     end
     if score > 21 && !@hand.select{|card| card.include?('A')}.empty?
       @hand.select{|card| card.include?('A')}.length.times do
         score-=10
       end
     end
     score
   end

end