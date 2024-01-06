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
N = 0:6400; % Numero de elementos de RIS
Aeff = 0.005^2; % Área efectiva de un elemento
A_RIS = (0.005*80)^2; % Área efectiva de la RIS
NSD = -174; % Densidad espectral de ruido en dBm/Hz

% Cálculo potencia de ruido del sistema
Pn = NSD + 10*log10(BW);

% SNR limitante del servicio utilizado
C = 2.35*10^9; % Tasa de bits del servicio que ofrecemos (bits/s)
SNR_limit = 2^(C/BW) - 1; % SNR limitante del servicio que ofrecemos


%% Recogida de datos de las figuras
% Recoger datos de la ganancia de la figura esc_azim (ganancia directa multicast)
ruta_figura = 'esc4_cosq_EB.fig'; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
% La figura contiene dos celdas pero solo necesitamos la curva de interés
Cell_Theta = get(line, 'XData'); 
Theta = Cell_Theta{1,1};% Valores de ángulos de azimuth
Cell_G_BS = get(line, 'YData'); 
G_BS = Cell_G_BS{2,1};% Valores de ganancia de la RIS

% Recoger datos de la ganancia de la figura esc_azim (ganancia reflejada multicast)
ruta_figura = 'esc4_azim_IRS.fig'; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
HAzim_angle = get(line, 'XData'); % Valores de ángulos de azimuth
G_RA_azim = get(line, 'YData'); % Valores de ganancia de la RIS

% Recoger datos de la ganancia de la figura esc_pincel (ganancia reflejada unicast)
ruta_figura = 'esc4_pincel_IRS.fig'; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
Cell_HAzim_angle_Unicast = get(line, 'XData'); % Valores de ángulos de azimuth
HAzim_angle_Unicast = Cell_HAzim_angle_Unicast{1,1};
Cell_G_RA_azim_Unicast = get(line, 'YData'); % Valores de ganancia de la RIS
G_RA_azim_Unicast = Cell_G_RA_azim_Unicast{2,1};


%% Cálculo distancias limitantes multicast
% Establecer distancias hacia cada usuario desde la RIS ,la distancia de
% la antena transmisora a la RIS en metros
d_txtoRIS = 8.64;
% Hallar la distancia a usuario limitante en caso multicast
% Caso directo
angle_index = find(abs(Theta) < 14);
limit_user_1 = find(G_BS == min(G_BS(angle_index))); % indice usuario con menor ganancia dentro del haz
Theta_BS = abs(Theta(limit_user_1)); % Ángulo directo desde BS station
PL = SNR_limit - (P_BS + G_BS(limit_user_1) + G_UE) + Pn;
d_txtoUser = lambda/(10^(PL/20)*4*pi); % Distancia TX-User

% Caso reflejado
azim_angle = [45 50]; % Ángulos de azimuth inicial y final haz reflejado
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

% Calcular gananacia de RIS
G_RA = max(G_RA_azim_Unicast);

% Ángulo de ganancia máxima
index_value = G_RA_azim_Unicast == max(G_RA_azim_Unicast);
azim_angle = HAzim_angle_Unicast(index_value);
elev_angle = 0; % Invariante en nuestro escenario

% Cálculo numero de usuarios reflejados
NT_User_Rfl_dB = P_BS - (SNR_limit - G_RA - PL - G_UE + Pn);
NT_User_Rfl = floor(10^(NT_User_Rfl_dB/10)); % Numero de usuarios posibles

% Valor de SNR por usuario de la zona reflejada
SNRb(1) = SNR_limit;

% Calcular SNR de los usuarios a los que la antena transmite
% Establecer las pérdidas usando la ecuación de Friis
PL = 20*log10(lambda/(4*pi*d_txtoUser)); % Distancia Tx-User

% Gananncia antena de transmisión base
G_BS_max = max(G_BS);

% Cálculo numero de usuarios directos
NT_User_Dir_dB = P_BS - SNR_limit + G_BS_max + PL + G_UE - Pn;
NT_User_Dir = floor(10^(NT_User_Dir_dB/10));

SNRb(2) = SNR_limit;


% Hallar la SNR mínima que indicará el peor usuario del sistema
SNRmin = min(SNRb);

 % Eficiencia Espectral
SE = log2(1 + db2pow(SNRmin));

% Eficiencia Espectral Agregada
NT_User = NT_User_Dir + NT_User_Rfl;
ASE = NT_User*SE;


%% Comprobación resultados
SNR_Reflejada = (P_BS + G_RA + 20*log10(lambda/(4*pi*d_RIStoUser)) + G_UE) - Pn - NT_User_Rfl_dB;
SNR_Directa = (P_BS + G_BS_max + 20*log10(lambda/(4*pi*d_txtoUser)) + G_UE) - Pn - NT_User_Dir_dB;