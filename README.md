# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# 参考にしたサイト

* zipで二つのリストを同時にeach文

https://qiita.com/s_tatsuki/items/a01e95812dbef85a3b9d




##２次元線形計画問題
一般には、2次元の線形計画問題は以下のように表せます。

```math
\min\qquad c_1x_1 + c_2x_2 \\
s.t.\qquad a_{i1}x_1 + a_{i2}x_2 \geq a_{i0} \\
```

s.t.とはsubject toのことで、これを満たすような、$\min {c_1x_1 + c_2x_2}$ を求める問題となります。

$a_{i1}x_1 + a_{i2}x_2 \geq a_{a0}$ を制約条件、これらの不等式が満たす領域を**実行可能領域**といいます。

実行可能領域を$(x_1,x_2)$平面に図示すると、実行可能領域が有界なら凸多角形になります。

目的関数が$cx+dy$のとき、傾きがx軸と平行になるようにx軸,y軸を回転すると、

```math
\begin{align}
cx+dy&=e \\
y&= -\frac{c}{d}x+\frac{e}{d}\\
\end{align}
```

となり、一般性を失うことなく次のような形の問題として考えることができます。


```math
\min \qquad y \\
s.t \qquad y \geq ax_1 + b
```

###凸関数g(x)を最小化する問題
一般の関数hにおいて、十分小さな$ε>0$に対して

```math
h(x')\leq h(x'+ε) \\
h(x')\leq h(x' - ε)
```


となっているとき、$x'$を**局所最小解**(local minimum)あるいは**局所最適解**と呼びます。

そして、特に凸関数に対しては上の不等式が成り立つときは、$x'$が全域での最小解(最適解)、すなわち**全域最小解**(global minimum)となる

凸性によって、任意の局所最小解は全域最小解となる。また、$g(x)$が狭義凸関数なら、高々１つの全域最小解が存在する。

$g(x)$に対して、$x_0$の最小解$x^* $の値を知ることなく、十分小さな$ε>0$に対して次のような局所的な条件を調べることによって、$x_0$と$x^*$の関係がわかる

```math
\left\{
\begin{array}{ll}
x^* \leq x_0 & (g(x_0+ε) \geq g(x_0)) \\
x^* \geq x_0 & (g(x_0-ε) \leq g(x_0)) \\
x^* = x_0 & (g(x_0+ε),g(x_0-ε) \geq g(x_0)
\end{array}
\right.
```


##縮小法
縮小法の基盤となる考え方は、**一定割合減らす**ということです。
一回の操作で残っているデータを$a (0\leq a \leq 1)$倍に減らすことができるとします。



目的の数までデータを減らすのにかかる最悪計算量は無限等比級数の和を考えて

```math
\begin{array}{ll}
\sum_{k=0}^{\infty} α^kn&=\frac{n}{1-α}\\
&=cn
\qquad (c\in \boldsymbol{R})

\end{array}
```
となるので、最悪計算量は$O(n)$となる


##最適解を求めるアルゴリズム
前書きが長くなりましたが、本題です。


前述の通り、今回は次のような問題を考えます。

```math
\min \qquad y \\
s.t \qquad y \geq ax_1 + b
```

前処理として、傾きが同じ複数の直線に関して、冗長なものは除いてしまうことができます。具体的には

```math
\qquad y\geq ax+b \\
\qquad y\geq ax+c \\
```

 b>cならば、$ y\geq ax+c$は冗長なので削除していい。

よって、$\\{a_i\\}$はすべて異なるものとして考えることとします

###Step 1.
n本の制約条件(直線)を2本ずつの組にする。
$x_{ij}$:=$l_i$と$l_j$の交点のx座標$\qquad$  ($l_i,l_j$:制約条件)
$m=\lfloor \frac{n}{2} \rfloor$個の交点ができる
計算量:$O(n)$

