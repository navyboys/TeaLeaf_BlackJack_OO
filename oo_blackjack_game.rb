# Object Oriented Blackjack Game

require 'rubygems'
require 'pry'

class Card
  attr_accessor :suit, :value

  def initialize(s, v)
    @suit = s
    @value = v
  end

  def to_s
    "[#{suit}, #{value}]"
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |s|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |v|
        @cards << Card.new(s, v)
      end
    end
    @cards.shuffle!
  end
end

module Hand
  def numerate(card)
    if card == 'A'
      11
    elsif card.to_i == 0
      10
    else
      card.to_i
    end
  end

  def total
    # keep only value info
    array = cards.map{|e| e.value }

    # calculate
    total = 0
    array.each { |e| total += numerate(e) } 

    # correct for 'A'
    array.select{ |e| e == 'A' }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def show_hand
    puts "-- #{name}'s cards: --"
    cards.each do|card|
      puts "#{card}"
    end
    puts "=> Total: #{total}"
  end

  def get_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Game::BLACKJACK_AMOUNT
  end
end

class Player
  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = 'Dealer'
    @cards = []
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new('')
    @dealer = Dealer.new
  end

  def get_player_name
    puts "Welcome to Blackjack Game!"
    puts "Enter your name, please."
    player.name = gets.chomp
  end

  def deal_cards
    player.get_card(deck.cards.pop)
    dealer.get_card(deck.cards.pop)
    player.get_card(deck.cards.pop)
    dealer.get_card(deck.cards.pop)
  end

  def show_hands
    player.show_hand
    dealer.show_hand
  end

  def win?(participant)
    if participant.total == 21
      puts "#{participant.name} win!"
      once_again?
    elsif participant.total > 21
      puts "#{participant.name} bust!"
      once_again?
    end
  end

  def player_turn
    puts "--"
    puts "#{player.name}'s turn."
    win?(player)
    while player.total < BLACKJACK_AMOUNT
      puts 'Hit or Stay? H - Hit; S - Stay'
      anwser = gets.chomp
      puts "--"
      if anwser.downcase == 'h' # Hit
        new_card = deck.cards.pop
        player.get_card(new_card)
        puts "Dealing card to #{player.name}: #{new_card}"
        puts "#{player.name}'s total is now: #{player.total}"
      elsif anwser.downcase == 's' # Stay 
        puts "You chose to stay at #{player.total}."
        break
      else      
        puts "You must enter H or S."
        next
      end
      win?(player)
    end
  end

  def dealer_turn
    puts "--"
    puts "Dealer's turn."
    win?(dealer)
    while dealer.total < DEALER_HIT_MIN
      new_card = deck.cards.pop
      dealer.get_card(new_card)
      puts "Dealing card to dealer: #{new_card}"
      puts "Dealer's total is now: #{dealer.total}"
      win?(dealer)
    end
    puts "Dealer stays at #{dealer.total}."
  end

  def once_again?
    puts 'Once again? Y - Yes; N - No.'
    anwser = gets.chomp
    puts "--"

    if anwser.downcase == 'y'
      start
    elsif anwser.downcase == 'n'
      puts 'Bye!'
      exit
    end  
  end

  def compare_hands
    if player.total > dealer.total
      puts "#{player.name} wins!"
    elsif player.total < dealer.total
      puts "#{dealer.name} wins!"
    else
      puts "It's a tie!"
    end
    once_again?
  end

  def reset_data
      deck = Deck.new
      player.cards = []
      dealer.cards = []
  end

  def start
    get_player_name if player.name == ''
    reset_data
    deal_cards
    show_hands
    player_turn
    dealer_turn
    compare_hands
  end
end

game = Game.new
game.start

