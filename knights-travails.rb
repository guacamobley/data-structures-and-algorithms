module Travails
  class Move
    #record the spot you've moved to and the spot you moved from
    attr_accessor :position,:previous_position

    def initialize(position,previous_position=nil)
      if position.class == :Move
        @position = position.position
        @previous_position = position.previous_position
      else
        @position = position
        @previous_position = previous_position
      end
    end

    def to_s
      @position.to_s
    end

    def start?
      return true if previous_position == nil
      return false
    end

    def plus offset
      xPos,yPos = self.position
      xOff,yOff = offset
      return Move.new([xPos+xOff,yPos+yOff],self)
    end

    def self.unroll_path(move)
      #given a final move, get the path from the oldest move to this final move
      path = []
      path.unshift(move.position)
      until move.start?
        move = move.previous_position
        path.unshift(move.position)
      end
      return path
    end

  end

  class Knight
    attr_accessor :board, :position

    MOVES = [ [1,2],
              [1,-2],
              [-1,2],
              [-1,-2],
              [2,1],
              [2,-1],
              [-2,1],
              [-2,-1]]

    def initialize board, position=Move.new([1,1])
      @board = board
      @position = position
      @moves = next_moves(position)
    end

    def knight_moves start=@position, finish
      #find the shorted path from start to finish.
      #first check to see if you're there already
      #then check each move from the start
      #then check each move from that place
      #once you've found the finish, rewind the search back to the start

      return [finish] if start == finish
      startMove = Move.new(start)

      path = []
      queue = [startMove]
      until queue.empty?
        node = queue.pop
        if node.position == finish
          print_path(Move.unroll_path(node))
          return true
        end
        next_moves(node).each{|node|
          queue.unshift(node)
        }
      end
    end

    def next_moves start=@position
      start = Move.new(start) if start.class == :Array
      moveList = []
      MOVES.each{|move|
        newMove = start.plus(move)
        moveList << newMove if legal_move?(newMove)
      }
      return moveList
    end
      #return an array of all possible moves a knight could make

    def legal_move? move
      return board.include? move.position
    end

    def print_path moves
      if moves.length == 1
        puts "You made it in 1 move! Here's your path: "
      else
        puts "You made it in #{moves.length} moves! Here's your path:"
      end
      moves.each{|move|
        print move
        print "\n"
      }
    end


  end




  class Board
    attr_accessor :squares

    def initialize size
      @squares = []
      1.upto(size){|x|
        1.upto(size){|y|
          @squares << [x,y]
        }
      }
    end

    def include? square
      return squares.include?(square)
    end

    def random_square
      return @squares.sample
    end
  end
  board = Board.new(8)
  knight = Knight.new(board)
  knight.knight_moves [1,1],[5,5]
end