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
            puts "#{form()}   id:#{@id}"
        end

        def val_at(x)
            return @slope * x + @y_intercept
        end

        def form()
            if(@y_intercept.positive?)
                return "y≥#{@slope}x+#{@y_intercept}"
            elsif(@y_intercept.negative?)
                return "y≥#{@slope}x#{@y_intercept}"
            else
                return "y≥#{@slope}x"
            end
        end
    end

    class Point
        attr_accessor :x, :y
        def initialize(x,y)
            @x = x
            @y = y
        end

        def show()
            puts "(#{@x}, #{@y})"
        end
    end

    class LinePair
        attr_accessor :line1, :line2, :intersection

        def initialize(l1, l2)
            @line1 = l1
            @line2 = l2
            @intersection = get_intersection()
        end

        def show()
            puts "{"
            print "line1: "
            @line1.show()
            print "line2: "
            @line2.show()
            puts "}"
        end

        private

        #交点の座標を返す
        def get_intersection()
            if(@line1.slope == @line2.slope)
                raise RuntimeError, "同じ傾きの直線をペアにすることはできません"
            end

            x = (@line2.y_intercept - @line1.y_intercept).to_f / (@line1.slope - @line2.slope)
            y = @line1.val_at(x)

            return Point.new(x,y)
        end

    end

    class PhaseInfo
        attr_accessor :ph_lines, :ph_exist_line_num, :ph_intersections
        @@min_x = -1 
        @@max_x = 1
        @@min_y = -1
        @@max_y = 1

        #
        # 交点がない場合は空の配列を渡す
        # オーバーロードさせてほしいなrubyさん
        #
        def initialize(lines, exist_line_num, line_pairs)
            @ph_lines = deepcopy(lines)
            @ph_exist_line_num = exist_line_num
            @ph_intersections = []
            
            line_pairs.each do |pair|
                @ph_intersections.append(pair.intersection)

                @@min_x = [@@min_x, pair.intersection.x - 1].min
                @@max_x = [@@max_x, pair.intersection.x + 1].max
                @@min_y = [@@min_y, pair.intersection.y - 1].min
                @@max_y = [@@max_y, pair.intersection.y + 1].max
            end

            @@min_x =  (@@min_x/10).to_i * 10
            @@max_x =  ((@@max_x+10)/10 - 1).to_i * 10
        end

        def deepcopy(obj)
            return Marshal.load(Marshal.dump(obj))    
        end

        def plot(data_for_plot, colors_for_plot)
            #
            # どこからどこまで描画するかは, [交点の中の最小-1, 交点の中の最大+1]
            #

            lines_for_plot = []
            colors = []

            @ph_lines.each_with_index do |line, idx|
                color = idx < @ph_exist_line_num ? "#000000" : "#DDDDDD"
                colors.append(color)

                # lines_for_plot.append({data:[[@@min_x, line.val_at(@@min_x)], [@@max_x, line.val_at(@@max_x)], name:line.form() ]})
                lines_for_plot.append({name:line.form() , data:[[@@min_x, line.val_at(@@min_x)], [@@max_x, line.val_at(@@max_x)]]})
            end
            data_for_plot.append(lines_for_plot)
            colors_for_plot.append(colors)
        end

        def self.min_y()
            return @@min_y
        end

        def self.max_y()
            return @@max_y
        end

        def self.min_x()
            return @@min_x
        end

        def self.max_x()
            return @@max_x
        end


    end


    def top
        @page = "top"
        puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nv"
        @data_for_plot = []
        @colors_for_plot = []
        @@TAB = "    "

        if(request.post?)
            puts "POST"
            puts "入力↓"
            puts params[:"2dlp_text"]
            puts ""

            
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
            sample_input()
            @messages = ["サンプル", "#{@@TAB}min y", "#{@@TAB}s.t."]
            add_LP_message()
            
            puts "GET"
        end

        @@line_counter  = 0
        @phase_info_list = [PhaseInfo.new(@lines, @exist_line_num, [])]
        
        
        
        
        solve()
        

        @phase_info_list.each do |phase_info|
            phase_info.plot(@data_for_plot, @colors_for_plot)
        end

        @min_y = PhaseInfo.min_y
        @max_y = PhaseInfo.max_y
        @min_x = PhaseInfo.min_x
        @max_x = PhaseInfo.max_x
        p "######{@min_y}, #{@max_y}"
        p "######{@min_x}, #{@max_x}"

    end

    # 入力を読んで, 解析
    def input(arr)
        begin
            @line_num = arr[0].to_i
            @exist_line_num = @line_num

            if(@line_num <= 1)
                raise RuntimeError, "直線の数は2本以上"
            end

            @lines = []
            (1..@line_num).each do |idx|
                slope, y_intercept = arr[idx].split(" ").map(&:to_f)
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

        file = File.join(Rails.root, "public", "sample_in.txt")
        @default_form_text = File.read(file)
        input(@default_form_text.split("\n"))
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
                intersection_x_list.append(pair.intersection.x)
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

            if(opt_direction == "OPT")
                break
            end
            delete_lines( opt_direction,  intersection_x_list, line_pairs, x_median)
            

            @phase_info_list.append(PhaseInfo.new(@lines, @exist_line_num, line_pairs))
            loop_cnt += 1
            
            # debug_flag = false # for debug
        end
    end

    #まだ削除されてない直線を2つ1組にする
    def make_line_pairs
        line_pairs = []
        flag = false
        waste_lines = []
        (0...@exist_line_num).each do |idx|
            #
            # 傾きが等しい直線は, 切片の小さい方を削除する(line_pairsには入れない)
            #
            if(flag)
                @line2 = @lines[idx]
                if(@line1.slope == @line2.slope)
                    if(@line1.y_intercept < @line2.y_intercept)
                        waste_lines.append(@line1)
                        @line1 = @line2
                    else
                        waste_lines.append(@line2)
                    end
                    next
                end
                flag = false
                line_pairs.append(LinePair.new(@line1, @line2))
            else
                flag = true
                @line1 = @lines[idx]
            end
        end

        waste_lines.each do |line|
            delete_line(line)
        end
        puts "size:#{line_pairs.size()}"
        return line_pairs
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

        p "#{x_median}でy = #{y_max}をとる直線のうちの傾き最大, 最小: #{slope_max}, #{slope_min}"

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
        p "最適解は, #{x_median}より#{opt_direction == "LEFT" ? "左" : "右"}"
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

        # どの直線が残っていて, どれが削除済みか出力
        @lines.each_with_index do |line, idx|
            print idx < @exist_line_num ? "exist  " : "removed  "
            line.show()
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

    def about
        @page = "about"
    end

    def howto
        @page = "howto"
    end
end