#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:1.4.7": *
#import "@preview/zap:0.5.0"

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "Лабораторная работа",
    number: "3",
    subject: "Исследование простых цепей синусоидального тока",
    variant: "4",
  ),
  manager: (
    name: "Батюков С.В.",
  ),
  performer: (
    name: "Ермаков В. С.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

// Глобальные константы для расчетов
#let f = 800
#let U_value = 5
#let U = polar(U_value, 0) // Входное напряжение U = 5e^(j0) В

// ИСХОДНЫЕ ДАННЫЕ
#let V = (
  R1: 141.9,  // Ом
  R2: 141.7,  // Ом
  R3: 144,    // Ом
  L: 43.96,   // мГн
  rk: 53.3,   // Ом
  C: 1.016,   // мкФ
  VARIANT: 4,
)

= Цель работы
Приобретение навыков работы с вольтметром, амперметром, генератором, фазометром. Экспериментальная проверка законов распределения токов и напряжений в последовательной, параллельной и последовательно-параллельной цепях гармонического тока.

= Расчет домашнего задания

== Последовательная цепь

Исходные данные варианта #V.VARIANT представлены в таблице @src-table-1, схема электрической цепи для последовательного соединения представлена на рисунке @src-circuit-1.

#figure(
  caption: [Исходные данные варианта #V.VARIANT],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      [№ \ вар.], [Схема на рис.], [$U$, В], [$f$, Гц], [$R_1$, Ом], [$R_2$, Ом], [$R_3$, Ом], [$L$, мГн], [$r_k$, Ом], [$C$, мкФ]
    ),
    [4], [3.9], [#U_value], [#f], [#V.R1], [#V.R2], [#V.R3], [#V.L], [#V.rk], [#V.C]
  )
) <src-table-1>

#lab-figure(
  above: -3em,
  gap: -1em,
  caption: [Схема для исследования последовательной цепи],
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("4", (0, 0), label: (content: "4", anchor: "bottom"), visible: true)
    node-better("3", (8, 0), label: (content: "3", anchor: "bottom"), visible: true)
    node-better("2", (8, 4), label: (content: "2", anchor: "left"), visible: true)
    node-better("mid", (8, 7), visible: false)
    node-better("1", (0, 10), label: (content: "1", anchor: "top"), visible: true)

    open-branch-better("U_in", "1", "4", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")
    wire("1", (8,10))
    current-arrow("I_arrow", (2,10), (6,10), arrow-label: $dot(I)$, arrow-side: "top")
    inductor-better("L", (8,10), "mid", label: (content: $L$, anchor: "west"), arrow-label: $dot(U)_k$, arrow-side: "right", arrow-dir: "forward")
    resistor-better("rk", "mid", "2", label: (content: $r_k$, anchor: "west"), arrow-label: (content: $dot(U)_k$, dist: -0.4), arrow-side: "right", arrow-dir: "down")
    capacitor-better("C", "2", "3", label: (content: $C$, anchor: "west"), arrow-label: $dot(U)_C$, arrow-side: "right", arrow-dir: "down")
    resistor-better("R1", "3", "4", label: (content: $R_1$, anchor: "top"), arrow-label: $dot(U)_1$, arrow-side: "bottom", arrow-dir: "left")
  })
) <src-circuit-1>

#pagebreak()
Найдем реактивные сопротивления индуктивности и емкости:
#let XL_calc = calc-reactance-L(f, V.L)
#let XC_calc = calc-reactance-C(f, V.C)
#XL_calc.display
#XC_calc.display

Определяем комплексное входное сопротивление цепи:
#let components = (
  (type: "R", val: V.R1, symbol: $R_1$),
  (type: "R", val: V.rk, symbol: $r_k$),
  (type: "XL", val: XL_calc.val),
  (type: "XC", val: XC_calc.val),
)
#let Z_calc = calc-series-impedance(components)
#Z_calc.display

Определяем комплексный ток, приняв начальную фазу входного напряжения равной нулю:
#let I_calc = calc-ohms-law(U, Z_calc.val)
#I_calc.display

