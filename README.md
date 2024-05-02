# RIS-Aplication
Trabajo de fin de grado de Javier Gutiérrez
Descripción de Código:

1. Especificación datos iniciales.
Se establecen los datos iniciales del escenario:
▪ Potencia transmitida por la estación base: 30 dBm.
▪ Ganancia del terminal de usuario: 1 dB.
▪ Velocidad de la luz: 3 × 108 m/s.
▪ Ancho de banda: Variable (rango de 25 MHz a 1 GHz).
▪ Frecuencia de trabajo: 27 GHz.
▪ Longitud de onda: Variable (se mide en m).
▪ Número de elementos de RIS: 6400.
▪ Área efectiva de un elemento de la RIS: 25 mm2.
▪ Número de usuarios total del sistema: Variable.
▪ Densidad espectral de ruido: Variable (se mide en dBm/Hz).

2. Asignación de distancias y ángulos relevantes para la realización de cálculos.
Asignamos las distancias y ángulos para poder obtener las ganancias y pérdidas del sistema.
Las distancias y ángulos dependen del escenario analizado y se clasifican del siguiente modo:
▪ Distancia BS a RIS: distancia en metros desde la estación base a la RIS, se
utiliza para calcular las pérdidas de propagación para el caso del área de
usuarios sin línea de visión directa.
▪ Ángulo de azimuth: es el ángulo de orientación sobre el plano horizontal que
presentan la onda incidente en la RIS (asociada al haz radiado desde la
estación base a la RIS) y la onda reflejada por la RIS. Se utiliza para obtener la
ganancia de la RIS al redirigir el haz hacia la zona de cobertura reflejada.
▪ Ángulo de elevación: es el ángulo de orientación en el plano vertical que
presentan las ondas incidente y reflejada por la RIS. En nuestro escenario,
todos los componentes (BS, RIS, usuarios) mantienen la misma altura por lo
que se mantendrá siempre con valor de 0°. Se utiliza para obtener la ganancia
de la RIS al redirigir el haz hacia la zona de cobertura reflejada.
▪ HPBW: es el ancho total del haz radiado entre puntos situados a -3 dB del
máximo, se fija en función de los requisitos del escenario (regiones de
cobertura), tanto para la BS como para la RIS, y determina el valor de ganancia
máxima de la estación base y la RIS. En nuestro caso, supondremos una RIS
con un haz ensanchado con HPBW de 10°, que permite cubrir la región de
cobertura reflejada.
▪ Theta: es el ángulo de orientación horizontal que indica el apuntamiento del
haz generado por la estación base. Se define para cubrir tanto la región
directa de usuarios como la RIS, por lo que su valor se ajusta en función del
escenario.

3. Balance de enlace
El balance de enlace de nuestro escenario se obtiene mediante el análisis de pérdidas y
ganancias asociadas a los elementos del sistema que forman parte de la simulación.
Como datos iniciales contaremos con:
▪ PBS = 30 dBm -> potencia transmitida estación base
▪ GBS-> ganancia de estación base (variable)
▪ PLBS -> pérdidas de propagación de la estación base a la RIS (variable)
▪ GRIS -> ganancia de la RIS de entrada o salida del haz incidente (variable)
▪ SLRIS -> pérdidas de escaneo de la RIS de entrada o salida del haz (variable)
▪ PLUE -> pérdidas de propagación de RIS al usuario (variable)
▪ GUE = 1 dB -> Ganancia de la antena del usuario
▪ f = 27 GHz-> frecuencia de trabajo
Para ello, seguimos un método de modelado de ganancia que entiende como ganancia de
transmisión todo el esquema conformado tanto por la RIS como la estación base teniendo en
cuenta la potencia de transmisión, las ganancias de cada componente del esquema y las
pérdidas de propagación que dan lugar a una potencia recibida del usuario:
          𝑃𝑈𝐸 = 𝑃𝐵𝑆 + 𝐺𝑅𝐼𝑆 + 𝑃𝐿𝑈𝐸 + 𝐺𝑈𝐸
Las pérdidas de propagación vienen dadas por la ecuación del modelo de Friis:
                  𝑃𝐿 = 20𝑙𝑜𝑔(𝜆/4𝜋𝐷) 
A partir de la potencia recibida, calcularemos la SNR de cada usuario restando la potencia de
ruido (PN) en dB:
                  𝑆𝑁𝑅 = 𝑃𝑈𝐸 − 𝑃𝑁 
El factor más importante de este modelo es la ganancia de la RIS, cuyo valor depende de varios
parámetros como:
▪ Número de elementos: Con una elevada cantidad elementos la eficiencia de la RIS
mejora, adquiriendo mayor factor de beamforming.
▪ Ángulo de incidencia y reflexión: El ángulo de incidencia del haz transmitido tiene
influencia en el diseño de la RIS para poder desviarlo de tal manera que apunte a
la dirección deseada. El diagrama de radiación de la RIS depende de estos ángulos.
Además, cuando el ángulo de reflexión es distinto del normal (0°), se produce una
pequeña pérdida de ganancia (pérdida por escaneo), debido a que el tamaño
efectivo de la apertura de radiación de la RIS se reduce.
▪ Tamaño de la RIS: En un escenario es preferible una RIS de mayor tamaño para
poder colocar más elementos, debido a veces a la necesidad de usar elementos de
mayor tamaño para aumentar el área efectiva de cada elemento.
▪ Diagramas de radiación: constituyen una representación del haz o los haces
radiados por la RIS y la estación base, que permiten caracterizar la ganancia,
directividad y anchura del haz transmitido. El haz transmitido por la estación base
incidirá en la RIS, y gracias a su capacidad reflectora se generará otro haz cuyo
diagrama será objeto de estudio.
La ganancia de la BS se calcula mediante la siguiente fórmula:
                𝐺𝐵𝑆 = 10 𝑙𝑜𝑔10(4𝜋/𝐻𝑃𝐵𝑊2) 
