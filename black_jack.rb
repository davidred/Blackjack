require_relative 'deck'
require_relative 'hand'
require_relative 'player'

def get_bet
  puts
  while true
    puts "Place your bet"
  	bet = gets.chomp.to_i
  	if bet>$player.balance
   	  puts "You only have $#{$player.balance} left. You can't bet more than that."
   	  puts
    else
      break
	end	
  end
  bet
end

def define_player
  puts "What's your name?"
  name = gets.chomp
  $player = Player.new
  $player.name=name
  puts
  puts "Hi #{$player.name}, how much money do you want to spend?"
  bankroll = gets.chomp
  $player.balance=bankroll.to_i
  puts
  puts "Bigggg Baller!!! Changing $#{$player.balance}. Good luck!"
end

def split(hand,bet)
  puts
  #remove current hand from player stack
  $player.hands.delete(hand)
  #create two new hands
  hand_1 = []
  hand_2 = []
  hand_1 << hand.hand[0]
  hand_1 << $deck.deal
  hand_2 << hand.hand[1]
  hand_2 << $deck.deal
  #add new hands to player object
  $player.add_hand(hand_1)
  $player.hands.last.bet = bet
  puts $player.hands.last.show
  puts
  $player.add_hand(hand_2)
  $player.hands.last.bet = bet
  puts $player.hands.last.show
  #play hands
  puts
  play_hand
end

def play_hand
 catch (:found) do 
  $player.hands.each do |hand|
    bust = false	
    stay = false
    bj = false
    counter = 0
    while bust==false && stay==false do
  	  counter+=1
  	  puts "Your hand" 
  	  puts hand.show
  	  puts
  	  puts "You have #{hand.score}"
  	  puts
  	  if counter == 1 && hand.hand[0][0]==hand.hand[1][0]
  	    puts "Would you like to Hit, Stay, Double Down, or Split? (h/s/d/split)"
  	    move = gets.chomp
  	  elsif counter == 1 && hand.hand[0][0]!=hand.hand[1][0]
        puts "Would you like to Hit, Stay, or Double Down? (h/s/d)" 
        move = gets.chomp
      else
  	    puts "Would you like to Hit or Stay? (h/s)"
  	    move = gets.chomp
  	  end
  	  if move == 'h'
        hand.add_card($deck.deal)
        if hand.bust?
          puts hand.show
  	  	  puts "Bust. You lose"
  	  	  bust = true
  	  	end
  	  elsif move == 's'
  	    stay = true
  	  elsif move == 'd'
  	    if $bet > $player.balance
  	  	  puts "You don't have enough money to double down"
  	  	  counter -= 1
  	    else
  	      $player.bet(hand.bet)#Remove bet from players bankroll
  	      hand.bet=hand.bet*2
          hand.add_card($deck.deal)
          sleep(1)
          puts hand.show
          puts
          if hand.bust?
          	puts "Bust. You lose"
          	bust = true
          end
  	      stay = true
  	    end
  	  elsif move == 'split'
        if hand.hand[0][0] != hand.hand[1][0]
          puts "You can only split when you have two of the same card"
          puts
          counter-=1
        elsif $bet > $player.balance
          puts "You don't have enough money to double down"
          counter -= 1
        else
          $player.bet(hand.bet)#Remove bet from players bankroll
          split(hand,hand.bet)
  	      throw(:found)
        end
  	  else 
  	    puts "Enter either \'h\' or \'s\'"
  	  end	
  	end
  end
 end 
end

def dealer_plays
  puts
  puts "Dealer shows #{$dealer.hands.last.show}"	
  sleep(1)	
  while true
	if $dealer.hands.last.score < 17
	  puts
	  puts "Dealer hits"
	  $dealer.hands.last.add_card($deck.deal)
	  puts $dealer.hands.last.show
	  sleep(1)
	elsif $dealer.hands.last.score >= 17 && $dealer.hands.last.score <= 21
	  puts
	  puts "Dealer has #{$dealer.hands.last.score}"
	  break
    elsif $dealer.hands.last.score > 21
	  puts 
	  puts "Dealer busts. You win!"	
	  break		
	end
  end
  puts
end

def play_again?
  while true
    puts "Do you want to play again? (y/n)"
    response = gets.chomp
    if response == 'n'
      play = false
      break
    elsif response == 'y' && $player.balance == 0
      puts
      puts "You don't have any more money. Go home to your wife and kids."
      puts
      exit
    elsif response == 'y'
      play = true
      break
    else
      puts "Invalid response."
    end
  end
  play
end	

def compare
  $player.hands.each do |hand|
    if hand.bust? 
      puts "You lost #{hand.bet} on #{hand.show}"
    elsif !hand.bust? && $dealer.hands.last.bust? #if user busted, he lost
      puts "You win #{hand.bet} on #{hand.show}"
      $player.win(hand.bet * 2)
    elsif hand.score == $dealer.hands.last.score #push
      puts "You push on #{hand.show}"
      $player.win(hand.bet)
    elsif hand.score < $dealer.hands.last.score
      puts "You lost #{hand.bet} on #{hand.show}"
    else
      puts "You win #{hand.bet} on #{hand.show}"
      $player.win(hand.bet * 2)
    end
  end
end

puts
puts "***Welcome to the Rozenberg Indian Reservation Casino!!!***" #Welcome
puts
$dealer = Player.new #Initiate Dealer
define_player #Initiate Player
$deck = Deck.new #Initiate Deck

while true
  $bet = get_bet #Ask what player wants to bet
  $player.bet($bet) #Remove bet from players bankroll
  #Deal Cards
  card_1 = $deck.deal
  card_2 = $deck.deal
  card_3 = $deck.deal
  card_4 = $deck.deal
  #Initiate players hand
  $player.add_hand([card_1,card_2])
  $player.hands.last.bet = $bet
  puts
  #puts "Your hand"
  #puts $player.hands.last.show
  #puts 
  puts "Dealer is showing"
  puts "#{card_3}"
  puts
  #Player plays blackjack
  play_hand
  #Initiate dealers hand
  $dealer.add_hand([card_3,card_4])

  #if $player.hands.select{|hand| hand.bust?}.empty?
  if !$player.hands.last.bust?
	dealer_plays
  end
  #Compare scores
  puts
  compare

  puts
  puts "Your new balance is #{$player.balance}"
  puts
  if !play_again?
    exit
  end

   $player.remove_hands
   $dealer.remove_hands
end
