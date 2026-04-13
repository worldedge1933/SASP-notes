// -----------------
// Cover
// -----------------
#set page(
  margin: (top: 22mm, bottom: 22mm, left: 18mm, right: 18mm),
  columns: 1,
  background: none,
  numbering: none,
)

#set math.mat(delim: "[")


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
#let chapter = state("chapter", 0)
#set math.equation(
  numbering: (..nums) => context {
    numbering("(1.1)", chapter.get(), ..nums)
  },
)

#show heading.where(level: 1): set block(below: 2em, above: 2em)
#show heading.where(level: 2): set block(below: 1.5em, above: 2em)
#show heading.where(level: 3): set block(below: 1.3em)

#show heading.where(level: 1): set text(fill: red)
#show heading.where(level: 2): set text(fill: blue, font: "Microsoft YaHei")
#show heading.where(level: 3): set text(weight: "regular")

#show heading.where(level: 1): it => [
  #context chapter.update(n => n + 1)
  #counter(math.equation).update(0)
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



= Chapter 7 Linear predictive coding

== 1. 自回归模型

当前值视作 $p$ 个旧的值的线性组合（FIR）

$
  s(n) approx sum_(k=1)^p a_k s(n-k)
$

#note[$A_k$ 一般只在分析窗内视作是常数]

当然，真实世界往往还有噪音，于是

$
  s(n) = sum_(k=1)^p a_k s(n-k) + G u(n)
$

$u(n)$ : 白噪音，激励

#note[必须有白噪，否则要么简单振荡，要么衰减至0或无穷发散]

现在我们将其转移到 $z$ 域上

$
  S(z) eq sum_(k=1)^p a_k z^(-k) S(z) + G U(z)
$

于是定义如下

$
  H(z) eq.delta S(z) / (G U(z)) = 1 / (1 - sum_(k=1)^p a_k z^(-k)) eq.delta 1 / A(z)
$

$
  A(z) eq.delta 1 - sum_(k=1)^p a_k z^(-k)
$

$H(z)$ 是一个全极点滤波器

== 2. LPC 预测器

于是我们可以有一个线性预测器，并得到对 $s$ 的估计

$
  hat(s)(n) eq.delta sum_(k=1)^p a_k s(n-k)
$

于是，我们有误差

$
  e(n) eq.delta s(n) - hat(s)(n) = s(n) - sum_(k=1)^p a_k s(n-k)
$

$
  E(z) = (1 - sum_(k=1)^p a_k z^(-k)) S(z) = A(z) S(z) = S(z) / H(z)
$

其中

$A(z)$: Inverse filter / Whitening filter

$H(z)$: Forward filter / Shaping filter

$
  P(z) eq.delta sum_(k=1)^p a_k z^(-k)
$

$P(z)$: prediction filter

$
  A(z) = 1 - P(z)
$

且有

$
  e(n) = G u(n)
$

#note[LPC 的本质是：找一个滤波器，使得输出误差尽可能像白噪声；或：把信号中的“结构”全部提取出来，剩下的应该是“无结构”的随机噪声]

== 3. 求解 LPC 参数

求解 LPC 参数可以转化为以下优化目标

$
  min_(a_k) E[ |s(n) - hat(s)(n)|^2]
$

#figure(
  image("media/Chap7/LPC_model.png", width: 100%),
)

#note[注意观察这里系数编号和一般版本的区别。]

于是这个问题可以转化为 Wiener-Hopf 方程

$
  sum_(k=1)^p a_k r(i-k) = r(i), quad i = 1,2,3,...,p
$

写成矩阵形式为

$
  bold(upright(a)) = bold(upright(R))^(-1) bold(upright(r))
$

其中

$
  bold(upright(R))=mat(
    delim: "[",
    r(0), r(1), dots, r(p-1);
    r(1), r(0), dots, r(p-2);
    dots.v, dots.v, dots.down, dots.v;
    r(p-1), r(p-2), ..., r(0)
  )
$
$
  bold(upright(a)) = mat(
    delim: "[",
    a_1;
    dots.v;
    a_p
  )
$
$
  bold(upright(r)) =
  mat(
    delim: "[",
    r(1);
    dots.v;
    r(p)
  )