```python
#交点のx座標を返す
def solve_where_pair_cross(pair,lines):
    #y=ax+b,
    #y=cx+d より
    #x=(d-b)/(a-c)
    a=lines[pair[0]][0]
    b=lines[pair[0]][1]
    c=lines[pair[1]][0]
    d=lines[pair[1]][1]

    x=(d-b)/(a-c)
    return x
    

#２つの直線でペアを作ってline_pairsに格納する
def make_pairs(line_pairs,exist_lines_index,lines):
    line_pairs.clear()
    exist=False
    for i in exist_lines_index:
        if exist:
            exist=False
            two = i
            line_pairs.append((one,two))
        else:
            exist=True
            one = i
```
###Step 2.
$\\{x_{ij}\\}$の中央値$\lfloor m/2 \rfloor$番目を$x_0$とする.
計算量:$O(n)$・・・(※)

(※ 中央値を求めるときに、"ソートして、真ん中にあるのが中央値"としたくなりますが、ソートは$O(n\log n)$かかってしまいますので、**縮小法**で$O(n)で求めます. 詳細は省きます. )


```python
def solve_k(X,k):
  l = X[:]
  l.sort()
  return l[k]
```

```python
def solve_k(X,k):
    #本来100でやるが、100を大きく上回る直線数でやるとやかましいので。
    if len(X)>=10:
        
        #5個ずつのグループに分ける
        fives=[]
        cnt=0
        for x in X:
            if cnt%5==0:
                fives.append([x])
            else:
                fives[-1].append(x)
            cnt+=1

        #それぞれsort(サイズが小さいのでO(1))
        mids = []
        for f in fives:
            f.sort()
            #そのグループの中央値をmidsに格納
            if len(f)==5:
                mids.append(f[2])

        #中央値の中央値を求める(再帰)
        m=solve_k(mids,len(mids)//2)

        S_1=0
        S_2=0
        S_3=0
        smallers=[]
        equals=[]
        largers=[]
        for i in range(len(X)):
            if m>X[i]:
                smallers.append(X[i])
                S_1+=1
            elif m<X[i]:
                largers.append(X[i])
                S_3+=1
            else:
                equals.append(X[i])
                S_2+=1
        

        if S_1>k:
            ret = solve_k(smallers,k)
        elif S_1<=k<=(S_1+S_2):
            ret = m
        else:
            ret = solve_k(largers,k-S_1-S_2)
    
        return ret
    
    #whileに入らなかったら
    else:
        #X.sort()でやると、pythonの場合は参照渡しなのでmain内での順番も変わってしまう
        l = X[:]
        l.sort()
        return l[k]


def solve_a_plus_minus(mid,exist_lines_index,lines):
    maximums=[]
    maxim = 0
    for i in exist_lines_index:
        y=lines[i][0]*mid + lines[i][1]
        #print(y)
        if maxim < y:
            maxim=y
            maximums=[i]
        elif maxim==y:
            maximums.append(i)
        else:
            continue

    print("x={}における最大値をとる直線".format(mid))
    for i in maximums:
        show(lines[i])

    a_plus=max(maximums,key = lambda i:lines[i][0])
    a_minus=min(maximums,key = lambda i:lines[i][0])
    return (lines[a_plus][0],lines[a_minus][0])
        
def delete_lines(minus:bool,lines,x,line_pairs,exist_lines_index,x_zero):
    for xi,pair in zip(x,line_pairs):
        #2本の直線の傾き
        l1_slope=lines[pair[0]][0]
        l2_slope=lines[pair[1]][0]

        if minus and xi <= x_zero:
            if l1_slope > l2_slope:
                exist_lines_index.remove(pair[1])
            else:
                exist_lines_index.remove(pair[0])
        elif not minus and xi >= x_zero:
            if l1_slope < l2_slope:
                exist_lines_index.remove(pair[1])
            else:
                exist_lines_index.remove(pair[0])
        else:
            continue


```

###Step 3.
$x_0$でテストして、最適解の方向を調べます。

```math
\begin{array}{ll}
I &= \{i\:|\: a_ix_0 + b_i = f(x_0) \} \\
a^+ &= max\{ a_i\:|\:i\in I\} \\
a^- &= min\{ a_i\:|\:i\in I\} \\
\end{array}
```

```math
a^+ > 0　\Rightarrow x^* \leq x_0 \\
a^- < 0　\Rightarrow x^* \geq x_0 \\
```

