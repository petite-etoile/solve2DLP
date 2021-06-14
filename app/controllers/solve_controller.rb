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

        srand(0)
        @lines = []
        @line_num.times do 
            line = Line.new(rand(-10..10), rand(-10..10))
            @lines.append(line)
        end
        puts "lines#{@lines}"

        # solve()

        #
        # setを使うことによるO(logN)の落とし方
        # ⬇︎
        # delete -> setを使う/一番うしろに送る
        #
    end

    def solve
        #
        # ここに傾き0の直線に対する処理が入る
        #

        @exist_lines_indices = [*0...@line_num].to_set #まだ削除されていない直線の添字の集合
        puts "exist#{@exist_lines_indices}"
        debug_flag = true
        loop_cnt = 0
        while @exist_lines_indices.size() > 2 and debug_flag do 
            puts "phase: #{loop_cnt}"
            puts @exist_lines_indices
            line_pairs = make_line_pairs() #2つ一組にする
            
            line_pairs.each do |pair|
                puts ""
                pair.show()
            end

            #それぞれの直線ペアの交点のx座標を求める
            intersection_x_list = []
            line_pairs.each do |pair|
                intersection_x_list.append(get_intersection_x(pair))
            end
            puts "交点のx座標 #{intersection_x_list}"

            #交点のx座標の中央値を求める
            median_x = get_median(intersection_x_list)

            #直線ペアの中でmedian_xで交わる直線のうち, 最大,最小の傾きを求める
















            
            
            debug_flag = false # for debug
        end
    end

    #まだ削除されてない直線を2つ1組にする
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

    #交点のx座標を返す
    def get_intersection_x(line_pair)
        if(not line_pair.is_a?(LinePair))
            raise RuntimeError, "get_intersection_x関数の引数はLinePairクラスであることを期待されます"
        end

        y_intercept1 = line_pair.line1.y_intercept
        y_intercept2 = line_pair.line2.y_intercept
        slope1 = line_pair.line1.slope
        slope2 = line_pair.line2.slope
        return (y_intercept2 - y_intercept1) / (slope1 - slope2)
    end

    def get_median(x_list)
        #5個ずつのグループに分ける
        groups = []
        x_list.each_with_index do |x, idx|
            if(idx%5==0)
                groups.append([x])
            else
                groups[-1].append(x)
            end
        end

        #各グループの中央値を求める
        medians = []
        groups.each do |group|
            puts group
            group.sort!()
            puts group
            if(group.size == 5) 
                medians.append(group[2])
            end
        end



    
        
    end



    


end
