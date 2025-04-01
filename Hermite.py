import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import BarycentricInterpolator, CubicHermiteSpline

# 給定的數據
T = np.array([0, 3, 5, 8, 13])  # 時間 t
D = np.array([0, 200, 375, 620, 990])  # 距離 D(t)
V = np.array([75, 77, 80, 74, 72])  # 速度 V(t) = D'(t)

# 建立 Hermite 插值
hermite_interpolator = CubicHermiteSpline(T, D, V)

# (a) 預測 t = 10 時的 D 和 V
t_target = 10
D_10 = hermite_interpolator(t_target)
V_10 = hermite_interpolator.derivative()(t_target)

print(f"(a) D(10) = {D_10:.2f} ft")
print(f"(a) V(10) = {V_10:.2f} ft/s")

# (b) 找出車速是否超過 55 mi/h (80.67 ft/s)
speed_limit = 80.67

# 建立細緻時間點來尋找速度超過 80.67 ft/s 的時刻
t_fine = np.linspace(min(T), max(T), 1000)
V_fine = hermite_interpolator.derivative()(t_fine)

# 找出第一次超過 80.67 ft/s 的時間點
exceed_indices = np.where(V_fine > speed_limit)[0]
if exceed_indices.size > 0:
    t_exceed = t_fine[exceed_indices[0]]
    print(f"(b) 車速首次超過 55 mi/h 時間: t ≈ {t_exceed:.2f} 秒")
else:
    print("(b) 車速從未超過 55 mi/h")

# (c) 找最大車速
V_max = np.max(V_fine)
t_max_speed = t_fine[np.argmax(V_fine)]

print(f"(c) 預測最大車速: {V_max:.2f} ft/s")
print(f"(c) 最大車速發生在 t ≈ {t_max_speed:.2f} 秒")

# 畫圖顯示速度變化
plt.figure(figsize=(8, 5))
plt.plot(t_fine, V_fine, label="速度 V(t)", color='b')
plt.axhline(speed_limit, color='r', linestyle="--", label="55 mi/h (80.67 ft/s)")
plt.axvline(t_exceed, color='g', linestyle="--", label=f"t ≈ {t_exceed:.2f} s")
plt.xlabel("時間 (秒)")
plt.ylabel("速度 (ft/s)")
plt.title("速度變化圖")
plt.legend()
plt.grid()
plt.show()
