close all;
clear;
clc;

%% 2do Escenario
% Datos inicales
N_Escenarios = 4; % Numero de escenarios a simular
P_BS = 30; % Potencia transmitida de la estacion base en dBm
G_UE = 15; % Ganancia de usuario
c = 3*10^8; % Velocidad de la luz en m/s
BW = 1e9; % Ancho de banda en GHz
f = 27*10^9; % Frecuencia de 28 GHz
lambda = c/f;% Longitud de onda
N = 0:6400; % Numero de elementos de RIS
Aeff = 0.005^2; % Área efectiva de un elemento
A_RIS = (0.005*80)^2; % Área efectiva de la RIS
U = 14; % Numero de usuarios total del sistema
NSD = -174; % Densidad espectral de ruido en dBm/Hz

% Cálculo potencia de ruido del sistema
Pn = NSD + 10*log10(BW);

% Establecer distancias hacia cada usuario desde la RIS ,la distancia de
% la antena transmisora a la RIS en metros
d_txtoRIS(2,:) = 51.8;
d_RIStoUser(2,:) = [60.02 62.46 64.17 64.78 64.14 62.41 59.96];
d_txtoUser(2,:) = [57.61 60.05 61.78 62.39 61.78 60.05 57.61]; 


% Establecer ángulos de elevación y azimuth en grados 
% dirigidos a cada usuario (Componentes a misma altura)
azim_angle(2,:) = [33 33.5 34.5 35.5 36.5 37.5 38];
elev_angle = 0; % Invariante en nuestro escenario
HPBW = [-5 -4 -2 0 2 4 5]*2; % Ancho de haz directo de estación 
% base a primer grupo de usuarios (Half Power Beamwidth)


% Recoger datos de la ganancia de la figura esc_azim
ruta_figura = 'esc2_azim_IRS.fig'; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
HAzim_angle = get(line, 'XData'); % Valores de ángulos de azimuth
G_RA_azim = get(line, 'YData'); % Valores de ganancia de la RIS


% Calcular SNR de los usuarios a los que la RIS transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_RIStoUser(2,i))); % Distancia RIS-User
    
    % Encontrar valor de ganancia en función del ángulo de azimuth
    dist = abs(HAzim_angle - azim_angle(2,i)); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    
    % Calcular gananacia de RIS
    G_RA = G_RA_azim(index_value(1));
    
    % Calcule las SNR reales con un RIS
    SNRb(2,i) = (P_BS + G_RA + PL + G_UE) - Pn;
end


% Recoger datos de la ganancia de la figura esc_azim
ruta_figura = 'esc2_cosq_EB.fig'; % Ruta al archivo .fig
figura = openfig(ruta_figura); % Abrir figura
line = findobj(figura, 'Type', 'line'); % Línea con valores del diagrama de
% radiación
% La figura contiene dos celdas pero solo necesitamos la curva de interés
Cell_Theta = get(line, 'XData'); 
Theta = Cell_Theta{1,1};% Valores de ángulos de azimuth
Cell_G_BS = get(line, 'YData'); 
G_BS = Cell_G_BS{2,1};% Valores de ganancia de la RIS



% Calcular SNR de los usuarios a los que la antena transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_txtoUser(2,i))); % Distancia Tx-User
    
    % Encontrar valor de ganancia en función del HPBW
    dist = abs(Theta - abs(HPBW(i))); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    
    SNRb(2,i + U/2) = (P_BS + G_BS(index_value) + PL + G_UE) - Pn;
end


% Hallar la SNR mínima que indicará el peor usuario del sistema
SNRmin(2) = min(SNRb(2,:));


% Eficiencia Espectral
SE(2) = log2(1 + db2pow(SNRmin(2)));


% Eficiencia Espectral Agregada
ASE(2) = U*SE(2);