```python 
def solve_a_plus_minus(mid,exist_lines_index,lines):
    maximums=[]
    maxim = 0
    for i in exist_lines_index:
        y=lines[i][0]*mid + lines[i][1]
        #print(y)
        if maxim < y:
            maxim=y
            maximums=[i]
        elif maxim==y:
            maximums.append(i)
        else:
            continue

    print("x={}における最大値をとる直線".format(mid))
    for i in maximums:
        show(lines[i])

    a_plus=max(maximums,key = lambda i:lines[i][0])
    a_minus=min(maximums,key = lambda i:lines[i][0])
    return (lines[a_plus][0],lines[a_minus][0])
   
# ばしっと最適解が求まる
if a_plus*a_minus < 0:
    break
# 縮小!!! n/4本の直線を冗長と断定!!
else:
    print("a_plus:", a_plus, "a_minus:", a_minus)
    if a_plus > 0:
        # ans_x > mid
        minus = False
        # print(a_plus,a_minus)

        delete_lines(minus, lines, x, line_pairs,exist_lines_index,mid)

    else:
        # ans_x > mid
        minus = True

        delete_lines(minus, lines, x, line_pairs,exist_lines_index,mid)
        pass

```
###Step4
冗長な直線を削除します。
$x^* \leq x_0$ならば
$\quad x_{ij} \geq x_0$となる$x_{ij}$に対して
$\qquad a_i>a_j$なら$l_i$は冗長
$\qquad a_i<a_j$なら$l_j$は冗長

$x^* \geq x_0$ならば
$\quad x_{ij} \leq x_0$となる$x_{ij}$に対して
$\qquad a_i< a_j$なら$l_i$は冗長
$\qquad a_i>a_j$なら$l_j$は冗長

**このステップで何本の直線を削除したでしょうか**
$\quad\lceil\frac{m}{2}\rceil$本、ですね。
$\quad m=\lfloor \frac{n}{2} \rfloor$だったので、1フェイズで$\frac{3}{4}$倍に減らすことができます。



**Step1~4を繰り返す**
上記の操作を直線が2本になるまで繰り返します

ということは、計算量はどうなるんでしたっけ？
そうです。

```math
\begin{array}{ll}
\sum_{k=0}^{\infty} α^kn&=\frac{n}{1-α}\\
&=cn
\qquad (c\in \boldsymbol{R})

\end{array}
```
$O(n)$で求まるのでしたね。
ということで全体の計算量もO(n)です
これで最適解が$O(n)$で求まりました。

##図でみてみようのコーナー
このコーナーは冗長だと判断された直線が消されていく様子を見てみようじゃないかというコーナーです。
**初期状態**
![スクリーンショット 2019-05-15 0.21.27.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/a73fdb9c-15d6-4f44-97fb-88570a0beaab.png)
**1回削除**
![スクリーンショット 2019-05-15 0.21.34.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/5b9afaf0-1845-7a32-a15c-7b73da20bea0.png)
**2回削除**
![スクリーンショット 2019-05-15 0.21.40.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/98fdd0d9-760c-ff77-7eee-b07866ffa4a0.png)
**3回削除**
![スクリーンショット 2019-05-15 0.21.45.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/6d8e3a51-859c-a551-31bd-873f88980da0.png)
**4回削除**
![スクリーンショット 2019-05-15 0.21.49.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/7d413e89-7d86-7c9d-2f94-efd7fcf49266.png)
**丸がついているところが最適解です**
![スクリーンショット 2019-05-15 0.21.49のコピー.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/285348/0cfaa109-dd9d-10b3-8904-bda1ef7886f9.png)



##ソースコード
すべての操作をまとめたコードがこちらです

