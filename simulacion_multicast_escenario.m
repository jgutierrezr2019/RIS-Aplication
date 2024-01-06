close all;
clear;
clc;


%% Simulación Escenario multicast
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


%% Cálculo distancias limitantes multicast
% Establecer distancias hacia cada usuario desde la RIS ,la distancia de
% la antena transmisora a la RIS en metros
% Distancia txtoRIS [Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
d_txtoRIS_Escenarios = [30, 51.8, 3.21, 8.64];
d_txtoRIS = d_txtoRIS_Escenarios(N_Escenario);

% Ángulo haz incidencia en RIS de escenarios [Pos Intermedia,Pos Lejana,Pos Cercana max,Pos Cercana]
Theta_BS_Escenarios = [6.5, 5.5, 14, 14];
Theta_BS = Theta_BS_Escenarios(N_Escenario);

% Hallar la distancia a usuario limitante en caso multicast
% Caso directo
angle_index = find(abs(Theta) < Theta_BS);
limit_user_1 = find(G_BS == min(G_BS(angle_index))); % indice usuario con menor ganancia dentro del haz
Theta_BS_user_lm = abs(Theta(limit_user_1)); % Ángulo directo desde BS station
PL = SNR_limit - (P_BS + G_BS(limit_user_1) + G_UE) + Pn;
d_txtoLmUser = lambda/(10^(PL/20)*4*pi);  
d_txtoCtlUser = abs(cosd(Theta_BS_user_lm)*d_txtoLmUser); % Distancia TX-User

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
d_RIStoCtlUser = lambda/(10^(PL/20)*4*pi); % Distancia RIS-User


%% Simulación de N usuarios en servicio multicast
% Datos
U = 12; % Numero de usuarios de la simulación
reflected_angle_user = (5 - (-5))*rand(1,U/2) - 5; % Ángulo de haz reflejado usuarios
azim_angle_user = (50 - 45)*((reflected_angle_user + 5)/10) + 45;% Ángulo de azimuth usuarios
Theta_BS_user = (14 - (-14))*rand(1,U/2) - 14; % Ángulo de haz directo
d_RIStoUser_rdn = d_RIStoCtlUser*rand(1,U/2);
d_RIStoUser_rdn = d_RIStoUser_rdn./cosd(reflected_angle_user);
d_txtoUser_rdn = d_txtoCtlUser*rand(1,U/2);
d_txtoUser_rdn = d_txtoUser_rdn./cosd(Theta_BS_user);

% Calcular SNR de los usuarios a los que la RIS transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_RIStoUser_rdn(i))); % Distancia RIS-User
    
    % Encontrar valor de ganancia en función del ángulo de azimuth
    dist = abs(HAzim_angle - azim_angle_user(i)); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    
    % Calcular gananacia de RIS
    G_RA = G_RA_azim(index_value(1));
    
    % Calcule las SNR reales con un RIS
    SNRb(1,i) = (P_BS + G_RA + PL + G_UE) - Pn;
end

% Calcular SNR de los usuarios a los que la antena transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_txtoUser_rdn(i))); % Distancia Tx-User
    
    % Encontrar valor de ganancia en función del Theta_BS
    dist = abs(Theta - abs(Theta_BS_user(i))); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    
    SNRb(1,i + U/2) = (P_BS + G_BS(index_value) + PL + G_UE) - Pn;
end

% Hallar la SNR mínima que indicará el peor usuario del sistema
SNRmin(1) = min(SNRb(1,:));

 % Eficiencia Espectral
SE(1) = log2(1 + db2pow(SNRmin(1)));

% Eficiencia Espectral Agregada
ASE(1) = U*SE(1);

%% Simulación de N usuarios en servicio multicast con haz pincel dirigido
% Calcular SNR de los usuarios a los que la RIS transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_RIStoUser_rdn(i))); % Distancia RIS-User

    % Calcular gananacia de RIS
    G_RA = max(G_RA_azim_Unicast);

    % Ángulo de ganancia máxima
    index_value = G_RA_azim_Unicast == max(G_RA_azim_Unicast);
    azim_angle = HAzim_angle_Unicast(index_value);
    elev_angle = 0; % Invariante en nuestro escenario
    
    % Calcule las SNR reales con un RIS
    SNRb(2,i) = (P_BS + G_RA + PL + G_UE) - 10*log10(U/2) - Pn;
end

% Calcular SNR de los usuarios a los que la antena transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_txtoUser_rdn(i))); % Distancia Tx-User
    
    % Encontrar valor de ganancia en función del Theta_BS
    dist = abs(Theta - abs(Theta_BS_user(i))); % Calcula la diferencia
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


