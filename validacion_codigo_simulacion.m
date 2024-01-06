close all;
clear;
clc;

%% Escenario Unicast 
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
N_Escenario = 2; % Numero de escenario a simular (4 máx)

% Cálculo potencia de ruido del sistema
Pn = NSD + 10*log10(BW);

% Establecer la distancia hacia el usuario desde la RIS  y la distancia de
% la antena transmisora a la RIS en metros
d_RIStoUser = 30;
% Distancia txtoRIS [Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
d_txtoRIS_Escenarios = [30, 51.8, 3.21, 8.64];
d_txtoRIS = d_txtoRIS_Escenarios(N_Escenario);

% Establecer ángulos de elevación, azimuth y theta en grados 
azim_angle = 0; % Ganancia máxima haz pincel
elev_angle = 0; % Invariante en nuestro escenario
% Ángulo haz estaición base de escenarios [Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
Theta_BS_Escenarios = [6.5, 5.5, 14, 14];
Theta_BS = Theta_BS_Escenarios(N_Escenario);


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

% Recoger datos de la ganancia de la figura esc_pincel (ganancia reflejada unicast)
ruta_figura_escenarios = {'esc1_pincel_IRS.fig','esc2_pincel_IRS.fig','esc3_pincel_IRS.fig','esc4_pincel_IRS.fig'};
ruta_figura = ruta_figura_escenarios{N_Escenario}; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
Cell_HAzim_angle_Unicast = get(line, 'XData'); % Valores de ángulos de azimuth
HAzim_angle_Unicast = Cell_HAzim_angle_Unicast{1,1};
Cell_G_RA_azim_Unicast = get(line, 'YData'); % Valores de ganancia de la RIS
G_RA_azim_Unicast = Cell_G_RA_azim_Unicast{2,1};


%% Balance de enlace (Datos ofrecidos por haz pincel)
% Establecer las pérdidas usando la ecuación de Friis
PL = 20*log10(lambda/(4*pi*d_RIStoUser)); % Distancia RIS-User

% Calcular gananacia de RIS
G_RA = max(G_RA_azim_Unicast);

% Ángulo de ganancia máxima
index_value = G_RA_azim_Unicast == max(G_RA_azim_Unicast);
azim_angle = HAzim_angle_Unicast(index_value);
elev_angle = 0; % Invariante en nuestro escenario

% Valor de SNR del usuario de la zona reflejada
SNRb(1)= (P_BS + G_RA + PL + G_UE) - Pn;


%% Balance de enlace (Datos ofrecidos por modelado de Bjorson)
% Pérdidas de propagación
alpha = 20*log10(lambda/(4*pi*d_txtoRIS)); % Pathloss a RIS
beta = 20*log10(lambda/(4*pi*d_RIStoUser)); % Pathloss desde RIS
% gamma = 20*log10(N); % Ganancia RIS
gamma = 20*log10((4*pi/(lambda^2))*(0.4*0.4)); % Ganancia de las diapositivas
% reflectarray más el Scan Loss

% Encontrar valor de ganancia en función del Theta_BS
dist = abs(Theta - abs(Theta_BS)); % Calcula la diferencia
% absoluta entre el valor deseado y todos los elementos del vector
index_value = find(dist == min(dist));
% Ganancia desde la estación base
G_BS_Rfl = G_BS(index_value);

% Valor de SNR del usuario de la zona reflejada
SNRb(2) = (P_BS + G_BS_Rfl + beta + alpha + gamma + G_UE) - Pn;


%% Comparación Ganancia RIS del haz pincel y Ganancia RIS ideal caso Bjorson
% La ganancia del haz pincel abarca G_BS, PL_BStoRIS y G_RIS
SL = 2.5;
G_RIS_Pincel = G_RA - 20*log10(lambda/(4*pi*d_txtoRIS)) - G_BS(index_value);
G_RIS_Bjorson = gamma;

fprintf('La ganancia de la RIS en el caso teórico es  %d dB.\n', G_RIS_Bjorson);
fprintf('La ganancia de la RIS en el caso se haz pincel es  %d dB.\n', G_RIS_Pincel);
fprintf('Por lo tanto la diferencia entre nuestro modelado y el ideal es %d dB.\n', (G_RIS_Bjorson - G_RIS_Pincel));