// -----------------
// Cover
// -----------------
#set page(
  margin: (top: 22mm, bottom: 22mm, left: 18mm, right: 18mm),
  columns: 1,
  background: none,
  numbering: none,
)

#place(center, dy: 80mm)[
  #set text(size: 22pt, weight: "bold")
  #align(center)[Sound Analysis and Processing Notes]
]

#place(bottom + center, dy: -10mm)[
  #set text(size: 12pt, weight: "regular")
  #align(center)[基于米兰理工大学（Politecnico di Milano）\ 2025 Fall《Sound Analysis and Processing》课程]

  #v(0.8em)
  #set text(size: 11pt)
  #align(center)[作者：#link("https://github.com/worldedge1933/")[\@worldedge1933]]

  #v(0.6em)
  #align(center)[2026-01-03]
]


#pagebreak()

// -----------------
// Table of contents
// -----------------
#set page(
  margin: (top: 22mm, bottom: 22mm, left: 18mm, right: 18mm),
  columns: 1,
  background: none,
  numbering: none,
)

#set text(size: 18pt, weight: "bold")
#align(center)[目录]

#v(1.2em)
#set text(size: 11pt, weight: "regular")
#show outline.entry.where(level: 1): set block(above: 2em, below: 1.2em)
#outline(depth: 2)

#pagebreak()

// -----------------
// Main document
// -----------------
#set page(
  margin: (top: 18mm, bottom: 18mm, left: 10mm, right: 10mm),
  columns: 2,
)

#set page(background: context {
  // 正文区域宽度（不含左右页边距）
  let textw = page.width - page.margin.left - page.margin.right
  // gutter 的中线刚好在正文区域的 50% 处（两栏对称时）
  let x = page.margin.left + 0.5 * textw

  // 竖线从正文顶部到正文底部（不含上下页边距）
  let y = page.margin.top
  let h = page.height - page.margin.top - page.margin.bottom

  place(
    top + left,
    dx: x,
    dy: y,
    line(length: h, angle: 90deg, stroke: 0.5pt),
  )
})
#counter(page).update(1)
#set page(
  numbering: "1",
  number-align: center + bottom,
)


#set text(size: 10.5pt)
#set par(justify: true, leading: 0.65em)

#show heading.where(level: 1): set block(below: 2em, above: 2em)
#show heading.where(level: 2): set block(below: 1.5em, above: 2em)
#show heading.where(level: 3): set block(below: 1.3em)

#show heading.where(level: 1): set text(fill: red)
#show heading.where(level: 2): set text(fill: blue, font: "Microsoft YaHei")
#show heading.where(level: 3): set text(weight: "regular")

#show heading.where(level: 1): it => [
  #colbreak(weak: true)
  #it
]

#let note(body) = [
  #text(fill: gray)[注：#body]
]


= Chapter 1 Sinusoidal analysis and modeling

== 1. Intro

将声音分解为正弦波之和，再在频域上寻峰是一种常见的分析手段。

有两种常见手段：
- STFT（短时傅里叶变换）
- Filter bank（滤波器组）

== 分辨正弦峰

== 2. 窗的效应

时域上乘窗等价于频域上卷积

#note[卷积算子 $T_W(X) = X * W$ 不是单射，存在零空间，即存在不为零的 $D$ 使得 $T_W(D) = 0$，两个不同的函数乘窗后可能会变得一样即说明了这一点。]

由于窗口函数频谱的形状特性（主瓣有一定宽度），导致原函数中相近的峰难以被区分。

== 3. 窗的主瓣宽度

#table(
  columns: 2,
  align: (left, left),
  stroke: 0.6pt,
  inset: (x: 6pt, y: 7pt),
  table.header[*Window*][*Main-lobe width*],
  [Rectangular], [$(4 pi) / (M-1) approx 2 Omega_M$],
  [Hamming], [$(8 pi) / M approx 4 Omega_M$],
  [Bartlett], [$(8 pi) / M approx 4 Omega_M$],
  [Blackman], [$(12 pi) / M approx 6 Omega_M$],
  [Hann], [$(8 pi) / M approx 4 Omega_M$],
)

$M$ 是采样点数，$Omega_M$ 是 DFT 格点长，$Omega_M = (2 pi) / M$，$Delta f = F_s / M$。

== 4. 窗长度选择

#figure(
  image("media/Chap1/window_length.png", width: 70%),
)

如果要让相邻的峰能被分辨，需要有：

$
  B_w <= Delta f
$

$B_w$ 是主瓣宽度。若 $B_w = L F_s/M$

$
  => M >= L F_s / (Delta f)
$

$Delta f$ 越小，需要的 $M$ 越大。

== 5. Zero padding

Zero padding 是一种用于提高 FFT 分辨率的方法。

在时域信号后补零，拓宽窗口。

为何补0不会改变频谱，从数学上非常好理解：

