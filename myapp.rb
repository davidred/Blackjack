require 'sinatra'

require_relative 'game'
require_relative 'strategy'
require_relative 'deck'
require_relative 'player'
require_relative 'helpers'

get '/' do
  erb :home
end

post '/' do
   #COMING FROM THE HOMEPAGE
   bet = params["initial_bet"].to_i
   if bet > 0 && bet <= 1000
     @game = Blackjack.new
     @deck = Deck.new
     #@strategy = Strategy.new
     @player = Player.new
     @dealer = Player.new
     @player.balance = 1000
     @bust = false 
     @stay = false
     @bj = false
     @dealer_bj = false
     @fresh_deal = true #when fresh_deal is true, player has options to double and split as well as hit and stay
     #deal hands
     @game.deal_hands(@deck,@player,@dealer)
     @player.bet(bet) #remove bet from player balance
     #associate bet with hand
     @player.add_bet(bet)
     #check for blackjack (both player and dealer)
     if @player.hands.length == 1 #you cant get blackjack after you split
       player_hand, player_bet, dealer_hand = @player.hands.last, @player.bets.last.to_i, @dealer.hands.last
       if @game.blackjack?(player_hand) && !@game.blackjack?(dealer_hand)#if player has blackjack and dealer doesn't have blackjack
         puts "blackjack!"
         @player.win_or_loss[0] = 'win'
         @bj = true #blackjack notification shown, h/s/d/split options not displayed to user
         @player.win(player_bet*(1 + 1.5))#gets bet + bet * 1.5
       elsif @game.blackjack?(player_hand) && @game.blackjack?(dealer_hand)#elsif player has blackjack and dealer has blackjack
         puts "you both have blackjack!"
         @player.win_or_loss[0] = 'push'
         @bj = true #blackjack notification shown, next hand option avaialable
         @player.win(player_bet) #player wins his bet back
       elsif !@game.blackjack?(player_hand) && @game.blackjack?(dealer_hand) #elseif player does not have blackjack and dealer has blackjack
         puts "dealer has 21 :("
         @player.win_or_loss[0] = 'loss'
         @dealer_bj = true
         @stay = true #goes to next hand
       end
     end
     #generate id to save game data for next post request
     @id = rand(36**6).to_s(36)
     while check_dup(@id)
       @id = rand(36**6).to_s(36)
     end
     #saves game data for next post request
     save_game(@id, @player.hands, @dealer.hands, @deck.deck, @player.balance, @player.bets, @player.moves, @player.win_or_loss)
     
     erb :game


   #AFTER THE HOMEPAGE
   elsif params["initial_bet"] == nil
   	 index = params["index"].to_i #Which hand is the action is being taken on (in the case of split)
     if params["hit"] != nil
       @id = params["hit"]
   	 	 @action = "hit"
   	 elsif params["stay"] != nil
   	 	 @id = params["stay"]
       @action = "stay"
     elsif params["double"] != nil
   	 	 @id = params["double"]
       @action = "double"
   	 elsif params["split"] != nil
   	 	 @id = params["split"]
       @action = "split"
     elsif params["next_hand"] != nil
       @id = params["next_hand"]
       @action = "next_hand"
       hand_bet = params["new_bet"].to_i
   	 end

     @bust = false
     @stay = false
     @bj = false
     @dealer_bj = false
     
     @saved_game = find_game(@id)

     @game = Blackjack.new
     @deck = Deck.new(@saved_game[:deck])
     if @action == "next_hand"
       @player = Player.new
       @dealer = Player.new
       @player.balance = @saved_game[:balance].to_i
       @game.deal_hands(@deck,@player,@dealer)
       @player.bet(hand_bet) #remove bet from player balance
       @player.add_bet(hand_bet) #associate bet with hand
       @fresh_deal = true
       #check for blackjack (both player and dealer)
       if @player.hands.length == 1 #you cant get blackjack after you split
         player_hand, player_bet, dealer_hand = @player.hands.last, @player.bets.last.to_i, @dealer.hands.last
         if @game.blackjack?(player_hand) && !@game.blackjack?(dealer_hand)#if player has blackjack and dealer doesn't have blackjack
           puts "blackjack!"
           @player.win_or_loss[0] = 'win'
           @bj = true #blackjack notification shown, h/s/d/split options not displayed to user
           @player.win(player_bet*(1 + 1.5))#gets bet + bet * 1.5
         elsif @game.blackjack?(player_hand) && @game.blackjack?(dealer_hand)#elsif player has blackjack and dealer has blackjack
           puts "you both have blackjack!"
           @player.win_or_loss[0] = 'push'
           @bj = true #blackjack notification shown, next hand option avaialable
           @player.win(player_bet) #player wins his bet back
         elsif !@game.blackjack?(player_hand) && @game.blackjack?(dealer_hand) #elseif player does not have blackjack and dealer has blackjack
           puts "dealer has 21 :("
           @player.win_or_loss[0] = 'loss'
           @stay = true #goes to next hand
           @dealer_bj = true
         end
       end
     else
       @player = Player.new(@saved_game[:player], @saved_game[:balance], @saved_game[:bets], @saved_game[:moves], @saved_game[:win_or_loss])
       @dealer = Player.new(@saved_game[:dealer])
     end

     if @action == "hit"
       puts "hitting hand #{index}"
   	   @game.hit(@player,@deck,index)
       @game.bust?(@player.hands[index]) ? @player.moves[index] = 'bust' : @player.moves[index] = 'open' #check if player busted
       @bust = true if @player.moves.select{|move| move == 'bust'}.length == @player.hands.length #check if all hands busted
       puts "busted hand #{index}" if @game.bust?(@player.hands[index])
       puts "all hands busted" if @bust
       @stay = true if @player.moves.select{|move| move == 'bust' || move == 'stay'}.length == @player.hands.length #check if all hands have either busted or stayed
     elsif @action == "stay"
       @player.moves[index] = 'stay'
       puts "#{@player.moves[index]} for hand #{index}"
       @stay = true if @player.moves.select{|move| move == 'bust' || move == 'stay'}.length == @player.hands.length #check if all hands have either busted or stayed
       puts "all hands are either bust or stay" if @stay == true
     elsif @action == "double"
       double = @player.bets[index]
       @player.bets[index] = double * 2
       @player.bet(double)
       @game.hit(@player,@deck,index)
       if @game.bust?(@player.hands[index])
         @player.moves[index] = 'bust'
         @bust = true if @player.moves.select{|move| move == 'bust'}.length == @player.hands.length #check if all hands busted
       else
         @player.moves[index] = 'stay'
         @stay = true if @player.moves.select{|move| move == 'bust' || move == 'stay'}.length == @player.hands.length #check if all hands have either busted or stayed
       end
     elsif @action == "split"
      #think about adding this to game.rb as @game.split
       split_hand = @player.hands[index]
       split_hand_bet = @player.bets[index]
       @player.hands.delete_at(index)
       @player.bets.delete_at(index)
       hand_1, hand_2 = [],[]
       hand_1 << split_hand[0]
       hand_1 << @deck.deal
       hand_2 << split_hand[1]
       hand_2 << @deck.deal
       @player.add_hand(hand_1)
       @player.add_hand(hand_2)
       @player.bet(split_hand_bet) #remove bet from player balance
       @player.add_bet(split_hand_bet) #associate bet with hand
       @player.add_bet(split_hand_bet)
       @fresh_deal = true
     end

     #if the player stays and hasn't busted ON ALL HANDS, or gotten bj, the dealer plays
     if @stay == true && @bust == false 
       #dealer plays
       while true
         if @game.score(@dealer.hands.last) < 17
           @game.hit(@dealer,@deck)
         elsif @game.score(@dealer.hands.last) >= 17 && @game.score(@dealer.hands.last) <= 21
           break
         elsif @game.score(@dealer.hands.last) > 21
           @dealer_bust = true
           break   
         end
       end
       #compare scores
       dealer_score = @game.score(@dealer.hands.last)
       @player.hands.each_with_index do |hand,index|
         player_score = @game.score(hand)
         hand_bet = @player.bets[index].to_i
         if @player.moves[index] == 'bust'
           @player.win_or_loss[index] = 'loss'
         elsif @dealer_bust == true
           @player.win(hand_bet * 2) #player wins bet
           @player.win_or_loss[index] = 'win'
         elsif player_score == dealer_score #push
           @push = true
           @player.win(hand_bet) #player gets his bet back
           @player.win_or_loss[index] = 'push'
         elsif player_score < dealer_score
           @player.win_or_loss[index] = 'loss'
           #@player_wins = false
         else
           @player.win_or_loss[index] = 'win'
           #@player_wins = true
           @player.win(hand_bet * 2)
         end
       end
     elsif @bust == true #if the player busted on all hands
       #@player_wins = false
       @player.hands.length.times do 
         @player.win_or_loss << 'loss'
       end
     end
     
     save_game(@id, @player.hands, @dealer.hands, @deck.deck, @player.balance, @player.bets, @player.moves, @player.win_or_loss)

   	 erb :game

   end
end