donde HPBW se expresa en radianes.
Esta ganancia refleja la capacidad de la estación base para concentrar su energía en una
dirección específica, lo que influye directamente en la calidad de la señal transmitida y
recibida.
En cuanto a la ganancia de la RIS, empleamos dos enfoques: uno teórico basado en el modelo
de procesamiento de señales y otro mediante análisis electromagnético del conjunto 𝑅𝐼𝑆 +
𝐵𝑆. En el primer caso, la ganancia se calcula utilizando la fórmula del logaritmo del cuadrado
del número de elementos de la RIS (𝑁2). Para el segundo enfoque, diseñamos una RIS pasiva
específica para cada escenario, considerando ángulos de incidencia y reflexión según las
condiciones del entorno. Luego, simulamos esta configuración para obtener su diagrama de
radiación en azimuth. Es importante destacar en este segundo método que la ganancia de la
RIS ya incluye la ganancia de la BS, las pérdidas de propagación hasta la RIS, la ganancia de la
RIS en sí misma y posiblemente otras pérdidas adicionales, lo que modifica la forma en que se
calcula la ganancia total del sistema.
El balance de enlace en el caso del grupo directo de usuarios, se analiza y simula como un
radioenlace, cuya ganancia vendrá dada por el HPBW de la estación base y pérdidas de
propagación siguiendo el modelo de Friis:
                𝑃𝑈𝐸 = 𝑃BS + 𝐺BS + 𝑃𝐿𝑈𝐸+𝐺𝑈𝐸 
A partir de la potencia recibida, calcularemos la SNR según.

4. Cálculo de zonas de cobertura
En nuestro escenario se ofrece un servicio que requiere de una tasa de bits. A partir de ella, se
calcula la distancia máxima para que este servicio pueda ser difundido en condiciones
adecuadas. 
Para ello, se calculan las pérdidas de propagación (PL):
            𝑃𝐿𝑈𝐸 = 𝑆𝑁𝑅 + 𝑃𝑁 − (𝑃𝐵𝑆 + 𝐺𝐵𝑆 + 𝐺𝑅𝐼𝑆 + 𝐺𝑈𝐸)
Una vez calculado 𝑃𝐿𝑈𝐸, podemos obtener la distancia máxima como:
                      𝐷 =𝜆/10^((𝑃𝐿𝑈𝐸⁄20)4𝜋) 
Mediante trigonometría se calcula la altura, base y área del triángulo que conformarán
nuestras zonas de cobertura a partir del ángulo utilizado y la distancia obtenida.
Por último, se calcula la eficiencia espectral y la eficiencia espectral agregada para la SNR
limitante del servicio ofrecido y los usuarios de nuestro sistema.

5. Comparativa con una RIS de haz pincel
A continuación, se realiza una comparativa entre el rendimiento de nuestro escenario con una
RIS de haces ensanchados para la SNR limitante requerida por el servicio y un nuevo enfoque,
considerando el mismo escenario, pero utilizando una RIS con haces directivos (haces de tipo
pincel) para cada usuario perteneciente a la zona reflejada.
En esta sección, se utiliza la ganancia máxima del haz pincel dirigido a cada usuario de la zona
reflejada. Debido a que la RIS tiene que generar diferentes haces a partir de la incidencia de un
único haz, se reparte la energía de la onda incidente entre los haces generados. Existen varios
métodos para lograrlo, en nuestro caso utilizaremos el método de división equitativa de
potencia, consistiendo en repartir la potencia de transmisión a partes iguales entre los
usuarios del sistema. Para ello, se toma como referencia la ganancia de la RIS cuando se diseña
para generar un único haz pincel, obtenida mediante simulación electromagnética. A este valor
se la aplica un factor de reducción de ganancia en función del número de haces que se desee
generar. Mediante este enfoque, calculamos el máximo teórico posible, entendiendo que las
implementaciones prácticas siempre estarán por debajo de este valor.
El objetivo es averiguar el máximo número de usuarios posible para este sistema manteniendo
el mismo rendimiento del escenario con haces ensanchados. Con este fin, se calcula el número
de usuarios (𝑁𝑢) a partir de la ecuación del balance de enlace utilizando los datos iniciales del
anterior enfoque, la ganancia máxima del haz pincel y la SNR limitante:
              𝑁𝑢 = 10𝑃𝐵𝑆 – (𝑆𝑁𝑅 + 𝑃𝑁 −( 𝑃𝐵𝑆 + 𝐺𝑅𝐼𝑆 + 𝐺𝑈𝐸))
