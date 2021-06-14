class SolveController < ApplicationController
    require "set"
    layout "solve"

    class Line
        attr_accessor :slope, :y_intercept
        
        def initialize(s,y)
        @slope = s
        @y_intercept = y
        end

        def show()
        puts "y=#{@slope}x+#{@y_intercept}"
        end
    end

    class LinePair
        attr_accessor :line1, :line2

        def initialize(l1, l2)
        @line1 = l1
        @line2 = l2
        end

        def show()
        print "line1: "
        @line1.show()
        print "line2: "
        @line2.show()
        end
    end

    def top
        @data = []
        
        #直線の数
        @line_num = 5

        @lines = []
        (0...@line_num).each do |idx|
        line = Line.new(idx,idx)
        @lines.append(line)
        end
        puts "lines#{@lines}"

        solve()
        #delete -> setを使う/一番うしろに送る
    end

    def solve
        @exist_lines_indices = [*0...@line_num].to_set #まだ削除されていない直線の添字の集合
        puts "exist#{@exist_lines_indices}"
        flag = true
        while @exist_lines_indices.size() > 2 and flag do 
        puts @exist_lines_indices
        line_pairs = make_line_pairs() #2つ一組にする
        puts line_pairs
        flag = false
        end
    end

    def make_line_pairs
        line_pairs = []
        flag = false
        @exist_lines_indices.each do |idx|
        if(flag)
            flag = false
            @line2 = @lines[idx]
            line_pairs.append(LinePair.new(@line1, @line2))
            line_pairs[-1].show()
        else
            flag = true
            @line1 = @lines[idx]
        end
        end
        return line_pairs
    end

    #   def 


end
