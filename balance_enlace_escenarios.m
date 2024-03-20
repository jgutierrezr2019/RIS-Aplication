close all;
clear;
clc;

%% Simulación de escenario
% Elegir escenario y servicio limitante
N_Escenario = 4; % Numero de escenario:[Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
N_Servicio = 5; % Numero de escenario:[ES_VR,El_VR,ADV_VR,EXT_VR_sp,EXT_VR_int]

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
NT_User = 50; % Número total de usuarios


% Cálculo potencia de ruido del sistema
Pn = NSD + 10*log10(BW);

% SNR limitante del servicio utilizado
C_Servicios = [0.025 0.1 0.4 1 2.35]*10^9;
C = C_Servicios(N_Servicio); % Tasa de bits del servicio que ofrecemos (bits/s)
SNR_limit = 2^(C/BW) - 1; % SNR limitante del servicio que ofrecemos
SNR_limit = 10*log10(SNR_limit);

% Establecer ángulos de elevación y azimuth en grados 
% dirigidos a cada usuario (Componentes a misma altura)
azim_angle_escenarios = [42.5 43 44 45 46 47 47.5;
                         33 33.5 34.5 35.5 36.5 37.5 38;
                         47.5 48 49 50 51 52 52.5;
                         45 45.5 46.5 47.5 48.5 49.5 50];
azim_angle = azim_angle_escenarios(N_Escenario,:); % Diferentes ángulos de azimuth
elev_angle = 0; % Invariante en nuestro escenario


%% Recogida de datos de las figuras
% Recoger datos de la ganancia de la figura esc_azim
ruta_figura_escenarios = {'esc1_azim_IRS.fig','esc2_azim_IRS.fig','esc3_azim_IRS.fig','esc4_azim_IRS.fig'};
ruta_figura = ruta_figura_escenarios{N_Escenario}; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
HAzim_angle = get(line, 'XData'); % Valores de ángulos de azimuth
G_RA_azim = get(line, 'YData'); % Valores de ganancia de la RIS

% Recoger datos de la ganancia de la figura esc_azim
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


%% Cálculo zonas de cobertura
% Zona de cobertura del primer grupo

% Hallar la distancia a usuario limitante
Theta_BS_Escenarios = [6.5, 5.5, 14, 14];
angle_index = find(abs(Theta) < Theta_BS_Escenarios(N_Escenario));
limit_user_1 = find(G_BS == min(G_BS(angle_index))); % indice usuario con menor ganancia dentro del haz
angle_limit_user_1 = abs(Theta(limit_user_1)); % ángulo usuario limitante
PL = SNR_limit - (P_BS + G_BS(limit_user_1) + G_UE) + Pn;
dist_limitante_1= lambda/(10^(PL/20)*4*pi); % Distancia limitante primer grupo
    
% Cálculo área de cobertura
% Suponiendo el área como un triángulo
angle_in_Rad = deg2rad(angle_limit_user_1); % Ángulo de triángulo de zona de cobertura
heigth = abs(cos(angle_in_Rad)*dist_limitante_1); % Cálculo de altura
base = abs((heigth*sin(angle_in_Rad))*2); % Cálculo de base
area_group_1 = base*heigth/2; % Cálculo del área del primer grupo
    
% Zona de cobertura del segundo grupo
    
% Hallar la distancia a usuario limitante
dist = abs(HAzim_angle - abs(azim_angle(1)));
fst_index_value = find(dist == min(dist));
dist = abs(HAzim_angle - abs(azim_angle(end)));
lst_index_value = find(dist == min(dist));
index_range = fst_index_value:1:lst_index_value; % Ángulos haz reflejado
limit_user_2 = find(G_RA_azim == min(G_RA_azim(index_range))); % indice 
% usuario con menor ganancia dentro del haz
angle_reflected_haz = [-5 -4 -2 0 2 4 5]; % Ángulos de apertura de haz en orden
angle_azimuth_haz = HAzim_angle(limit_user_2); 
angle_index = find(azim_angle == angle_azimuth_haz);
angle_limit_user_2 = angle_reflected_haz(angle_index);
G_RA = G_RA_azim(limit_user_2);
PL = SNR_limit - (P_BS + G_RA + G_UE) + Pn;
% Establecer las pérdidas usando la ecuación de Friis
dist_limitante_2 = lambda/(10^(PL/20)*4*pi); % Distancia Tx-User
    
% Cálculo área de cobertura
% Suponiendo el área como un triángulo
if angle_limit_user_2 == 0
    angle_in_Rad = deg2rad(angle_reflected_haz(end)); % Ángulo de triángulo de zona de cobertura
    heigth = dist_limitante_2; % Cálculo de la altura
    hipotenusa = abs(heigth/cos(angle_in_Rad));
    base = abs((dist_limitante_2*sin(angle_in_Rad))*2); % Cálculo de la base
else
    angle_in_Rad = deg2rad(angle_limit_user_2); % Ángulo de triángulo de zona de cobertura
    heigth = abs(cos(angle_in_Rad)*dist_limitante_2); % Cálculo de la altura
    base = abs((heigth*sin(deg2rad(angle_reflected_haz(end)))*2)); % Cálculo de la base
end
area_group_2 = base*heigth/2; % Cálculo del área del segundo grupo

    
% Eficiencia Espectral
SE = log2(1 + db2pow(SNR_limit));


% Eficiencia Espectral Agregada
ASE = NT_User*SE;

% Resultados
fprintf('Para una SNR limitante de %d dB:\n', SNR_limit);
fprintf('El escenario %d tiene distancia limitante de %d m ', N_Escenario, dist_limitante_1);
fprintf('para la zona directa con ángulo de haz %dº y ', angle_limit_user_1);
fprintf('con Área de cobertura %d m^2 y ', area_group_1);
fprintf('distancia limitante de %d m para la zona reflejada ', dist_limitante_2);
fprintf('con ángulo de haz reflejado %dº y ', angle_limit_user_2);
fprintf('con Área de cobertura %d m^2\n', area_group_2);