$

并有

$
  D_p & = E_min = sigma^2 - bold(upright(r))^T bold(upright(R))^(-1) bold(upright(r)) \
      & = r(0) - bold(upright(r))^T bold(upright(a)) \
      & = r(0) - sum_(k=1)^p a_k r(k)
$

#note[$sigma$ 是输入信号的方差，也即 $r(0)$]

我们引入新概念：prediction gain

$
  G_p = sigma^2 / D_p
$

$G_p -> oo$，$s(n)$ 很好预测

$G_p -> 1$，$s(n)$ 无法预测（如白噪声）

== 4. 白化原因推导

我们假设有一理想无限长 LP

$
  s(n) = sum_(k=1)^infinity a_k s(n-k)
$

由正交原理有

$
  E[e_o(n) s(n-i)] = 0, quad i = 1,2,...,oo
$

于是

$
  r_e_o (i) & = E[e_o (n)e_o (n-i)] \
            & = E[e_o (n)[s(n-i) - hat(s)_o (n-i)]] \
            & = E[e_o (n)s(n-i)] - E[e_o (n) sum_(k=1)^infinity a_k s(n-i-k)] \
            & = E[e_o (n)s(n-i)] - sum_(k=1)^infinity a_k E[e_o (n)s(n-i-k)] \
            & = 0 - sum_(k=1)^infinity a_k * 0 \
            & = 0, quad forall i > 0
$

由于自相关函数为偶函数，因此对 $i < 0$ 同样成立

$
  r_e_o (0) = D_p
$

$
  r_e_o (i) = 0, quad i != 0
$

而这正是白噪声的定义

#note[这一性质只对无限长滤波器严格成立。]

== 5. LPC 的一些性质

- $A(z)$ 是 minimum-phase，零点在单位圆内，保证稳定
- 可用 Levinson-Durbin 快速求解

== 6. LPC 的功率谱包络性质

当 LPC 阶数增高时，有

$
  lim_(p -> oo) |hat(S)_n (omega)|^2 = |S_n (omega)|^2
$

#note[对复数，$|X| = |Y|$ 不能推出 $X = Y$。]

即 $hat(S)$ 的功率谱是 $S$ 的包络，并逐渐趋近于 $S$

这个包络在峰处跟踪效果较好，在谷处差

== 7. LPC 的阶数选取

$p$ 决定了频谱拟合的光滑程度
- $p$ 小，功率谱粗略包络，细节不足，抓大轮廓
- $p$ 大，过拟合

因为 $H$ 是一个全极点滤波器，且极点数量是 $p$

语音经验公式为

$
  F_s / 1000 <= p <= F_s / 1000 + 4
$

== 8. 频率选择性 LPC

我们可以构造出一种 LPC，使其只关心部分频率。\
基本思想：频率映射

$
  omega in [2 pi f_A, 2 pi f_B] -> omega' in [0, 2pi]
$

#note[原笔记此处还有一段与 $x[n]$ 相关的映射说明，但手写辨识不够稳定，暂不擅自补写。]

只需使用以下新定义的自相关函数

$
  r_n'(k) = 1/(2 pi) integral_(-pi)^(pi) |S_n (omega ')|^2 e^(j omega' k) dif omega
$


= Chapter 11 Digital Audio Restoration

声音修复（Audio Restoration）是指对受损或退化的音频信号进行处理，以恢复其原始质量和清晰度的过程或对其进行降噪的过程。

音频质量劣化的类型往往包括：
- 局部劣化：如点击声、爆音、咔嗒声等；
- 全局劣化：如背景噪声、震荡，或某些类型的非线性失真等。

== 全局劣化修复

== 1. 维纳滤波

维纳滤波的模型如下图所示

#figure(
  image("media/Chap11/wiener_model.png", width: 70%),
)

其中 $s$ 是想要恢复的原始信号，$v$ 是噪声，$x$ 是观测到的受噪声污染的信号，$y = hat(s)$ 是滤波器输出的估计信号。

维纳滤波的目标是找到一个线性滤波器 $h$，使得输出信号 $y$ 与原始信号 $s$ 之间的均方误差最小化：