Найдём комплексные напряжения на участках цепи:
#let Z_k = rect(V.rk, XL_calc.val)
#let U_K_calc = calc-voltage-drop-explicit(
  I_calc.val, Z_k,
  $r_k + j X_L$,
  $#_fmt(V.rk) + #add_j(XL_calc.val)$,
  U-symbol: $U_K$
)
#U_K_calc.display

#let Z_C = rect(0, -XC_calc.val)
#let U_C_calc = calc-voltage-drop-explicit(
  I_calc.val, Z_C,
  $- j X_C$,
  $- #add_j(XC_calc.val)$,
  U-symbol: $U_C$
)
#U_C_calc.display

#let Z_1 = rect(V.R1, 0)
#let U_1_calc = calc-voltage-drop-explicit(
  I_calc.val, Z_1,
  $R_1$,
  $#add_j(V.R1)$,
  U-symbol: $U_1$
)
#U_1_calc.display

// Для проверки правильности вычислений сложим все падения напряжений. По второму закону Кирхгофа сумма должна быть равна входному напряжению $dot(U)$:
// #let U_check = add(add(U_K_calc.val, U_C_calc.val), U_1_calc.val)
// #let check_im_sign = if U_check.im < 0 {$-$ } else {$+$}
// #mathtype-mimic[
//   $ dot(U)_1 + dot(U)_C + dot(U)_K = #_fmt(U_check.re) #check_im_sign j #_fmt(calc.abs(U_check.im)) " В" approx #_fmt(U_value) + j 0","00 " В". $
// ]

// --- Вытягиваем полярные значения для таблицы ---
#let Z_polar = to-polar(Z_calc.val)
#let I_polar = I_calc.val-mA
#let UK_polar = to-polar(U_K_calc.val)
#let UC_polar = to-polar(U_C_calc.val)
#let U1_polar = to-polar(U_1_calc.val)

// Собираем все расчётные данные в один массив
#let calc_row = (
  XL_calc.val, XC_calc.val,
  Z_polar.mag, Z_polar.ang,
  I_polar.mag, I_polar.ang,
  UK_polar.mag, UK_polar.ang,
  UC_polar.mag, UC_polar.ang,
  U1_polar.mag, U1_polar.ang
)

// диаграмма - потом

#figure(
  caption: [Результаты для последовательной цепи],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Цепь\ на\ рис.\ 3.5],
      table.cell(rowspan: 2)[$X_L$,\ Ом],
      table.cell(rowspan: 2)[$X_C$,\ Ом],
      table.cell(colspan: 2)[$Z_"вх"$],
      table.cell(colspan: 2)[$I$],
      table.cell(colspan: 2)[$U_K$],
      table.cell(colspan: 2)[$U_C$],
      table.cell(colspan: 2)[$U_1$],
      // Вторая строка шапки
      [$Z_"вх"$,\ Ом], [$phi$,\ град.],
      [$I$,\ мА], [$psi_1$,\ град],
      [$U_K$,\ В], [$psi_(U K)$,\ град.],
      [$U_C$,\ В], [$psi_(U C)$,\ град.],
      [$U_1$,\ В], [$psi_(U 1)$,\ град.]
    ),

    // Форматируем массив (3 знака) -> Поворачиваем на -90 градусов -> Разворачиваем (..) в ячейки
    [Расчет], ..rotate-cells(..format-cells(..calc_row, dec: 3)),

    // Строка для эксперимента (12 пустых ячеек)
    [Опыт], ..rotate-cells(..((hide("............."),) * 12))
  )
) <res-table-1>

== Параллельная цепь

Схема электрической цепи для параллельного соединения элементов представлена на рисунке @src-circuit-2.