%% Cálculo máxima zona de cobertura con SNR limitante
%C = ; % Tasa de bits del servicio que ofrecemos (bits/s)
%SNR_limit = 2^(C/B) - 1; % SNR limitante del servicio que ofrecemos
SNR_limit = 20; % SNR limitante del servicio que ofrecemos

% Zona de cobertura del primer grupo

    % Hallar la distancia a usuario limitante
    limit_user_1(2) = find(G_BS == min(G_BS)); % indice usuario con menor ganancia dentro del haz
    angle_limit_user_1(2) = Theta(limit_user_1(2)); % ángulo usuario limitante
    PL = SNR_limit - (P_BS + G_BS(limit_user_1(2)) + G_UE) + Pn;
    dist_limitante_1(2) = lambda/(10^(PL/20)*4*pi); % Distancia limitante primer grupo
    
    % Cálculo área de cobertura
    % Suponiendo el área como un triángulo
    angle_in_Rad = deg2rad(angle_limit_user_1(2)/2);
    heigth = abs(cos(angle_in_Rad)*dist_limitante_1(2));
    base = abs((dist_limitante_1(2)*sin(angle_in_Rad))*2);
    area_group_1(2) = base*heigth/2;
    
    
% Zona de cobertura del segundo grupo
    
    % Hallar la distancia a usuario limitante
    dist = abs(HAzim_angle - abs(azim_angle(2,1)));
    fst_index_value = find(dist == min(dist));
    dist = abs(HAzim_angle - abs(azim_angle(2,end)));
    lst_index_value = find(dist == min(dist));
    index_range = fst_index_value:1:lst_index_value; % Ángulos haz reflejado
    limit_user_2(2) = find(G_RA_azim == min(G_RA_azim(index_range))); % indice 
    % usuario con menor ganancia dentro del haz
    angle_reflected_haz = [-5 -4 -2 0 2 4 5]; % Ángulos de apertura de haz en orden
    angle_azimuth_haz = HAzim_angle(limit_user_2(2));
    angle_index = find(azim_angle(2,:) == angle_azimuth_haz);
    angle_limit_user_2(2) = angle_reflected_haz(angle_index);
    G_RA = G_RA_azim(limit_user_2(2));
    PL = SNR_limit - (P_BS + G_RA + G_UE) + Pn;
    % Establecer las pérdidas usando la ecuación de Friis
    dist_limitante_2(2) = lambda/(10^(PL/20)*4*pi); % Distancia Tx-Userr
    
    % Cálculo área de cobertura
    % Suponiendo el área como un triángulo
    if angle_limit_user_2(2) == 0
        angle_in_Rad = deg2rad(angle_reflected_haz(end));
        heigth = dist_limitante_2(2);
        hipotenusa = abs(heigth/cos(angle_in_Rad));
        base = abs((dist_limitante_2(2)*sin(angle_in_Rad))*2);
    else
        angle_in_Rad = deg2rad(angle_limit_user_2(2));
        heigth = abs(cos(angle_in_Rad)*dist_limitante_2(2));
        base = abs((heigth*sin(deg2rad(angle_reflected_haz(end)))*2)); 
    end
    area_group_2(2) = base*heigth/2;
    
%% Cáculo SNR media    
fprintf('El escenario 2 tiene SNR de %d dB de media\n', mean(SNRb(2,:)));


%% Cálculo de área de cobertura en función de SNR limitante
% 2DO ESCENARIO
fprintf('Para una SNR limitante de %d dB:\n', SNR_limit);
fprintf('El escenario 2 tiene distancia limitante de %d m ', dist_limitante_1(2));
fprintf('para el primer grupo con ángulo de haz %dº y ', angle_limit_user_1(2));
fprintf('con Área de cobertura %d m^2 y ', area_group_1(2));
fprintf('distancia limitante de %d m para el segundo grupo ', dist_limitante_2(2));
fprintf('con ángulo de haz reflejado %dº y ', angle_limit_user_2(2));
fprintf('con Área de cobertura %d m^2\n', area_group_2(2));