$
  text("MSE") = E [(s-y)^2]
$

在 Chapter 4 中，我们已经介绍了正交原理及其推论，即当误差最小时，误差与观测信号正交，即

$
  e = (s-y) perp x
$

也即

$
  E [(s(n)-y(n))x(m)] = 0, forall m, n
$ <eq:orth_principle>

将 @eq:orth_principle 展开，我们得到

$
  E [ s(n)x(m)] = E [y(n)x(m)]
$

于是

$
  r_(s x) (n - m) = & E[sum_k h(k) x(n-k) x(m)] \
                  = & sum_k h(k) r_x (n - m - k)
$

换元简化形式可得

$
  r_(s x) (n) = sum_k h(k) r_x (n - k)
$

转到时域有

$
  H(omega) = (R_(s x) (omega)) / (R_x (omega))
$


事实上，由于 s 和 v 不相关，于是有

$
  r_(s x) (n) & = E[ s(k) x(k+n)] \
              & = E[ s(k) (s(k+n) + v(k+n))] \
              & = E[ s(k) s(k+n)] + E[ s(k) v(k+n)] \
              & = E[ s(k) s(k+n)] + 0 \
              & = r_s (n)
$

对 $r_x$ 也进行类似分析，最终得到

$
  H(omega) = (R_s (omega)) / (R_s (omega) + R_v (omega))
$

#note[一个信号的自相关函数的频谱是其本身的功率谱，即
  $
    R_s(omega) = |S(omega)|^2 = P_s(omega)
  $
]

由此，我们就得到了标准的维纳滤波器频率响应。这样的滤波器的结果是最小均方误差（MMSE）的，同时由于这个滤波器的频率响应为实数（且为正值），所以其不会引入任何额外的相位变化。使用这样一种滤波器所依据的前提是，信号 s 和噪声 v 的功率谱是已知或能用某种方法估计的。

上述推导有一个未提到的大前提：s 和 v 是均值为 0 的随机过程，如果它们的均值不为 0，那么维纳滤波器需要转变为以下结构

#figure(
  image("media/Chap11/non_zero_mean_wiener.png", width: 70%),
)

其中，$m_s$ 和 $m_v$ 分别是信号 s 和噪声 v 的均值。对于非零均值的情况，维纳滤波器需要先对输入信号进行去均值处理，即从观测信号 x 中减去均值 $m_s + m_v$，然后再进行线性滤波，最后再加上信号的均值 $m_s$ 来得到最终的估计结果。

对于高信噪比（$P_s >> P_v$）的情况，维纳滤波器的响应倾向于 1，几乎不对信号进行衰减；而对于低信噪比（$P_s << P_v$）的情况，维纳滤波器的响应倾向于 0，几乎完全抑制信号。

有时，维纳滤波器也可以写成以下形式

$
  H(omega) = (P_x (omega) - P_v (omega)) / (P_x (omega))
$

== 2. Power Spectral Matching (PSM)

MMSE 的优化准测在数学上是最优的，但是在听觉上并不一定是最优的。PSM 的优化目标是使得滤波器输出信号的功率谱与原始信号的功率谱尽可能匹配，由此推出的滤波器为

$
  hat(H) = sqrt(P_s / (P_s + P_v)) = sqrt((P_x (omega) - P_v (omega)) / (P_x (omega)))
$

== 3. Parametric Wiener filtering

$
  H_p (omega) = {(P_x (omega) - alpha P_v (omega)) / (P_x (omega))}^beta
$

通过对 $alpha$ 和 $beta$ 的调整，可以在 MMSE 和 PSM 之间进行权衡，以获得更好的听觉效果。

== 4. 短时傅里叶变换视角下的算法流程

#figure(
  image("media/Chap11/STFT_Spectral_Attenuation.png", width: 90%),
)

其中 $G(t_a^u, Omega_k)$ 是 spectral attenuation function。

$hat(P)_v$ 是噪声功率谱的估计，可以通过在没有信号的帧上计算平均功率谱来获得。

$
  hat(P)_v (Omega_k) = E [ |V(t_a^u, Omega_k)|^2 ]
$

