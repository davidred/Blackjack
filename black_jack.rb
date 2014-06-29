#!/usr/bin/env ruby


require_relative 'deck'
require_relative 'hand'
require_relative 'player'
require_relative 'strategy'

class Blackjack

def get_bet
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

def get_bet_auto(table_min,table_max)
  bet = $strategy.get_bet(table_min,table_max)
  while true
    if bet < table_min
      puts "You don't have enough to play at this table!"
      exit
    elsif bet>$player.balance
      bet-=1
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
  puts "Big Baller!!! Changing $#{$player.balance}. Good luck!"
end

def split(hand,bet,dealer_shows=nil)
  puts if $mode != 'auto'
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
  puts $player.hands.last.show if $mode != 'auto'
  puts if $mode != 'auto'
  $player.add_hand(hand_2)
  $player.hands.last.bet = bet
  puts $player.hands.last.show if $mode != 'auto'
  #play hands
  puts if $mode != 'auto'
  if $mode == 'auto'
    play_hand_auto(dealer_shows)
  else
    play_hand
  end
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
  	    puts "Would you like to Hit, Stay, Double Down, or Split? (h/s/d/p)"
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

def play_hand_auto(dealer_shows)
 catch (:found) do 
  $player.hands.each do |hand|
    bust = false  
    stay = false
    hand.score == 21 ? bj = true : bj = false
    counter = 0

    # if bj 
    #   puts "Your hand"
    #   puts hand.show
    #   puts "BLACKJACK!"
    # end

    while bust==false && stay==false && bj==false do
      counter+=1
      puts if $mode != 'auto'
      puts "Your hand" if $mode != 'auto'
      puts hand.show if $mode != 'auto'
      puts if $mode != 'auto'
      puts "You have #{hand.score}" if $mode != 'auto'
      puts if $mode != 'auto'
      #Get move
      move = $strategy.get_move(hand, dealer_shows,counter)
      puts "Your move is #{move}" if $mode != 'auto'
      if move == 'h'
        hand.add_card($deck.deal)
        if hand.bust?
          puts hand.show if $mode != 'auto'
          puts "Bust. You lose" if $mode != 'auto'
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
          sleep(1) if $mode != 'auto'
          puts hand.show if $mode != 'auto'
          puts if $mode != 'auto'
          if hand.bust?
            puts "Bust. You lose" if $mode != 'auto'
            bust = true
          end
          stay = true
        end
      elsif move == 'p'
        if $bet > $player.balance
          puts "You don't have enough money to split"
          counter -= 1
        else
          $player.bet(hand.bet)#Remove bet from players bankroll
          split(hand,hand.bet,dealer_shows)
          throw(:found)
        end
      end 
    end
  end
 end 
end

def dealer_plays
  puts if $mode != 'auto'
  puts "Dealer shows #{$dealer.hands.last.show}" if $mode != 'auto'
  sleep(1) if $mode != 'auto'
  while true
	if $dealer.hands.last.score < 17
	  puts if $mode != 'auto'
	  puts "Dealer hits" if $mode != 'auto'
	  $dealer.hands.last.add_card($deck.deal)
	  puts $dealer.hands.last.show if $mode != 'auto'
	  sleep(1) if $mode != 'auto'
	elsif $dealer.hands.last.score >= 17 && $dealer.hands.last.score <= 21
	  puts if $mode != 'auto'
	  puts "Dealer has #{$dealer.hands.last.score}" if $mode != 'auto'
	  break
    elsif $dealer.hands.last.score > 21
	  puts if $mode != 'auto'
	  puts "Dealer busts. You win!"	if $mode != 'auto'
	  break		
	end
  end
  puts if $mode != 'auto'
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
      puts "You lost #{hand.bet} on #{hand.show}" if $mode != 'auto'
      $losses+=1
    elsif hand.blackjack?
      puts "You win #{hand.bet*1.5} on #{hand.show}" if $mode != 'auto'
      $wins+=1
      $player.win(hand.bet + hand.bet * 1.5)
    elsif !hand.bust? && $dealer.hands.last.bust? #if user busted, he lost
      puts "You win #{hand.bet} on #{hand.show}" if $mode != 'auto'
      $wins+=1
      $player.win(hand.bet * 2)
    elsif hand.score == $dealer.hands.last.score #push
      puts "You push on #{hand.show}" if $mode != 'auto'
      $pushes+=1
      $player.win(hand.bet)
    elsif hand.score < $dealer.hands.last.score
      $losses+=1
      puts "You lost #{hand.bet} on #{hand.show}" if $mode != 'auto'
    else
      puts "You win #{hand.bet} on #{hand.show}" if $mode != 'auto'
      $wins+=1
      $player.win(hand.bet * 2)
    end
  end
end

puts
puts "***Welcome to the Rozenberg Indian Reservation Casino!!!***" #Welcome
puts
#Initialize play mode
$mode = ARGV[0].to_s  
ARGV[1].nil? ? iterations = 10 : iterations = ARGV[1].to_i
ARGV[2].nil? ? table_min = 10 : table_min = ARGV[2].to_i
ARGV[3].nil? ? table_max = 1000 : table_max = ARGV[3].to_i

ARGV.clear
puts
$dealer = Player.new #Initiate Dealer
if $mode != 'auto'
   define_player #Initiate Player
else 
   $player = Player.new
   $player.balance=10000000000000
end

$deck = Deck.new #Initiate Deck
$strategy = Strategy.new #Initiate Strategy
counter = 0
$wins, $losses, $pushes = 0, 0, 0
starting_balance = $player.balance

while counter < iterations do 
  if $mode == 'auto'
    $bet = get_bet_auto(table_min,table_max)
    counter += 1
  else 
    $bet = get_bet #Ask what player wants to bet
  end
  $player.bet($bet) #Remove bet from players bankroll
  #Deal Cards
  card_1 = $deck.deal
  card_2 = $deck.deal
  card_3 = $deck.deal
  card_4 = $deck.deal
  #Initiate players hand
  $player.add_hand([card_1,card_2])
  $player.hands.last.bet = $bet
  puts if $mode != 'auto'
  #puts "Your hand"
  #puts $player.hands.last.show
  puts  if $mode != 'auto'
  puts "Dealer is showing #{card_3}" if $mode != 'auto'
#  puts "#{card_3}" #if $mode != 'auto'
  puts if $mode != 'auto'
  
  #Player plays blackjack
  if $mode == 'auto'
    dealer_shows = card_3
    play_hand_auto(dealer_shows)
  else
    $strategy.right_move($player.hands.last,card_3[0])
    play_hand
  end
  #Initiate dealers hand
  $dealer.add_hand([card_3,card_4])

  #if $player.hands.select{|hand| hand.bust?}.empty?
  if !$player.hands.last.bust? && !$player.hands.last.blackjack?
	dealer_plays
  end
  #Compare scores
  puts if $mode != 'auto'
  compare

  puts if $mode != 'auto'
  if $mode != 'auto'
    puts "Your new balance is #{$player.balance}" if $mode != 'auto' 
    puts 
  end
  # if !play_again?
  #   exit
  # end

   $player.remove_hands
   $dealer.remove_hands
end

puts "You won #{$wins} times, you lost #{$losses} times, and you pushed #{$pushes} times."
puts "With this strategy, you win #{($wins.to_f/counter)*100} percent of the time"
puts "With this strategy, you lose #{($losses.to_f/counter)*100} percent of the time"
#puts "You started with $#{starting_balance}. You now have a balance of $#{$player.balance}"
starting_balance < $player.balance ? puts("You made #{$player.balance - starting_balance}"): puts("You lost $#{starting_balance-$player.balance}")

end