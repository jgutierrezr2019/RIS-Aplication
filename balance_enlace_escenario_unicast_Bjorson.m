close all;
clear;
clc;


%% Escenario Unicast (Base: Esceario RIS posición cercana gran obstáculo)
% Datos inicales
P_BS = 30; % Potencia transmitida de la estacion base en dBm
G_UE = 1; % Ganancia de usuario
c = 3*10^8; % Velocidad de la luz en m/s
BW = 1e9; % Ancho de banda en GHz
f = 27*10^9; % Frecuencia de 27 GHz
lambda = c/f;% Longitud de onda
N = 6400; % Numero de elementos de RIS
Aeff = 0.005^2; % Área efectiva de un elemento
A_RIS = (0.005*80)^2; % Área efectiva de la RIS
NSD = -174; % Densidad espectral de ruido en dBm/Hz
N_Escenario = 4; % Numero de escenario a simular (4 máx)

% Cálculo potencia de ruido del sistema
Pn = NSD + 10*log10(BW);

% SNR limitante del servicio utilizado
C = 2.35*10^9; % Tasa de bits del servicio que ofrecemos (bits/s)
SNR_limit = 2^(C/BW) - 1; % SNR limitante del servicio que ofrecemos


%% Recogida de datos de las figuras
% Recoger datos de la ganancia de la figura esc_azim (ganancia directa multicast)
ruta_figura_escenarios = {'esc1_cosq_EB.fig','esc2_cosq_EB.fig','esc3_cosq_EB.fig','esc4_cosq_EB.fig'};
ruta_figura = ruta_figura_escenarios{N_Escenario}; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
% La figura contiene dos celdas pero solo necesitamos la curva de interés
Cell_Theta = get(line, 'XData'); 
Theta = Cell_Theta{1,1};% Valores de ángulos de azimuth
Cell_G_BS = get(line, 'YData'); 
G_BS = Cell_G_BS{2,1};% Valores de ganancia de la RIS

% Recoger datos de la ganancia de la figura esc_azim (ganancia reflejada multicast)
ruta_figura_escenarios = {'esc1_azim_IRS.fig','esc2_azim_IRS.fig','esc3_azim_IRS.fig','esc4_azim_IRS.fig'};
ruta_figura = ruta_figura_escenarios{N_Escenario}; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
HAzim_angle = get(line, 'XData'); % Valores de ángulos de azimuth
G_RA_azim = get(line, 'YData'); % Valores de ganancia de la RIS


%% Cálculo distancias limitantes multicast
% Establecer distancias hacia cada usuario desde la RIS ,la distancia de
% la antena transmisora a la RIS en metros
% Distancia txtoRIS [Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
d_txtoRIS_Escenarios = [30, 51.8, 3.21, 8.64];
d_txtoRIS = d_txtoRIS_Escenarios(N_Escenario);
% Hallar la distancia a usuario limitante en caso multicast
% Caso directo
Theta_BS_Escenarios = [6.5, 5.5, 14, 14];
angle_index = find(abs(Theta) < Theta_BS_Escenarios(N_Escenario));
limit_user_1 = find(G_BS == min(G_BS(angle_index))); % indice usuario con menor ganancia dentro del haz
Theta_BS = abs(Theta(limit_user_1)); % Ángulo directo desde BS station
PL = SNR_limit - (P_BS + G_BS(limit_user_1) + G_UE) + Pn;
d_txtoUser = lambda/(10^(PL/20)*4*pi); % Distancia TX-User

% Caso reflejado
azim_angle_escenarios = {[42.5 47.5], [33 38], [47.5 52.5], [45 50]};
azim_angle = azim_angle_escenarios{N_Escenario}; % Ángulos de azimuth inicial y final haz reflejado
dist = abs(HAzim_angle - abs(azim_angle(1)));
fst_index_value = find(dist == min(dist));
dist = abs(HAzim_angle - abs(azim_angle(end)));
lst_index_value = find(dist == min(dist));
index_range = fst_index_value:1:lst_index_value; % Ángulos haz reflejado
limit_user_2 = find(G_RA_azim == min(G_RA_azim(index_range))); % indice 
% usuario con menor ganancia dentro del haz
G_RA_Mul = G_RA_azim(limit_user_2);
PL = SNR_limit - (P_BS + G_RA_Mul + G_UE) + Pn;
% Establecer las pérdidas usando la ecuación de Friis
d_RIStoUser = lambda/(10^(PL/20)*4*pi); % Distancia RIS-User



%% Balance de enlace
% Establecer las pérdidas usando la ecuación de Friis
PL = 20*log10(lambda/(4*pi*d_RIStoUser)); % Distancia RIS-User

% Pérdidas de propagación
alpha = 10*log10(Aeff/(4*pi*d_txtoRIS^2)); %A RIS
beta = 10*log10(Aeff/(4*pi*d_RIStoUser^2)); %Desde RIS
gamma = 20*log10(N); %Loss en RIS (ideal = 1 U.N.)

% Gannacia desde la estación base
% Ángulo haz directo que incide sobre RIS
angle_inc = Theta_BS_Escenarios(N_Escenario);
elev_angle = 0; % Invariante en nuestro escenario
% Encontrar valor de ganancia en función del Theta_BS
dist = abs(Theta - abs(angle_inc)); % Calcula la diferencia
% absoluta entre el valor deseado y todos los elementos del vector
index_value = find(dist == min(dist));
% Ganancia desde la estación base
G_BS_Rfl = G_BS(index_value);

% Cálculo numero de usuarios reflejados
NT_User_Rfl_dB = P_BS - (SNR_limit - G_BS_Rfl - beta - alpha - gamma - G_UE + Pn);
NT_User_Rfl = floor(10^(NT_User_Rfl_dB/10)); % Numero de usuarios posibles

% Valor de SNR por usuario de la zona reflejada
SNRb(1) = SNR_limit;

% Calcular SNR de los usuarios a los que la antena transmite
% Establecer las pérdidas usando la ecuación de Friis
PL = 20*log10(lambda/(4*pi*d_txtoUser)); % Distancia Tx-User
    
% Encontrar valor de ganancia en función del Theta_BS
dist = abs(Theta - abs(Theta_BS)); % Calcula la diferencia
% absoluta entre el valor deseado y todos los elementos del vector
index_value = find(dist == min(dist));
NT_User_Dir = 1;

SNRb(2) = (P_BS + G_BS(index_value(1)) + PL + G_UE) - Pn;


% Hallar la SNR mínima que indicará el peor usuario del sistema
SNRmin = min(SNRb);

 % Eficiencia Espectral
SE = log2(1 + db2pow(SNRmin));

% Eficiencia Espectral Agregada
NT_User = NT_User_Dir + NT_User_Rfl;
ASE = NT_User*SE;


%% Comprobación resultados
SNR_Reflejada = (P_BS + G_BS_Rfl + beta + alpha + gamma + G_UE) - Pn - NT_User_Rfl_dB;
SNR_Directa = (P_BS + G_BS(index_value(1)) + 20*log10(lambda/(4*pi*d_txtoUser)) + G_UE) - Pn;