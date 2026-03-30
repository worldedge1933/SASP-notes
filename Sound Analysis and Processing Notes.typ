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


= Chapter 1: Sinusoidal analysis and modeling


== 1. Intro

将声音信号解耦为准正弦分量与瞬态分量，是一种常见的分析思路。

常用分析方法包括：

- STFT（短时傅里叶变换）
- Filter bank（滤波器组）

=== 分辨正弦峰

== 2. 窗的频谱

时域上乘窗等价于频域上的卷积：

$
  X_w(omega) = X(omega) * W(omega)
$

因此，窗函数会改变频谱峰的外观。主瓣决定分辨能力，旁瓣会带来谱泄漏；如果两个频率分量距离过近，就会难以在频域上分开。

== 3. 常用窗的主瓣宽度

不同窗函数的主瓣宽度不同，典型结果可记为：

- Rectangular: $4 pi / M approx 2 Omega_M$
- Bartlett: $8 pi / M approx 4 Omega_M$
- Hann: $8 pi / M approx 4 Omega_M$
- Hamming: $8 pi / M approx 4 Omega_M$
- Blackman: $12 pi / M approx 6 Omega_M$

其中，$M$ 为采样点数，$Omega_M$ 表示 DFT 栅格间隔。

== 4. 频率区分

#figure(
  rect(
    width: 100%,
    height: 36mm,
    stroke: 0.6pt,
    inset: 8pt,
  )[
    #align(center)[窗函数频谱示意占位]
  ],
)

若要区分两个相近的正弦频率，频谱分辨率需要满足：

$
  B_w <= Delta f
$

其中 $B_w$ 为主瓣宽度。若写成 $B_w = L Delta f$，则窗长需要足够大；主瓣越窄，所需的 $M$ 通常越大。

== 5. Zero padding

Zero padding 是一种提高 FFT 频率采样密度的方法。

原始长度为 $N$ 时：

$
  X[k] = sum_(n=0)^(N-1) x[n] e^(-j 2 pi k n / N)
$

若在时域末尾补零，并把长度扩展到 $N' > N$，则有：

$
  X'[k] = sum_(n=0)^(N-1) x[n] e^(-j 2 pi k n / N')
$

补零不会提升真实频率分辨率，但会让频谱采样更密，从而便于观察峰值位置。

== 6. Parabolic interpolation

抛物线插值是一种估计更精确谱峰位置的方法，可在单个峰值附近利用二次曲线近似来细化峰值位置。

通常它能改善读数精度，但对噪声与混叠较为敏感，不能简单理解为严格意义上的最优估计。

=== 加法合成分析技术

== 7. 加法合成

加法合成将信号表示为一组随时间缓慢变化的正弦分量之和：

$
  y(t) = sum_(i=1)^N A_i(t) sin(omega_i(t) t + phi_i(t))
$

== 8. 从 STFT 数据用谐波模型合成

从 STFT 数据重建谐波模型时，通常会遇到两个问题：

- 帧内参数的离散化误差
- 帧间参数不连续

常见做法是使用 peak tracking，在相邻分析帧之间关联谱峰，并在重叠区域平滑频率与相位。

== 9. Sines + Noise Modeling

为了更好地刻画语音或乐器信号，常将模型写为：

$
  s(t) = sum_(r=1)^R A_r(t) cos(theta_r(t)) + e(t)
$

其中 $e(t)$ 用于描述随机噪声项，或未被谐波分量解释的残差信号。


=== Vocoder and phase processing

== 10. Vocoder

使用声码器思想组合或修改频率分量时，可将每个分量写成：

$
  x_k(t) = A_k(t) cos(omega_k t + phi_k(t))
$

若保持包络基本不变，而只修改瞬时角频率，则有：

$
  Delta omega_k(t) = (dif phi_k(t)) / (dif t)
$

因此可以通过调节相位演化速度来实现变调或频率偏移，同时尽量保持音色特征。

=== Channel vocoder

Channel vocoder 是一种早期语音压缩与重建技术。它在分析阶段强调各频带的幅度包络，而对相位信息保留较少，因此瞬态细节通常会受到影响。

原始信号经分带、整流和低通滤波后，可以得到每个通道的慢变化包络，并将其用于后续重建。

== 11. 带限信号正交化

设窄带信号为：

$
  x_k(t) = A_k(t) cos(omega t + phi_k(t))
$

将其写成复指数形式：

$
  x_k(t) = (A_k(t) / 2) e^(j (omega t + phi_k(t))) + (A_k(t) / 2) e^(-j (omega t + phi_k(t)))
$

仅保留正频率项后，可得解析信号（analytic signal）：

$
  x_k^a(t) = A_k(t) e^(j (omega t + phi_k(t)))
$

再通过频移到基带，可得：

$
  x_k^b(t) = e^(-j omega t) x_k^a(t) = A_k(t) e^(j phi_k(t))
$

== 12. 希尔伯特变换

Hilbert 变换的作用可以理解为对信号施加 $90 deg$ 的相移滤波。

其频域响应常写为：

$
  G_H(f) = -j "sgn"(f)
$

对应的时域卷积核为：

$
  g_H(t) = 1 / (pi t)
$

因此，

$
  H(x(t)) = x(t) * (1 / (pi t))
$

解析信号可表示为：

$
  x_a(t) = x(t) + j hat(x)(t)
$

其中 $hat(x)(t)$ 为 $x(t)$ 的 Hilbert 变换。

== 13. Phase vocoder

相位声码器的核心在于跟踪复谱相位，并利用相位导数估计瞬时频率。

若复分析信号写为：

$
  x_a(t) = a(t) e^(j (omega t + phi(t))) = x(t) + j y(t)
$

则其幅度与相位分别为：

$
  a(t) = |x_a(t)|
$

$
  phi(t) = "arg"(x_a(t)) - omega t
$

瞬时频率可写成：

$
  omega_i(t) = omega + (dif phi(t)) / (dif t)
$

当 $x_a(t) = x(t) + j y(t)$ 时，相位导数满足：

$
  (dif phi(t)) / (dif t) = (x(t) y'(t) - y(t) x'(t)) / (x(t)^2 + y(t)^2)
$

这来自于反正切求导公式：

$
  (dif (arctan x)) / (dif t) = (1 / (1 + x^2)) (dif x) / (dif t)
$