Wiener Suppression Rule:
$
  G(t_a^u, Omega_k) = 1 - (hat(P)_v (Omega_k)) / (|X (t_a^u, Omega_k)|^2)
$

PSM Suppression Rule:

$
  G(t_a^u, Omega_k) = sqrt(1 - (hat(P)_v (Omega_k)) / (|X (t_a^u, Omega_k)|^2))
$

Parametric Suppression Rule:

$
  G(t_a^u, Omega_k) = {1 - alpha (hat(P)_v (Omega_k)) / (|X (t_a^u, Omega_k)|^2)}^beta
$

== 4. 去混响：倒谱方法 (Complex cepstrum)

定义信号的倒谱为
$
  c_x (n) & = cal(F)^(-1) {log X(omega)} \
          & = cal(F)^(-1) {log S(omega) + log H(omega)} \
          & = c_s(n) + c_h(n)
$

语音信号的倒谱主要集中在靠近原点的低频区域，而混响的倒谱主要集中在高频区域

== 5. 去混响：逆混响方法

如果混响系统的冲激响应 $h(n)$ 是已知的，那么可以通过构造一个逆滤波器来去除混响的影响。对 FIR 来说，其逆是一个 IIR，可能不稳定，因此我们希望计算一个近似的 FIR 逆滤波器，并将其转化为一个最小二乘解的线性方程组问题。

线性方程组为

$
  underbrace(
    mat(
      delim: "[",
      1;
      0;
      dots.v;
      0
    ),
    bold(upright(d))
  )
  =
  underbrace(
    mat(
      delim: "[",
      h[0], 0, dots.h, 0;
      h[1], h[0], dots.down, dots.v;
      dots.v, h[1], dots.down, 0;
      h[N_h], dots.v, dots.down, h[0];
      0, h[N_h], dots.down, h[1];
      dots.v, dots.down, dots.down, dots.v;
      0, dots.h, 0, h[N_h]
    ),
    bold(upright(H))
  )
  underbrace(
    mat(
      delim: "[",
      g[0];
      g[1];
      dots.v;
      g[N_g]
    ),
    bold(upright(g))
  )
$

其近似解为：

$
  bold(upright(g))_(L S) = (bold(upright(H))^T bold(upright(H)))^(-1) bold(upright(H))^T bold(upright(d))
$

== 压缩与扩展

== 6. 瞬时非线性系统对信号统计特性的影响

音频信号 $U(n)$ 可以被视作随机过程，因此可以得到其相应的统计特性。

Cumulative Probability Density Function (CPDF) 定义为

$
  F_U (u) eq.delta P[ U(n) <= u ]
$

对一个信号做瞬时非线性变换 $g(dot) $可以改变这个概率分布。

#note[瞬时指当前输出只与当前输入有关]

现在我们选取一个特殊的瞬时非线性函数

$
  g(dot) = F_U(dot)
$

$
  V = g(U) = F_U(U) in UU[0,1 ]
$

这样处理后得到的是符合0-1均匀分布的随机过程

现在我们有另一概率分布 $F_W$，现在我们希望让信号变成符合这个概率分布的随机过程。我们可以通过以下变换实现：

$
  W = F_W^(-1) (V) = F_W^(-1) (F_U(U))
$

== 7. 维纳滤波视角下的 Dolby NR

Dolby NR 通过录音时动态增强容易受噪声影响的频段，播放时再反向还原信号，同时把后加入的高频噪声压低；从 Wiener filter 的角度看，这相当于一种面向低 SNR 区域的动态最优化处理。

#figure(
  image("media/Chap11/Dolby_NR.png", width: 90%),
)

预加重的意义是让维纳滤波的作用变得“无关紧要”。

我们选取以下系统作为预加重系统和逆加重系统

$
  G = sqrt( P_v / P_s), space space F = sqrt(2) / G  = sqrt(2 P_s / P_v)
$

于是我们可以得到

$
  P_(overline(s)) (omega) = |G(omega)|^2 P_s (omega) = P_v (omega)
$

于是有

$
  H(omega) = (P_(overline(s)) (omega)) / (P_(overline(s)) (omega) + P_v (omega)) = 1/2
$

此外还有