```python
def plotting(lines,exist_lines_index):
    import matplotlib.pyplot as plt
    import numpy as np

    x=np.linspace(-30,30)
    maxim =0
    minim =float("inf")
    for i in range(len(lines)):
        line=lines[i]
        y=line[0]*x + line[1]
        lab = "l"+str(i)
        if i in exist_lines_index:    
            plt.plot(x,y,label=lab)
        else:
            plt.plot(x,y,label=lab,linestyle="dotted")

    x_axis=[[0,0],[100,-100]]
    y_axis=[[100,-100],[0,0]]
    plt.plot(x_axis[0],x_axis[1],color="black",linewidth=2)
    plt.plot(y_axis[0],y_axis[1],color="black",linewidth=2)
    plt.grid()
    plt.legend()
    plt.xlim(-30,30)
    plt.ylim(-10,30)
    plt.show()

def float_(x:str):
    if "/" in x:
        index = x.index("/")
        x = float(x[:index])/float(x[index+1:])
    return float(x)

def show(line):
    if line[1]>0:
        print(" y={}x+{}".format(line[0],line[1]))
    elif line[1]<0:
        print(" y={}x-{}".format(line[0],abs(line[1])))
    else:
        print(" y={}x".format(line[0]))

#２つの直線でペアを作ってline_pairsに格納する
def make_pairs(line_pairs,exist_lines_index,lines):
    line_pairs.clear()
    exist=False
    for i in exist_lines_index:
        if exist:
            exist=False
            two = i
            line_pairs.append((one,two))
        else:
            exist=True
            one = i
        

#交点のx座標を返す
def solve_where_pair_cross(pair,lines):
    #y=ax+b,
    #y=cx+d より
    #x=(d-b)/(a-c)
    a=lines[pair[0]][0]
    b=lines[pair[0]][1]
    c=lines[pair[1]][0]
    d=lines[pair[1]][1]

    x=(d-b)/(a-c)
    return x
    
def solve_k(X,k):
    #本来100でやるが、100を大きく上回る直線数でやるとやかましいので。
    if len(X)>=10:
        
        #5個ずつのグループに分ける
        fives=[]
        cnt=0
        for x in X:
            if cnt%5==0:
                fives.append([x])
            else:
                fives[-1].append(x)
            cnt+=1

        #それぞれsort(サイズが小さいのでO(1))
        mids = []
        for f in fives:
            f.sort()
            #そのグループの中央値をmidsに格納
            if len(f)==5:
                mids.append(f[2])

        #中央値の中央値を求める(再帰)
        m=solve_k(mids,len(mids)//2)

        S_1=0
        S_2=0
        S_3=0
        smallers=[]
        equals=[]
        largers=[]
        for i in range(len(X)):
            if m>X[i]:
                smallers.append(X[i])
                S_1+=1
            elif m<X[i]:
                largers.append(X[i])
                S_3+=1
            else:
                equals.append(X[i])
                S_2+=1
        

        if S_1>k:
            ret = solve_k(smallers,k)
        elif S_1<=k<=(S_1+S_2):
            ret = m
        else:
            ret = solve_k(largers,k-S_1-S_2)
    
        return ret
    
    #whileに入らなかったら
    else:
        #X.sort()でやると、pythonの場合は参照渡しなのでmain内での順番も変わってしまう
        l = X[:]
        l.sort()
        return l[k]


def solve_a_plus_minus(mid,exist_lines_index,lines):
    maximums=[]
    maxim = 0
    for i in exist_lines_index:
        y=lines[i][0]*mid + lines[i][1]
        #print(y)
        if maxim < y:
            maxim=y
            maximums=[i]
        elif maxim==y:
            maximums.append(i)
        else:
            continue

    print("x={}における最大値をとる直線".format(mid))
    for i in maximums:
        show(lines[i])

    a_plus=max(maximums,key = lambda i:lines[i][0])
    a_minus=min(maximums,key = lambda i:lines[i][0])
    return (lines[a_plus][0],lines[a_minus][0])
        
def delete_lines(minus:bool,lines,x,line_pairs,exist_lines_index,x_zero):
    for xi,pair in zip(x,line_pairs):
        #2本の直線の傾き
        l1_slope=lines[pair[0]][0]
        l2_slope=lines[pair[1]][0]

        if minus and xi <= x_zero:
            if l1_slope > l2_slope:
                exist_lines_index.remove(pair[1])
            else:
                exist_lines_index.remove(pair[0])
        elif not minus and xi >= x_zero:
            if l1_slope < l2_slope:
                exist_lines_index.remove(pair[1])
            else:
                exist_lines_index.remove(pair[0])
        else:
            continue


def main():
    import sys
    input=sys.stdin.readline
    
    #直線の数
    N = int(input())
    #傾きと切片の入力
    lines=[list(map(float_,input().split())) for _ in range(N)]
    
    print("直線を表示します")
    for line in lines:
        show(line)
    exist_lines_index=set([i for i in range(N)])

    #whileを使うときは無限ループで神戸県警に捕まらないように
    line_pairs=[]
    cnt=1
    while len(exist_lines_index)>2:
        print()
        #print(exist_lines_index)
        print("phase{}".format(cnt))
        cnt+=1
        make_pairs(line_pairs,exist_lines_index,lines)
        print("ペア(添字):",line_pairs)
        plotting(lines,exist_lines_index)

        x=[]
        for pair in line_pairs:
            x.append(solve_where_pair_cross(pair,lines))
        
        #交点のx座標の中央値
        mid = solve_k(x,len(x)//2)
        print("2本ずつのペアの交点x座標:",x)
        print("↑の中央値:",mid)



        #最適解が右にあるか左にあるかを判断
        a_plus,a_minus= solve_a_plus_minus(mid,exist_lines_index,lines)
        
    
        #ばしっと最適解が求まる
        if a_plus*a_minus<0:
            break
        #縮小!!! n/4本の直線を冗長と断定!!
        else:
            print("a_plus:",a_plus,"a_minus:",a_minus)
            if a_plus>0:
                #ans_x > mid
                minus = False
                #print(a_plus,a_minus)
                
                delete_lines(minus,lines,x,line_pairs,exist_lines_index,mid)
                    
            else:
                #ans_x > mid 
                minus = True

                delete_lines(minus,lines,x,line_pairs,exist_lines_index,mid)
                pass

    print("\n残った2本の直線")
    for i in exist_lines_index:
        show(lines[i])
    
    ans_line_1,ans_line_2 = exist_lines_index
    x=solve_where_pair_cross([ans_line_1,ans_line_2],lines)
    y=lines[ans_line_1][0]*x+lines[ans_line_1][1]
    
    print("最適解の座標(x,y)=",(x,y))

    plotting(lines,exist_lines_index)
    
if __name__ == '__main__':
    main()
```

