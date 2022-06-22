require 'colorize'
class Game
    def initialize(human, computer)
        @human = human
        @computer = computer
    end

    def setup_board
        puts "    X X X X"
        puts "----------"
        puts "1:  . . . ."
        puts "2:  . . . ."
        puts "3:  . . . ."
        puts "4:  . . . ."
        puts "5:  . . . ."
        puts "6:  . . . ."
        puts "7:  . . . ."
        puts "8:  . . . ."
        puts "9:  . . . ."
        puts "10: . . . ."
        puts "11: . . . ."
        puts "12: . . . ."
    end

    def game_loop()
        setup_board
        guess = 0

        while(!got_valid_guess(guess)) do
            puts "What is your guess? (Enter a 4 digit number between 1111 and 6666)"
            guess = gets.chomp.to_i
        end

        puts "Got valid guess :)"
        puts "Compare your guess with my answer"
        guess = convert_to_array(guess)
        if(guess == @computer.answer)
            puts "YOU GOT IT RIGHT!"
        end
        p guess
    end 

    def got_valid_guess(guess)
        return guess.digits.length == 4 && guess <= 6666 && guess >= 1111
    end

    def convert_to_array(int)
        return int.to_s.split('').map {|number| number.to_i}
    end
   
end

class Player
end

class Human < Player
end

class Computer < Player
    attr_reader :answer

    def initialize()
        @answer = create_answer()
        p @answer
    end

    def create_answer()
        arr = Array.new(4)
        prng = Random.new
        arr.map {|item| item = prng.rand(1..6)}
        arr = [1, 2, 3, 4]
    end
end

game = Game.new(Human.new, Computer.new)
game.game_loop