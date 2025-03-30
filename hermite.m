clc; clear; close all;
% 第三題
% 給定的數據
T = [0, 3, 5, 8, 13];  % 時間 (秒)
D = [0, 200, 375, 620, 990]; % 距離 (英尺)
V = [75, 77, 80, 74, 72]; % 速度 (英尺/秒)

% 構造 Hermite 插值
n = length(T);
Z = zeros(1, 2*n);  % 擴展時間節點
Q = zeros(2*n, 2*n); % 差分商表

for i = 1:n
    Z(2*i-1) = T(i);
    Z(2*i) = T(i);
    Q(2*i-1,1) = D(i);
    Q(2*i,1) = D(i);
    Q(2*i,2) = V(i); % f[x_i, x_i] = V(i)
    if i > 1
        Q(2*i-1,2) = (Q(2*i-1,1) - Q(2*i-2,1)) / (Z(2*i-1) - Z(2*i-2));
    end
end

% 計算高階差分
for j = 3:2*n
    for i = 1:(2*n - j + 1)
        Q(i,j) = (Q(i+1,j-1) - Q(i,j-1)) / (Z(i+j-1) - Z(i));
    end
end

% 插值函數
syms t;
P = Q(1,1);
prod_term = 1;

for i = 2:2*n
    prod_term = prod_term * (t - Z(i-1));
    P = P + Q(1,i) * prod_term;
end

% **(a) 計算 t = 10 秒時的位置和速度**
P_t10 = double(subs(P, t, 10));
P_derivative = diff(P, t); % 求導數 (速度函數)
V_t10 = double(subs(P_derivative, t, 10));

fprintf('(a) 在 t = 10 秒時，預測位置 D = %.2f 英尺, 速度 V = %.2f 英尺/秒\n', P_t10, V_t10);

% **(b) 判斷是否超過 55 mi/h**
speed_limit = 55 * 1.46667; % 轉換成 ft/s
f = matlabFunction(P_derivative); % 轉換為數值函數
time_range = linspace(0, 13, 1000);
speed_vals = arrayfun(f, time_range);

exceed_idx = find(speed_vals > speed_limit, 1);
if ~isempty(exceed_idx)
    first_exceed_time = time_range(exceed_idx);
    fprintf('(b) 汽車在 t = %.2f 秒首次超過 55 mi/h 限速。\n', first_exceed_time);
else
    fprintf('(b) 汽車從未超過 55 mi/h 限速。\n');
end

% **(c) 預測最大速度**
[max_speed, max_idx] = max(speed_vals);
max_time = time_range(max_idx);
fprintf('(c) 預測的最大速度為 %.2f 英尺/秒，發生在 t = %.2f 秒。\n', max_speed, max_time);

% **畫圖**
figure;
plot(time_range, speed_vals, 'b', 'LineWidth', 2);
hold on;
yline(speed_limit, 'r--', 'LineWidth', 2);
plot(max_time, max_speed, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('時間 (秒)');
ylabel('速度 (英尺/秒)');
title('Hermite 插值的速度曲線');
legend('速度曲線', '55 mi/h 限速', '最大速度', 'Location', 'Best');
grid on;