$
  P_y (omega) = |H(omega)|^2 P_(x) (omega) = 1/2 P_v (omega) 
$

$
  P_(hat(s)) = |F(omega)|^2 P_y (omega) = P_s (omega)
$

预加重往往是高通，逆加重是低通，作用强度取决于 SNR。

由于每首歌的 $P_s$ 不同，因此工程上需要根据大量音频的统计特性来设计一个“通用版本”的预加重和逆加重系统。

== 局部劣化的修复

== 8. Modeling Clicks

对局部退化有两种模型
- Additive model: 适用于大多数常见表面缺陷，如小划痕、灰尘、脏污，因此可以近似成在原信号上叠加一个短时干扰
- Replacement model: 适用于更严重的缺陷，如深划痕、断裂等，原内容视作是完全被替换掉了

在这里，我们讨论 Additive model。公式为：

$
  x(n) = s(n) + i(n) v(n)
$

其中 $i(n)$ 是一个指示是否存在劣化的二值开关

局部退化有以下特点：
- 起始位置和持续时长随机，在 44.1 kHz 采样率下，长度可达200个采样点
- i(n) 的值为 1 的位置通常是连续的，且在时间上相对稀疏
- 幅度变化范围特别大

#figure(
  image("media/Chap11/click_restore_model.png", width: 90%),
)

Click 的修复方法通常分为检测和修复两步

== 9. 基于AR模型的检测与修复


#figure(
  image("media/Chap11/AR_click_detec.png", width: 90%),
)

我们假设信号数据符合一个 AR(p) 模型，于是应该有
$
  s(n) = sum_(k=1)^p a_k s(n-k) + e(n)
$

$
  H(z) = E(z) / S(z) = (1 - sum_(k=1)^p a_k z^(-k))
$

现在我们让劣化后的信号通过这个滤波器，得到

$
  e_d (n) & eq.delta x(n)*h(n) \
          & = (s(n) + i(n) v(n)) * h(n) \
          & = e(n) + i(n) v(n)*h(n) \
$

此外我们还有

$
  P_s (e^(j omega)) = P_e (e^(j omega))
  abs(1 / (H(e^(j omega))))^2
$

#note[功率谱面积等于方差]

$
  2 pi sigma_s^2 & = integral_(-pi)^(pi) P_s (e^(j omega)) abs(1 / (H(e^(j omega))))^2 dif omega \
                 & = sigma_e^2 integral_(-pi)^(pi) abs(1 / (H(e^(j omega))))^2 dif omega
$

于是

$
  sigma_e^2 = (2 pi sigma_s^2) / (integral_(-pi)^(pi) abs(1 / (H(e^(j omega))))^2 dif omega)
$

当没有局部劣化的时候，$sigma_e^2$应该稳定在一个小值附近；当有局部劣化的时候，$sigma_e^2$ 会突然增大。

但是会带来“拖尾”效应，导致时间分辨率变差

#underline[现在我们讨论如何获得滤波器系数]

假设我们使用一段长为 $N$ 的音频数据来估计一个 AR(P) 模型的系数。

不妨设输入序列为：
$
  bold(upright(x)) = mat(
    x(1);
    dots.v;
    x(N)
  ) = mat(
    overline(bold(upright(x)));
    hat(bold(upright(x)))
  )
$

其中

$
  overline(bold(upright(x))) = mat(
    x(1);
    dots.v;
    x(P)
  ), space space
  hat(bold(upright(x))) = mat(
    x(P+1);
    dots.v;
    x(N)
  )
$

于是，自回归模型 $x(n) = sum_(k=1)^P a_k x(n-k) + e(n)$可以转化为以下矩阵形式：

$
  hat(bold(upright(x))) & = mat(
                            x(P+1);
                            dots.v;
                            x(N)
                          ) \
                        & = mat(
                            sum_(k=1)^P a_k x(P+1-k);
                            dots.v;
                            sum_(k=1)^P a_k x(N-k)
                          )
                          + mat(
                            e(P+1);
                            dots.v;
                            e(N)
                          ) \
                        & = mat(
                            x(P), x(P-1), dots, x(1);
                            x(P+1), x(P), dots, x(2);
                            dots.v, dots.v, dots.down, dots.v;
                            x(N-1), x(N-2), dots, x(N-P)
                          ) mat(
                            a_1;
                            a_2;
                            dots.v;
                            a_P
                          ) + mat(
                            e(P+1);
                            dots.v;
                            e(N)
                          ) \
