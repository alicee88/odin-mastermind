require 'colorize'
class Game
    def initialize(human, computer)
        @human = human
        @computer = computer
        @guesses = Array.new(12)
        @guess_counter = 0
        @guesser = human
        @coder = computer
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
    
    def choose_player()
        puts "Who chooses the code? (enter 'me' or 'you')"
        player_chosen = false;
        while(!player_chosen) do
            input = gets.chomp
            if(input == "me" || input == "ME" || input == "Me")
                player_chosen = true
                @guesser = @computer
                @coder = @human
                @human.create_answer
            elsif(input == "you" || input == "YOU" || input == "You")
                player_chosen = true
                @guesser = @human
                @coder = @computer
            end
        end
        game_loop
    end

    def check_for_win(guess)
        if(guess == @coder.answer)
            @guesser.print_win_message(@coder.answer)
            return true
        end
        return false

    end

    def game_loop()
        setup_board
        finished = false

        while(!finished && @guess_counter < 12) do
            guess = @guesser.get_valid_guess(@guess_counter)
            puts "My guess: #{guess}"
            if(check_for_win(guess))
                finished = true
            else
                feedback = @computer.calculate_feedback(guess, @coder.answer)
                
                @guesses[@guess_counter] = "#{guess[0]} #{guess[1]} #{guess[2]} #{guess[3]}   #{feedback[0].to_s.green} #{feedback[1].to_s.yellow}"
                @guess_counter += 1
                @computer.prune_possible_guesses(guess, feedback)

                print_board
            end
            if(@guess_counter >= 12 || guess == "q")
                puts "The answer was #{@coder.answer}."
            end
        end
    end

    def human_guesses_gameloop()
        setup_board
        finished = false

        while(!finished && @guess_counter < 12) do
            guess = @human.get_valid_guess
            
            if(guess == @computer.answer)
                puts "Well done, the answer was indeed #{@computer.answer}."
                finished = true
            else
                feedback = @human.calculate_feedback(guess, @computer.answer)
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

    
   
end

class Player
    def got_valid_code(code)
        return code.digits.length == 4 && code <= 6666 && code >= 1111
    end

    def convert_to_array(int)
        return int.to_s.split('').map {|number| number.to_i}
    end

    def calculate_feedback(guess, answer)
        feedback = [0, 0]
        temp = Array.new(4)
        
        answer.each_with_index do |answer_num, index|
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

        puts "Correct digits and in the right place: #{feedback[0].to_s.green}"
        puts "Correct digits but in the wrong place: #{feedback[1].to_s.yellow}"
        return feedback
    end
end

class Human < Player
    attr_reader :answer

    def initialize()
        @answer = Array.new(4)
    end

    def create_answer()
        code = 0
        while(!got_valid_code(code))
            puts "Choose the code for me to guess (Enter a 4 digit number between 1111 and 6666, or q to quit)"
            code = gets.chomp
            if(code == "q")
                break
            else
                code = code.to_i
            end
        end
        @answer = convert_to_array(code)
        puts @answer
    end

    def get_valid_guess(guess_counter)
        guess = 0
        while(!got_valid_code(guess)) do
            puts "What is your guess? (Enter a 4 digit number between 1111 and 6666, or q to quit)"
            guess = gets.chomp
            if(guess == "q")
                return "q"
            else
                guess = guess.to_i
            end
        end
        guess = convert_to_array(guess)
        return guess
    end

    def print_win_message(answer)
        puts "Well done, the answer was indeed #{answer}."
    end
    
   
end

class Computer < Player
    attr_reader :answer

    def initialize()
        @answer = create_answer()
        @possible_solutions = create_solutions()
    end

    def create_answer()
        arr = Array.new(4)
        prng = Random.new
        arr.map {|item| item = prng.rand(1..6)}
    end

    def create_solutions()
        digits = [1, 2, 3, 4, 5, 6]
        return digits.repeated_permutation(4).to_a
    end

    def get_valid_guess(guess_counter)
        if(guess_counter == 0) 
            # 1st guess
            guess = [1, 1, 2, 2]
        else
            prng = Random.new
            random_guess = prng.rand(0..@possible_solutions.length-1)
            guess = @possible_solutions[random_guess]
        end
        @possible_solutions.delete(guess)
        return guess
    end

    def prune_possible_guesses(guess, feedback)
        @possible_solutions.each_with_index do |solution|
            if(calculate_feedback(guess, solution) == feedback)
                # puts "SOLUTION #{solution} HAS SAME FEEDBACK AS OUR GUESS SO KEEP"
            else
                @possible_solutions.delete(solution)
            end
        end
    end

    def print_win_message(answer)
        puts "I worked out the answer was #{answer}."
    end

end

game = Game.new(Human.new, Computer.new)
game.choose_player