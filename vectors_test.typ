// --- РАСЧЁТ КООРДИНАТ ДЛЯ ДИАГРАММЫ ---
// Так как ток очень мал (порядка 0.025 А), введем масштаб для визуализации
#let i_scale = 150
#let u1-rect = to-rect(U_1_calc.val)
#let uk-rect = to-rect(U_K_calc.val)
#let uc-rect = to-rect(U_C_calc.val)
#let i-rect = to-rect(I_calc.val)

// Рассчитываем координаты конца каждого вектора (правило многоугольника)
#let p0 = (0, 0)
#let p_u1 = (u1-rect.re, u1-rect.im)
#let p_uk = (p_u1.at(0) + uk-rect.re, p_u1.at(1) + uk-rect.im)
#let p_uc = (p_uk.at(0) + uc-rect.re, p_uk.at(1) + uc-rect.im) // Должно совпасть с (5, 0)!
#let p_i  = (i-rect.re * i_scale, i-rect.im * i_scale)

#lab-figure(
  caption: [Векторная диаграмма напряжений и тока для последовательной цепи],
  vector-diagram(
    currents: (
      (start: p0, end: p_i, label: $dot(I) #hide("-")$, anchor: "north-east"),
    ),
    voltages: (
      (start: p0,   end: p_u1, label: $dot(U)_1$, anchor: "north"),
      (start: p_u1, end: p_uk, label: $dot(U)_k$, anchor: "south-east"),
      (start: p_uk, end: p_uc, label: $dot(U)_C$, anchor: "west"),
      // Суммарный вектор напряжения U из начала координат
      (start: p0,   end: p_uc, label: $dot(U)$,   anchor: "south-west", dashed: true),
    ),
    axes: (x: 6, y: 12) // Ось X до 6В, Ось Y от -6В до +6В
  )
)