$

记为

$
  hat(bold(upright(x))) = bold(upright(G_x)) bold(upright(a)) + bold(upright(e))
$
#note[这里略去基于高斯分布假设的贝叶斯概率推导]

而优化目标则转为

$
  bold(upright(a))^(upright(M L))= min_(bold(upright(a))) (hat(bold(upright(x))) - bold(upright(G_x)) bold(upright(a)))^T (hat(bold(upright(x))) - bold(upright(G_x)) bold(upright(a))) = min_(bold(upright(a))) bold(upright(e))^T bold(upright(e))
$

$
  (partial bold(upright(e))^T bold(upright(e))) / (partial bold(upright(a))) 
  = 2 bold(upright(e))^T (partial bold(upright(e))) / (partial bold(upright(a)))
  = 2 (hat(bold(upright(x))) - bold(upright(G_x)) bold(upright(a)))^T bold(upright(G_x))  = bold(0)
$

解得 

$
  bold(upright(a))^upright(M L) = (bold(upright(G_x))^T bold(upright(G_x)))^(-1) bold(upright(G_x))^T hat(bold(upright(x)))
$

#underline[现在我们讨论如何用 AR 模型来修复劣化]

#figure(
  image("media/Chap11/LSAR.png", width: 90%),
)

整体输入序列为

$
  bold(upright(x)) = mat(
    overline(bold(upright(x)))_L;
    hat(bold(upright(x)));
    overline(bold(upright(x)))_R
  )
$

已知数据序列为

$
  overline(bold(upright(x))) = mat(
    overline(bold(upright(x)))_L;
    overline(bold(upright(x)))_R
  )
$

整体输入序列可以重写为以下形式

$
  bold(upright(x)) =& mat(
    overline(bold(upright(x)))_L;
    hat(bold(upright(x)));
    overline(bold(upright(x)))_R
  ) \
  =& mat(
    bold(0)_(m times l);
    bold(upright(I))_(l times l);
    bold(0)_((N-m-l) times l)
  ) hat(bold(upright(x))) \
  &+ mat(
    bold(upright(I))_(m times m), bold(0)_(m times (N-m-l));
    bold(0)_(l times m), bold(0)_(l times (N-m-l));
    bold(0)_((N-m-l) times m), bold(upright(I))_((N-m-l) times (N-m-l))
  ) mat(
    overline(bold(upright(x)))_L;
    overline(bold(upright(x)))_R
  )\
  &= bold(upright(U)) hat(bold(upright(x))) + bold(upright(K)) overline(bold(upright(x)))
$

$bold(upright(U))$ 和 $bold(upright(K))$ 是重排矩阵。

#note[gap 部分不一定连续，只需对 $bold(upright(U))$ 和 $bold(upright(K))$ 进行适当调整即可。]



在此我们定义一个新的矩阵

$
  bold(upright(A)) = mat(
    -a_P, -a_(P-1), dots, -a_1, 1,0, dots, 0, dots, 0 ,0;
    0, -a_P, dots, -a_2, -a_1, 1, dots, 0, dots, 0 ,0;
    dots.v, dots.v,  , dots.v, dots.v, dots.v,  , dots.v,  , dots.v, dots.v;

    0, 0, dots, 0, 0, 0, dots, -a_P, dots, -a_1, 1
  ) 
$

并有

$
  hat(bold(upright(A))) = bold(upright(A)) bold(upright(U)), space space
  overline(bold(upright(A))) = bold(upright(A)) bold(upright(K)) 
$

#note[这里我们略去推导，直接给出 LSAR (Least Squares AR) 的解。]


$
  hat(bold(upright(x)))_upright(L S) = - (hat(bold(upright(A)))^T hat(bold(upright(A))))^(-1) hat(bold(upright(A)))^T overline(bold(upright(A))) overline(bold(upright(x)))
$