$
  X[k] = sum_(n=0)^(N-1) x[n] e^(-j (2 pi) / N k n)
$

补的 0 对求和的贡献为 0

假设补 $J - 1$ 倍长，\$N' = J N\$，则

$
  X'[k] = sum_(n=0)^(N-1) x[n] e^(-j (2 pi) / (J N) k n) = X[k / J]
$

补 0 的频谱对原频谱的补充

== 6. Parabolic interpolation

抛物线插值是一种估计更精确峰值位置的方法。\
在峰值附近3个点做抛物线拟合。

#note[一般只对幅度谱适用。且幅度谱形状和相位谱无关联，
  不能认为幅度峰值位置也有相位谱峰。]

== 加法合成分析技术

== 7. 加法合成（振荡器组）

$
  y(t) = sum_i A_i (t) sin[omega_i (t)t + phi_i (t)]
$

== 8. 从 STFT 数据用谐波模型合成

有两个问题：

- 帧内数据过多
- 帧间不连续

解决方法，Peak tracking：\
在帧内找峰，帧间对峰连线；\
除瞬态外往往只需要幅度和频率信息。

== 9. Sines + Noise Modeling

为模拟真实声音，往往引入噪声建模

$
  s(t) = sum_(i=1)^R A_i (t) cos(theta_i (t)) + e(t)
$

$e(t)$ 是用白噪声通过一个时变滤波器得到的


== 10. Vocoder

用滤波器组结果驱动振荡器组

$
  x_k (t) = a_k (t) cos[omega_k t + phi.alt_k(t)]
$

看起来频率并经调制，但实际上有

$
  Delta omega_k = (dif phi.alt_k (t)) / (dif t)
$

所以也可以有

$
  x_k (t) = A_k (t) cos([omega_k + Delta omega_k (t)] t)
$

数学上等价，但工程上常用后者

== 10. Channel vocoder

一种早期语音压缩重建技术

在 vocoder 完全舍弃相位（瞬态频率），只用幅度。

#note[一个信号经过绝对值，再经过一个低通滤波
  得到其幅度包络。]

== 11. 窄带信号理论

假设一个信号是窄带的，其可写作

$
  x_k (t) = a_k (t) cos(omega_k t + phi.alt_k (t))
$

由欧拉公式可知，

$
  x_k (t) = (a_k (t))/2 e^(j(omega_k t + phi.alt_k (t))) + a_k(t)/2 e^(-j(omega_k t + phi.alt_k (t)))
$

只保留正频率，消去负频率项，得到解析信号（analytic signal）

$
  x_k^a (t) = a_k (t) e^(j(omega_k t + phi.alt_k (t)))
$

再将频率中心移到 0，得

$
  x_k^m (t) = e^(-j omega_k t) x_k^a(t) = a_k (t) e^(j phi.alt_k (t))
$

== 12. 希尔伯特变换

Hilbert 变换的本质是全通 $plus.minus 90 deg$ 相移滤波器。

其频域为

$
  G_H(f) = -j "sgn"(f) = e^(-j pi/2 "sgn"(f))
$

时域

$
  g_H (t) = 1 / (pi t)
$

因此 Hilbert 变换为

$
  hat(x) = HH [x(t)] = x(t) * 1/(pi t)
$

如果我们已知信号的 analytic signal

$
  hat(x)(t) = Im[x_a (t)], x_a (t) = x(t) + j H[x(t)]
$

且有

$
  1/(G_H (f)) = j "sgn"(f) = -G_H (f)
$

== 13. Phase vocoder：相位声码器

对于实信号 $x(t)$，有 $x(t) = Re[x_k^a (t)]$

经 Hilbert 变换，有

$
  Im[x_k^a (t)] = H[x(t)]
$

于是
$
  x_k^a(t) = Re[x_k^a(t)] + j Im[x_k^a(t)] = a_k (t)e^(j(omega_k t + phi.alt_k(t)))
$


则

$
  cases(
    a_k (t) = |x_k^a (t)|,
    phi.alt_k (t) = angle(x_k^a (t)) - omega_k t = tan^(-1)(Im[x_k^a (t)] / Re[x_k^a (t)]) - omega_k t
  )
$


或

$
cases(
  a_k (t) = |x_k^m (t)|,
  phi.alt_k (t) = angle(x_k^m (t)) = tan^(-1)(Im[x_k^a (t)] / Re[x_k^a (t)])
)
$

不过不常用，因为反三角函数的计算成本很高

一般用 $Delta omega_k (t) = (dif) / (dif t) phi.alt_k (t)$ 求瞬时频率

$
  Delta omega_k (t) = (x y' - y x') / (x^2 + y^2)
  quad (x in Re{}, y in Im{})
$


#note[$
  (dif tan^(-1) x) / (dif t) = 1/(1+x^2)
$]