%% Simulación de N usuarios en servicio multicast con caso ideal de Bjorson
% Calcular SNR de los usuarios a los que la RIS transmite
for i = 1:U/2
    % Pérdidas de propagación
    alpha = 20*log10(lambda/(4*pi*d_txtoRIS)); % Pathloss a RIS
    beta = 20*log10(lambda/(4*pi*d_RIStoUser_rdn(i))); % Pathloss desde RIS
    gamma = 20*log10(N); % Ganancia RIS
    % gamma = 10*log10((4*pi/lambda^2)*N); % Ganancia de las diapositivas
    % reflectarray

    % Encontrar valor de ganancia en función del Theta_BS
    dist = abs(Theta - abs(Theta_BS)); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    % Ganancia desde la estación base
    G_BS_Rfl = G_BS(index_value);

    % Valor de SNR del usuario de la zona reflejada
    SNRb(3,i) = (P_BS + G_BS_Rfl + beta + alpha + gamma + G_UE) - 10*log10(U/2) - Pn;
end

% Calcular SNR de los usuarios a los que la antena transmite
for i = 1:U/2
    % Establecer las pérdidas usando la ecuación de Friis
    PL = 20*log10(lambda/(4*pi*d_txtoUser_rdn(i))); % Distancia Tx-User
    
    % Encontrar valor de ganancia en función del Theta_BS
    dist = abs(Theta - abs(Theta_BS_user(i))); % Calcula la diferencia
    % absoluta entre el valor deseado y todos los elementos del vector
    index_value = find(dist == min(dist));
    
    SNRb(3,i + U/2) = (P_BS + G_BS(index_value) + PL + G_UE) - Pn;
end

% Hallar la SNR mínima que indicará el peor usuario del sistema
SNRmin(3) = min(SNRb(3,:));

 % Eficiencia Espectral
SE(3) = log2(1 + db2pow(SNRmin(3)));

% Eficiencia Espectral Agregada
ASE(3) = U*SE(3);

%% Búsqueda mejor y peor escenario con su usuario limitante
[mejor_SNRmin, mejor_sim] = max(SNRmin);
ind_limitante = find(SNRb(mejor_sim,:) == mejor_SNRmin);
fprintf('El mejor caso es la simulación %d\n', mejor_sim);


if (ind_limitante <= U/2)
    fprintf('La mejor SNR del usuario limitante pertenece al segundo ');
    fprintf('grupo de usuarios con SNR de %d dB ',mejor_SNRmin);
    fprintf('y distancia %d ',d_RIStoUser_rdn(ind_limitante));
    fprintf('metros de la RIS y distancia entre RIS y estación base de ');
    fprintf('%d metros\n\n', d_txtoRIS);
else
    fprintf('La mejor SNR del usuario limitante pertenece al segundo ');
    fprintf('grupo de usuarios con SNR de %d dB ',mejor_SNRmin);
    fprintf('con distancia %d ',d_txtoUser_rdn(ind_limitante - U/2));
    fprintf('metros de la estación base\n\n');
end


[peor_SNRmin, peor_sim] = min(SNRmin);
ind_limitante = find(SNRb(peor_sim,:) == peor_SNRmin);
fprintf('El peor caso es la simulación %d\n', peor_sim);


if (ind_limitante <= U/2)
    fprintf('La peor SNR del usuario limitante pertenece al segundo ');
    fprintf('grupo de usuarios con SNR de %d dB ',peor_SNRmin);
    fprintf('y distancia %d ',d_RIStoUser_rdn(ind_limitante));
    fprintf('metros de la RIS y distancia entre RIS y estación base de ');
    fprintf('%d metros\n\n', d_txtoRIS);
else
    fprintf('La peor SNR del usuario limitante pertenece al segundo ');
    fprintf('grupo de usuarios con SNR de %d dB ',peor_SNRmin);
    fprintf('con distancia %d ',d_txtoUser_rdn(ind_limitante - U/2));
    fprintf('metros de la estación base\n\n');
end



%% Cáculo SNR media de la simulación
fprintf('El escenario de haz reflejado ensanchado tiene SNR de %d dB de media\n', mean(SNRb(1,1:U/2)));
fprintf('El escenario de haz pincel reflejado tiene SNR de %d dB de media\n', mean(SNRb(2, 1:U/2)));
fprintf('El escenario de Bjorson con ganancia de RIS ideal tiene SNR de %d dB de media\n', mean(SNRb(3, 1:U/2)));