#lab-figure(
  above: 1em,
  caption: [Схема для исследования параллельной цепи],
  circuit-better(scale-factor: 80%, {
    import zap: *

    // Опорные узлы
    node-better("T0", (0, 6), visible: false)
    node-better("B0", (0, 0), visible: false)
    node-better("T1", (3, 6), visible: true)
    node-better("B1", (3, 0), visible: true)
    node-better("T2", (6, 6), visible: true)
    node-better("B2", (6, 0), visible: true)
    node-better("T3", (9, 6), visible: false)
    node-better("M3", (9, 3), visible: false)
    node-better("B3", (9, 0), visible: false)

    // Входное напряжение (стрелка вниз)
    open-branch-better("U_in", "T0", "B0", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    // Верхний и нижний провода
    wire("T0", (1.5, 6))
    current-arrow("I", (1.5, 6), (3, 6), arrow-label: $dot(I)$, arrow-side: "top")
    wire("T1", "T2")
    wire("T2", "T3")
    wire("B0", "B3")

    // 1-я ветвь (резистор)
    resistor-better("R1", "T1", "B1", label: (content: $R_1$, anchor: "left"), arrow-label: $dot(I)_1$, arrow-side: "right", arrow-dir: "down")

    // 2-я ветвь (конденсатор)
    capacitor-better("C", "T2", "B2", label: (content: $C$, anchor: "left"), arrow-label: $dot(I)_2$, arrow-side: "right", arrow-dir: "down")

    // 3-я ветвь (катушка + резистор)
    inductor-better("L", "T3", "M3", label: (content: $L$, anchor: "left"), arrow-label: $dot(I)_3$, arrow-side: "right", arrow-dir: "down")
    resistor-better("rk", "M3", "B3", label: (content: $r_k$, anchor: "left"))
  })
) <src-circuit-2>

Найдём комплексные сопротивления каждой ветви:
#let Z_p1 = rect(V.R1, 0)
#let Z_p2 = rect(0, -XC_calc.val)
#let Z_p3 = rect(V.rk, XL_calc.val)

#mathtype-mimic[
  $ dot(Z)_1 &= R_1 = #_fmt(V.R1) " Ом". $
  $ dot(Z)_2 &= -j X_C = -j #_fmt(XC_calc.val) " Ом". $
  $ dot(Z)_3 &= r_k + j X_L = #_fmt(V.rk) + j #_fmt(XL_calc.val) " Ом". $
]

Найдём входное комплексное сопротивление цепи:
#let Y1 = div(rect(1, 0), Z_p1)
#let Y2 = div(rect(1, 0), Z_p2)
#let Y3 = div(rect(1, 0), Z_p3)
#let Y_eq = add(add(Y1, Y2), Y3)
#let Z_eq = div(rect(1, 0), Y_eq)

#mathtype-mimic[
  $ dot(Z)_123 = 1 / (1/dot(Z)_1 + 1/dot(Z)_2 + 1/dot(Z)_3) = #display-complex(Z_eq).both " Ом". $
]

#let I1_p_calc = calc-ohms-law(U, Z_p1)
#let I2_p_calc = calc-ohms-law(U, Z_p2)
#let I3_p_calc = calc-ohms-law(U, Z_p3)

#block(breakable: false)[
Найдём токи в ветвях по закону Ома:
#mathtype-mimic[
  $ dot(I)_1 &= dot(U) / dot(Z)_1 = #_fmt(U_value) / (#_fmt(V.R1)) = #display-complex(I1_p_calc.val-mA).polar " мА"; $
  $ dot(I)_2 &= dot(U) / dot(Z)_2 = #_fmt(U_value) / (-j #_fmt(XC_calc.val)) = #display-complex(I2_p_calc.val-mA).polar " мА"; $
  $ dot(I)_3 &= dot(U) / dot(Z)_3 = #_fmt(U_value) / (#_fmt(V.rk) + j #_fmt(XL_calc.val)) = #display-complex(I3_p_calc.val-mA).polar " мА". $
]
]

Найдём входной комплексный ток как сумму токов в ветвях и сравним с результатом по закону Ома:
#let I_sum_mA = add(add(I1_p_calc.val-mA, I2_p_calc.val-mA), I3_p_calc.val-mA)
#let I_ohm = calc-ohms-law(U, Z_eq)

