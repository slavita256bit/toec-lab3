#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:1.3.0": *
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
#let U = polar(U_value, 0) // Входное напряжение U = 10e^(j0) В

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

Исходные данные варианта #V.VARIANT представлены в таблице @src-table-1, схема электрической цепи представлена на рисунке @src-circuit-1.

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
  caption: [Схема для исследования последовательного колебательного контура],
  above: -1em,
  gap: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *

    // Опорные узлы
    node-better("1", (0, 8), label: (content: "1", anchor: "top"), visible: true)
    node-better("TR", (6, 8), visible: false)
    node-better("nL", (6, 5.5), visible: false)
    node-better("2", (6, 3), label: (content: "2", anchor: "left"), visible: true)
    node-better("3", (6, 0), label: (content: "3", anchor: "bottom"), visible: true)
    node-better("4", (0, 0), label: (content: "4", anchor: "bottom"), visible: true)

    // Входное напряжение
    open-branch-better("U_in", "4", "1", label: $dot(U)$, arrow-side: "left", arrow-dir: "up")

    // Верхний провод
    wire("1", (2, 8))
    current-arrow("I_arrow", (2, 8), (4, 8), arrow-label: $dot(I)$, arrow-side: "top", arrow-dir: "forward")
    wire((4, 8), "TR")

    // Правая ветвь: Катушка и Конденсатор
    inductor-better("L", "TR", "nL", label: (content: $L$, anchor: "west"), arrow-label: $dot(U)_k$, arrow-side: "right", arrow-dir: "forward")
    resistor-better("rk", "nL", "2", label: (content: $r_k$, anchor: "west"))
    capacitor-better("C", "2", "3", label: (content: $C$, anchor: "west"), arrow-label: $dot(U)_C$, arrow-side: "right", arrow-dir: "forward")

    // Нижняя ветвь
    resistor-better("R1", "3", "4", label: (content: $R_1$, anchor: "top"), arrow-label: $dot(U)_1$, arrow-side: "bottom", arrow-dir: "forward")
  })
) <src-circuit-1>

#pagebreak()

// --- Вычисления и отображение ---
Определяем индуктивное и емкостное сопротивления цепи:
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

Определяем комплексные напряжения:
#let Z_k = rect(V.rk, XL_calc.val)
#let U_K_calc = calc-voltage-drop(I_calc.val, Z_k, U-symbol: $U_K$)
#U_K_calc.display

#let Z_C = rect(0, -XC_calc.val)
#let U_C_calc = calc-voltage-drop(I_calc.val, Z_C, U-symbol: $U_C$)
#U_C_calc.display

#let Z_1 = rect(V.R1, 0)
#let U_1_calc = calc-voltage-drop(I_calc.val, Z_1, U-symbol: $U_1$)
#U_1_calc.display
