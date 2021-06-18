class SolveController < ApplicationController
    require "set"
    layout "solve"
    #
    # このプログラム上での, 昇順ソートされた配列Aの median,中央値は, A[ ⌊ |A| / 2 ⌋ ] (0-indexed) とする
    #

    class Line
        attr_accessor :slope, :y_intercept, :index, :id 
        @@line_counter = 0
        def initialize(s,y,i)
            @slope = s
            @y_intercept = y
            @index = i
            @id = @@line_counter
            @@line_counter += 1
        end

        def show()
            puts "y=#{@slope}x+#{@y_intercept}   id:#{@id}"
        end

        def val_at(x)
            return @slope * x + @y_intercept
        end
    end

    class LinePair
        attr_accessor :line1, :line2

        def initialize(l1, l2)
            @line1 = l1
            @line2 = l2
        end

        def show()
            puts "{"
            print "line1: "
            @line1.show()
            print "line2: "
            @line2.show()
            puts "}"
        end
    end

    

    def top
        puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nv"
        @data_for_plot = []
        @colors_for_plot = []
        @@TAB = "    "

        if(request.post?)
            puts "POST"
            puts params[:"2dlp_text"]

            
            if(params[:"2dlp_file"])
                input_string = params[:"2dlp_file"].read
            else
                input_string = params[:"2dlp_text"]
            end
            valid_input = input(input_string.split("\n"))
            @default_form_text = input_string


            if(valid_input)
                @messages = ["入力された問題", "#{@@TAB}min y", "#{@@TAB}s.t."]
                add_LP_message()
            else
                @messages = ["入力形式が正しくありません"]
                return 
            end
        else
            @default_form_text = "ここに入力"
            sample_input()
            @messages = ["サンプル", "#{@@TAB}min y", "#{@@TAB}s.t."]
            add_LP_message()
            
            puts "GET"
        end

        @@line_counter = 0
        
        


        add_plot()

        solve()

        add_plot()

    end

    def add_plot()
        #
        # どこからどこまで描画するかは, [交点の中の最小-1, 交点の中の最大+1]
        #


        @Left_x = -10
        @Right_x = 10

        lines_for_plot = []
        colors = []

        #
        # ここもあとでかわる
        # line_indicesを使う
        #
        @lines.each_with_index do |line, idx|
            if idx < @exist_line_num
                print "exist  "
                line.show()
                color = "#000000"
            else
                print "removed  "
                line.show()
                color = "DDDDDD"
            end
            lines_for_plot.append({data:[[@Left_x, line.val_at(@Left_x)], [@Right_x, line.val_at(@Right_x)]]})
            colors.append(color)
        end
        @data_for_plot.append(lines_for_plot)
        @colors_for_plot.append(colors)
    end

    # 入力を読んで, 解析
    def input(arr)
        begin
            @line_num = arr[0].to_i
            puts @line_num
            @exist_line_num = @line_num

            if(@line_num <= 1)
                raise RuntimeError, "直線の数は2本以上"
            end

            @lines = []
            (1..@line_num).each do |idx|
                p arr[idx].split(" ")
                slope, y_intercept = arr[idx].split(" ").map(&:to_f)
                p [slope, y_intercept]
                @lines.append(Line.new(slope, y_intercept, idx-1))
            end
            return true
        rescue => exception
            puts exception
            return false
        end

    end

    # サンプルの処理(GETのときのみ)
    def sample_input()
        @line_num = 10 #直線の数
        
        @exist_line_num = @line_num #未削除の直線の数

        srand(0)
        @lines = [] #@exist_line_num番目以前は未削除, それより後ろは削除済とする
        (0...@line_num).each do |idx|
            line = Line.new(rand(-10..10), rand(-10..10), idx)
            @lines.append(line)
        end
    end

    # 入力されたLPの表示
    def add_LP_message
        @lines.each do |line|
            if(line.y_intercept.positive?)
                @messages.append("#{@@TAB}#{@@TAB}y ≥ #{line.slope}x +#{line.y_intercept}")
            elsif(line.y_intercept.negative?)
                @messages.append("#{@@TAB}#{@@TAB}y ≥ #{line.slope}x #{line.y_intercept}")
            else
                @messages.append("#{@@TAB}#{@@TAB}y ≥ #{line.slope}x ")
            end
        end
    end

    # 2次元LPを
    def solve

        debug_flag = true
        loop_cnt = 0
        while @exist_line_num > 2 and debug_flag do 
            puts "-----------------\nphase: #{loop_cnt}"
            puts @exist_line_num
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
            x_median = get_kth_element(intersection_x_list, intersection_x_list.size()/2)
            puts "#{x_median} == #{intersection_x_list.sort()[intersection_x_list.size()/2]}"
            puts x_median == intersection_x_list.sort()[intersection_x_list.size()/2]
            if(x_median != intersection_x_list.sort()[intersection_x_list.size()/2])
                raise RuntimeError, "中央値を求めるターンで期待されたものが得られてません"
            end

            #最適解がx_medianより右にあるのか左にあるのか, あるいはx_medianが最適解なのか求める
            opt_direction = get_opt_direction(x_median)
            p opt_direction

            if(opt_direction == "OPT")
                break
            end
            delete_lines( opt_direction,  intersection_x_list, line_pairs, x_median)
            

            @lines.each_with_index do |line, idx|
                puts "#{idx} #{line.index}"
                
            end
            

            add_plot()
            loop_cnt += 1
            
            # debug_flag = false # for debug
        end
    end



    #まだ削除されてない直線を2つ1組にする
    def make_line_pairs
        line_pairs = []
        flag = false
        (0...@exist_line_num).each do |idx|
            #
            # 傾きが等しい直線は, 切片の小さい方を削除する(line_pairsには入れない)
            #
            if(flag)
                flag = false
                @line2 = @lines[idx]
                line_pairs.append(LinePair.new(@line1, @line2))
            else
                flag = true
                @line1 = @lines[idx]
            end
        end
        return line_pairs
    end

    #交点のx座標を返す
    def get_intersection_x(line_pair)
        unless(line_pair.is_a?(LinePair))
            raise RuntimeError, "get_intersection_x関数の引数はLinePairクラスであることを期待されます"
        end

        y_intercept1 = line_pair.line1.y_intercept
        y_intercept2 = line_pair.line2.y_intercept
        slope1 = line_pair.line1.slope
        slope2 = line_pair.line2.slope
        return (y_intercept2 - y_intercept1).to_f / (slope1 - slope2)
    end

    #x_listの中でk番目の要素を返す
    def get_kth_element(x_list, k)
        if( x_list.size() < 10)
            return x_list.sort()[k]
        end
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
            group.sort!()
            if(group.size == 5) 
                medians.append(group[2])
            end
        end

        median_of_medians = get_kth_element(medians, medians.size() / 2) #{各グループの中央値}の中央値

        smallers = [] #各グループの中央値の中央値より小さい
        equals = [] #各グループの中央値の中央値と等しい
        largers = [] #各グループの中央値の中央値より大きい

        x_list.each do |x|
            if(x < median_of_medians)
                smallers.append(x)
            elsif ( x == median_of_medians)
                equals.append(x)
            else
                largers.append(x)
            end
        end

        if( k < smallers.size() ) # x_listのk番目は, smallersに含まれている
            return get_kth_element( smallers, k) # smallersのk番目
        elsif ( k <= smallers.size() + equals.size()) # x_listのk番目は, {各グループの中央値}の中央値と等しい
            return median_of_medians
        else #x_listのk番目は, largersに含まれている
            return get_kth_element( largers, k - smallers.size() - equals.size() )
        end
    end

    #最適解がx_medianより右にあるのか左にあるのか, あるいはx_medianが最適解なのかを返す
    def get_opt_direction(x_median)
        #
        # まず, 削除されてない直線のうち, x_medianでの値が最大な直線の中の, 傾きの最大と最小を求める
        # 例) 
        #     x_median = 1
        #     直線1: y= x+1
        #     直線2: y=3x-1
        #     直線3: y=-x-1
        #
        #     x=1での値はそれぞれ, 2,2,0である
        #     最大値である2をとる直線1,直線2の中で傾きの最大,最小はそれぞれ 3,1である
        #

        unless(x_median.is_a?(Float))
            p "x_median:#{x_median}"
            raise RuntimeError, "x_medianはFloat型であることが期待されます"
        end
        y_max = -Float::INFINITY 
        maximum_indices = [] #最大値をとる直線の添え字リスト
    
        (0...@exist_line_num).each do |idx|
            y = @lines[idx].val_at(x_median)
            if(y_max < y)
                y_max = y
                maximum_indices = [idx]
            elsif(y_max == y)
                maximum_indices.append(idx)
            end
        end

        slope_max_idx = maximum_indices.max{|a,b| @lines[a].slope <=>@lines[b].slope }
        slope_min_idx = maximum_indices.min{|a,b| @lines[a].slope <=>@lines[b].slope }
        slope_max = @lines[slope_max_idx].slope #傾きの最大
        slope_min = @lines[slope_min_idx].slope #傾きの最小

        p slope_max,slope_min 

        if(slope_max * slope_min <= 0) # x_medianが最適解 傾き0でもOK
            direction = "OPT"
        elsif(slope_min > 0) # x_medianより左に最適解
            direction = "LEFT"
        else # x_medianより右最適解
            direction = "RIGHT"
        end
        return direction
    end

    def delete_lines(opt_direction,  intersection_x_list, line_pairs, x_median)
        unless opt_direction.in?(["LEFT", "RIGHT"]) 
            raise RuntimeError, "opt_directionは \"LEFT\" \"RIGHT\"のいずれかであることが期待されます"
        end
        p opt_direction
        intersection_x_list.zip(line_pairs) do |x, line_pair|
            slope1 = line_pair.line1.slope
            slope2 = line_pair.line2.slope
            
            if(opt_direction == "LEFT" and x_median <= x) 
                # 最適解がx_medianより左にあるので, x_medianより右で交差する直線ペアのうち, 傾きの値が大きい方は消す
                if( slope1 > slope2)
                    delete_line(line_pair.line1)
                else
                    delete_line(line_pair.line2)
                end
            elsif(opt_direction == "RIGHT" and ( x <= x_median ))
                # 最適解がx_medianより右にあるので, x_medianより左で交差する直線ペアのうち, 傾きの値が小さい方は消す
                if( slope1 < slope2)
                    delete_line(line_pair.line1)
                else
                    delete_line(line_pair.line2)
                end
            end
        end
    end

    def delete_line(line)
        unless(line.is_a?(Line))
            raise RuntimeError, "lineはLine型であることが期待されます"
        end
        print "delete:"
        line.show()

        index1 = line.index
        index2 = @exist_line_num-1
        
        @lines[index1], @lines[index2] = @lines[index2], @lines[index1]
        @lines[index1].index, @lines[index2].index = @lines[index2].index, @lines[index1].index

        @exist_line_num -= 1
    end
end