#mathtype-mimic[
  $ dot(I) &= dot(I)_1 + dot(I)_2 + dot(I)_3 = $
  $ &= (#display-complex(I1_p_calc.val-mA).rect) + (#display-complex(I2_p_calc.val-mA).rect) + (#display-complex(I3_p_calc.val-mA).rect) = $
  $ &= #display-complex(I_sum_mA).polar " мА". $
]

#mathtype-mimic[
  $ dot(I) = dot(U) / dot(Z)_123 = #_fmt(U_value) / (#display-complex(Z_eq).rect) = #display-complex(I_ohm.val-mA).polar " мА". $
]

// ПРОВЕРКА (для себя) через эквивалентную проводимость
// #let Y1 = rect(1 / V.R1, 0)
// #let Y2 = rect(0, 1 / XC_calc.val)
// #let Y3_denom = calc.pow(V.rk, 2) + calc.pow(XL_calc.val, 2)
// #let Y3 = rect(V.rk / Y3_denom, -XL_calc.val / Y3_denom)
// #let Y_eq = add(add(Y1, Y2), Y3)
// #let I_check = mul(U, Y_eq)
// #let I_check_mA = polar(I_check.mag * 1000, I_check.ang)
// #mathtype-mimic[
//   $ dot(I)_"пров" = dot(U) dot Y_"eq" = #display-complex(I_check_mA).both " мА". $
// ]

// Извлекаем полярные значения для таблицы
#let I1_pp = I1_p_calc.val-mA
#let I2_pp = I2_p_calc.val-mA
#let I3_pp = I3_p_calc.val-mA
#let I_pp = I_ohm.val-mA // Берем итоговый ток для таблицы

#let calc_row_par = (
  I_pp.mag, I_pp.ang,
  I1_pp.mag, I1_pp.ang,
  I2_pp.mag, I2_pp.ang,
  I3_pp.mag, I3_pp.ang
)

#figure(
  caption: [Результаты для параллельной цепи],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Цепь\ на\ рис.\ 3.6],
      table.cell(colspan: 2)[$I$],
      table.cell(colspan: 2)[$I_1$],
      table.cell(colspan: 2)[$I_2$],
      table.cell(colspan: 2)[$I_3$],
      [$I$,\ мА], [$psi_I$,\ град.],
      [$I_1$,\ мА], [$psi_1$,\ град.],
      [$I_2$,\ мА], [$psi_2$,\ град.],
      [$I_3$,\ мА], [$psi_3$,\ град.]
    ),

    [Расчет], ..format-cells(..calc_row_par, dec: 3),
    [Опыт], ..((hide("......."),) * 8)
  )
) <res-table-2>

== Разветвленная цепь

Схема электрической цепи для смешанного (разветвленного) соединения элементов для вариантов 3 и 4 представлена на рисунке @src-circuit-3.

#lab-figure(
  above: 1em,
  caption: [Схема для исследования смешанного соединения элементов],
  circuit-better(scale-factor: 80%, {
    import zap: *

    node-better("T0", (0, 6), visible: false)
    node-better("T1", (5, 6), visible: true)
    node-better("T2", (9, 6), visible: false)

    node-better("B0", (0, 0), visible: true)
    node-better("B1", (5, 0), visible: true)
    node-better("B2", (9, 0), visible: true)

    open-branch-better("U_in", "T0", "B0", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    wire("T0", (0.5, 6))
    current-arrow("I1", (0.5, 6), (2.5, 6), arrow-label: $dot(I)_1$, arrow-side: "top")
    resistor-better("R1", (2.5, 6), "T1", label: (content: $R_1$, anchor: "bottom"), arrow-label: $dot(U)_1$, arrow-side: "top", arrow-dir: "right")

    current-arrow("I2", "T1", (5, 4.5), arrow-label: $dot(I)_2$, arrow-side: "right", arrow-dir: "down")
    resistor-better("R2", (5, 4.5), "B1", label: (content: $R_2$, anchor: "left"), arrow-label: $dot(U)_2$, arrow-side: "right", arrow-dir: "down")

    capacitor-better("C", "T1", "T2", label: (content: $C$, anchor: "bottom"), arrow-label: $dot(U)_C$, arrow-side: "top", arrow-dir: "right")

    resistor-better("R3", "T2", (9, 2), label: (content: $R_3$, anchor: "right"))
    current-arrow("I3", (9, 2), "B2", arrow-label: $dot(I)_3$, arrow-side: "left", arrow-dir: "down")

    wire("B0", "B2")
  })
) <src-circuit-3>

