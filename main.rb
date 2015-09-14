require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret'

helpers do
  def calculate_total(hand) # accepts a nested array ie. [[x,y],[x,y] ...]
    hand_values = hand.map { |element| element[1] }

    total = 0
    hand_values.each do |value|
      if value == "A"
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    # adjust for aces
    hand_values.select { |value| value == "A" }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def display_card(card) # ["suit", "value"]
    suit = case card[0]
      when "C" then "clubs"
      when "D" then "diamonds"
      when "S" then "spades"
      when "H" then "hearts"
    end

    value = case card[1]
      when "A" then "ace"
      when "J" then "jack"
      when "Q" then "queen"
      when "K" then "king"
      else card[1]
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card'>"
  end

end

before do
  @display_stay_or_bust = true
end

get "/" do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/new_player"
  end
end

get "/new_player" do
  erb :new_player
end

post "/new_player" do
  session[:player_name] = params[:player_name]

  if session[:player_name].size == 0
    @error = "Please enter a valid name!"
    erb :new_player
  else
    redirect "/game"
  end
end

get "/game" do

  # initialize the deck
  suits = %w(H D S C)
  face_values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  session[:deck] = suits.product(face_values).shuffle!

  # initialize deal and player hand
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop

  # show deck
  erb :game
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  @player_hand_value = calculate_total(session[:player_hand])

  if @player_hand_value > 21
    @error = "Sorry, you busted!"
    @display_stay_or_bust = false
  elsif @player_hand_value == 21
    @success = "Congratulations, you've got 21!"
    @display_stay_or_bust = false
  end

  erb :game
end

post '/game/player/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  @display_stay_or_bust = false
  player_hand = calculate_total(session[:player_hand])
  dealer_hand = calculate_total(session[:dealer_hand])

  if dealer_hand == 21
    @error = "Sorry, Dealer hits BlackJack... You lose!"
  elsif dealer_hand > 21
    @success = "Dealer busts... You win!"
  elsif dealer_hand < 17
    @display_dealer_hit = true
  else
    if dealer_hand > player_hand
      @error = "Dealer has a better hand... You lose!"
    elsif dealer_hand < player_hand
      @success = "Your hand beats the Dealer... you win!"
    else
      @success = "Its a tie!"
    end
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect '/game/dealer'
end
