require 'colorize'
class Game
    def initialize(human, computer)
        @human = human
        @computer = computer
        @guesses = Array.new(12)
        @guess_counter = 0
    end

    def setup_board()
        @guesses = @guesses.map do |guess|
            guess = ". . . ."
        end
    end

    def print_board()
        puts "    X X X X"
        puts "----------"
        @guesses.each_with_index do |guess, index|
            if(index < 9)
                puts " #{index + 1}: #{guess}"
            else
                puts "#{index + 1}: #{guess}"    
            end
        end
    end

    def get_valid_guess()
        guess = 0
        while(!got_valid_guess(guess)) do
            puts "What is your guess? (Enter a 4 digit number between 1111 and 6666, or q to quit)"
            guess = gets.chomp
            if(guess == "q")
                break
            else
                guess = guess.to_i
            end
        end
        return guess
    end
    
    def calculate_feedback(guess)
        feedback = [0, 0]
        temp = Array.new(4)
        
        @computer.answer.each_with_index do |answer_num, index|
            if(answer_num == guess[index])
                feedback[0] += 1
            else
                temp[index] = answer_num
            end
        end
        guess.each_with_index do |digit, index|
            if(digit && temp.include?(digit))
                feedback[1] += 1
                temp[temp.index(digit)] = nil
            end
        end
        return feedback
    end

    def game_loop()
        setup_board
        finished = false

        while(!finished && @guess_counter < 12) do
            guess = get_valid_guess

            if(guess == "q")
                break
            end

            guess = convert_to_array(guess)
            
            if(guess == @computer.answer)
                puts "Well done, the answer was indeed #{@computer.answer}."
                finished = true
            else
                feedback = calculate_feedback(guess)
                puts "Correct digits and in the right place: #{feedback[0].to_s.green}"
                puts "Correct digits but in the wrong place: #{feedback[1].to_s.yellow}"

                @guesses[@guess_counter] = "#{guess[0]} #{guess[1]} #{guess[2]} #{guess[3]}   #{feedback[0].to_s.green} #{feedback[1].to_s.yellow}"
                @guess_counter += 1

                print_board
            end
        end
        if(@guess_counter >= 12 || guess == "q")
            puts "The answer was #{@computer.answer}."
        end
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
        # p @answer
    end

    def create_answer()
        arr = Array.new(4)
        prng = Random.new
        arr.map {|item| item = prng.rand(1..6)}
        # arr = [1, 1, 2, 3]
    end
end

game = Game.new(Human.new, Computer.new)
game.game_loop