Найдём комплексные сопротивления ветвей. Согласно варианту, в цепи отсутствуют элементы $L$ и $r_k$, поэтому сопротивления имеют вид:
#let Z_m1 = rect(V.R1, 0)
#let Z_m2 = rect(V.R2, 0)
#let Z_m3 = rect(V.R3, -XC_calc.val)

#mathtype-mimic[
  $ dot(Z)_1 &= R_1 = #_fmt(V.R1) " Ом"; $
  $ dot(Z)_2 &= R_2 = #_fmt(V.R2) " Ом"; $
  $ dot(Z)_3 &= R_3 - j X_C = #_fmt(V.R3) - j #_fmt(XC_calc.val) " Ом". $
]

Вычислим эквивалентное сопротивление разветвленного участка $dot(Z)_23$ и общее эквивалентное сопротивление цепи $dot(Z)$:
#let Z_m23_num = mul(Z_m2, Z_m3)
#let Z_m23_den = add(Z_m2, Z_m3)
#let Z_m23 = div(Z_m23_num, Z_m23_den)
#let Z_m_eq = add(Z_m1, Z_m23)

#mathtype-mimic[
  $ dot(Z)_23 &= (dot(Z)_2 dot dot(Z)_3) / (dot(Z)_2 + dot(Z)_3) = #display-complex(Z_m23).both " Ом"; $
  $ dot(Z) &= dot(Z)_1 + dot(Z)_23 = #display-complex(Z_m_eq).both " Ом". $
]

#let I1_m = div(U, Z_m_eq)
#let U23_m = mul(I1_m, Z_m23)
#let I2_m = div(U23_m, Z_m2)
#let I3_m = div(U23_m, Z_m3)

#let I1_pp_m = to-polar(I1_m)
#let I2_pp_m = to-polar(I2_m)
#let I3_pp_m = to-polar(I3_m)

#block(breakable: false)[
Определим токи в ветвях:
#mathtype-mimic[
  $ dot(I)_1 &= dot(U) / dot(Z) = #_fmt(U_value) / (#display-complex(Z_m_eq).polar) = #display-complex(polar(I1_pp_m.mag * 1000, I1_pp_m.ang)).polar " мА"; $
  $ dot(U)_2 &= dot(U)_23 = dot(I)_1 dot dot(Z)_23 = #display-complex(U23_m).polar " В"; $
  $ dot(I)_2 &= dot(U)_23 / dot(Z)_2 = #display-complex(polar(I2_pp_m.mag * 1000, I2_pp_m.ang)).polar " мА"; $
  $ dot(I)_3 &= dot(U)_23 / dot(Z)_3 = #display-complex(polar(I3_pp_m.mag * 1000, I3_pp_m.ang)).polar " мА". $
]
]

Найдём комплексные напряжения на всех элементах цепи:
#let U1_m = mul(I1_m, Z_m1)
#let U2_m = U23_m
#let U3_m = mul(I3_m, rect(V.R3, 0))
#let UC_m = mul(I3_m, rect(0, -XC_calc.val))

#let U1_pp_m = to-polar(U1_m)
#let U2_pp_m = to-polar(U2_m)
#let U3_pp_m = to-polar(U3_m)
#let UC_pp_m = to-polar(UC_m)

#mathtype-mimic[
  $ dot(U)_1 &= dot(I)_1 dot R_1 = #display-complex(U1_m).polar " В"; $
  $ dot(U)_3 &= dot(I)_3 dot R_3 = #display-complex(U3_m).polar " В"; $
  $ dot(U)_C &= dot(I)_3 dot (-j X_C) = #display-complex(UC_m).polar " В". $
]