##実行結果
必要に応じてprintしてるので貼り付けて置きますね。

```
McDonalds:*** ***$ python LP2D.py  < input_lines_2.txt 
直線を表示します
 y=-3.0x+15.0
 y=-0.6x+15.0
 y=-2.0x+16.0
 y=2.0x-5.0
 y=-0.8x+13.0
 y=1.0x+4.0
 y=-0.2x+13.0
 y=0.5x+5.0

phase1
ペア(添字): [(0, 1), (2, 3), (4, 5), (6, 7)]
2本ずつのペアの交点x座標: [-0.0, 5.25, 5.0, 11.428571428571429]
↑の中央値: 5.25
x=5.25における最大値をとる直線
 y=-0.2x+13.0
a_plus: -0.2 a_minus: -0.2

phase2
ペア(添字): [(1, 3), (5, 6)]
2本ずつのペアの交点x座標: [7.692307692307692, 7.5]
↑の中央値: 7.692307692307692
x=7.692307692307692における最大値をとる直線
 y=1.0x+4.0
a_plus: 1.0 a_minus: 1.0

phase3
ペア(添字): [(1, 5), (6, 7)]
2本ずつのペアの交点x座標: [6.875, 11.428571428571429]
↑の中央値: 11.428571428571429
x=11.428571428571429における最大値をとる直線
 y=1.0x+4.0
a_plus: 1.0 a_minus: 1.0

phase4
ペア(添字): [(1, 5)]
2本ずつのペアの交点x座標: [6.875]
↑の中央値: 6.875
x=6.875における最大値をとる直線
 y=-0.2x+13.0
a_plus: -0.2 a_minus: -0.2

残った2本の直線
 y=1.0x+4.0
 y=-0.2x+13.0
最適解の座標(x,y)= (7.5, 11.5)
```