Составим баланс мощностей:
#let I1_conj = rect(to-rect(I1_m).re, -to-rect(I1_m).im)
#let S_source = mul(U, I1_conj)
#let P_load = I1_pp_m.mag * I1_pp_m.mag * V.R1 + I2_pp_m.mag * I2_pp_m.mag * V.R2 + I3_pp_m.mag * I3_pp_m.mag * V.R3
#let Q_load = -(I3_pp_m.mag * I3_pp_m.mag * XC_calc.val)
#let S_load = rect(P_load, Q_load)
#let cos_phi = P_load / S_source.mag

#mathtype-mimic[
  $ dot(S)_"ист" &= dot(U) dot(I)_1^* = #display-complex(U).polar dot #display-complex(to-polar(I1_conj)).polar = #display-complex(S_source).rect " ВА"; $
  $ P_"потр" &= I_1^2 R_1 + I_2^2 R_2 + I_3^2 R_3 = #_fmt(P_load) " Вт"; $
  $ Q_"потр" &= -I_3^2 X_C = #_fmt(Q_load) " ВА"; $
//   $ cos phi &= P_"потр" / S_"ист" = #_fmt(P_load) / #_fmt(S_source.mag) = #_fmt(cos_phi). $
]

// ПРОВЕРКА ЗАКОНОВ КИРХГОФА И БАЛАНСА (для самоконтроля, закомментировано)
// #let I_check_kcl = sub(I1_m, add(I2_m, I3_m))
// #let U_check_kvl1 = sub(U, add(U1_m, U2_m))
// #let U_check_kvl2 = sub(U2_m, add(UC_m, U3_m))
// #mathtype-mimic[
//   $ dot(I)_1 - (dot(I)_2 + dot(I)_3) = #_fmt(I_check_kcl.re) + j #_fmt(I_check_kcl.im) " А" $
//   $ dot(U) - (dot(U)_1 + dot(U)_2) = #_fmt(U_check_kvl1.re) + j #_fmt(U_check_kvl1.im) " В" $
//   $ dot(U)_2 - (dot(U)_C + dot(U)_3) = #_fmt(U_check_kvl2.re) + j #_fmt(U_check_kvl2.im) " В" $
//   $ dot(S)_"ист" - dot(S)_"потр" = #_fmt(to-rect(S_source).re - S_load.re) + j #_fmt(to-rect(S_source).im - S_load.im) " В"dot"А" $
// ]

#let calc_row_mixed = (
  I1_pp_m.mag * 1000, I1_pp_m.ang,
  I2_pp_m.mag * 1000, I2_pp_m.ang,
  I3_pp_m.mag * 1000, I3_pp_m.ang,
  U1_pp_m.mag, U2_pp_m.mag, U3_pp_m.mag,
  UC_pp_m.mag, UC_pp_m.ang
)

#pagebreak()

#figure(
  caption: [Результаты для разветвленной цепи],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Разветв-\ ленная\ цепь],
      table.cell(colspan: 2)[$I_1$],
      table.cell(colspan: 2)[$I_2$],
      table.cell(colspan: 2)[$I_3$],
      table.cell(rowspan: 2)[$U_1$,\ В],
      table.cell(rowspan: 2)[$U_2$,\ В],
      table.cell(rowspan: 2)[$U_3$,\ В],
//       table.cell(colspan: 2)[$U_k$],
      table.cell(colspan: 2)[$U_C$],
      // Вторая строка шапки
      [$I_1$,\ мА], [$psi_1$,\ град.],
      [$I_2$,\ мА], [$psi_2$,\ град.],
      [$I_3$,\ мА], [$psi_3$,\ град.],
//       [$U_k$,\ В], [$psi_(U k)$,\ град.],
      [$U_C$,\ В], [$psi_(U C)$,\ град.]
    ),

    // Поворачиваем отформатированные расчетные значения
    [Расчет], ..rotate-cells(..format-cells(..calc_row_mixed, dec: 3)),

    // Строка для эксперимента (13 пустых ячеек).
    // Длинная скрытая строка при повороте растянет высоту всей ячейки.
    [Опыт], ..rotate-cells(..((hide("............"),) * 11))
  )
) <res-table-3>