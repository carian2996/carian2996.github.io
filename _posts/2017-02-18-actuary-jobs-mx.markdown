---
layout: post
title: "El Trabajo del Actuario en México"
author: "Ian Castillo"
date:   2017-02-18 14:14
---

El presente escrito está basado en el trabajo de David Sheehan publicado [aquí](http://dashee87.github.io/data%20science/data-scientists-vs-data-analysts-part-1/).

De igual manera, se agradece la ayuda de los siguientes recursos:

* [**Basic Text Mining in R**](https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html) de *RStudio*
* [**jobbR**](https://github.com/dashee87/jobbR) de *David Sheehan*
* [**mxmaps**](https://github.com/diegovalle/mxmaps) de *Diego Valle*
* [**outlierKD**](https://datascienceplus.com/rscript/outlier.R) de *Klodian Dhana*

## Objetivo
Este pequeño análisis presenta la situación actual respecto a los trabajos ofrecidos en México para las personas egresadas de la carrera de Actuaría.

De acuerdo con el artículo publicado por El Universal (2015) en su nota [Matemáticas vs desempleo](http://www.eluniversal.com.mx/articulo/periodismo-de-datos/2015/08/3/matematicas-vs-desempleo), una de las carreras profesionales mejor pagas es la del actuario, con un **sueldo promedio de 21 mil pesos al mes** y con una **tasa de desempleo del 0%**. Su análisis está basado en la [Encuesta Nacional de Ocupación y Empleo](http://www.beta.inegi.org.mx/proyectos/enchogares/regulares/enoe/) y las cifras corresponden al primer trimestre del 2015.

En esta breve publicación analizaremos las solicitudes de trabajo enfocadas a las personas egresadas de la licenciatura en Actuaría<sup>*</sup>.

Los datos, código fuente y reporte se pueden encontrar directamente [aquí](https://github.com/carian2996/RCode/tree/master/actuaryJobsMx).

\* *Nos basaremos en el supuesto de que al hacer una consulta en el portal de empleos Indeed con la consulta 'actuaria', los datos arrojados están relacionados con la oferta laboral para los actuarios. La consulta se realiza por orden de 'Relevancia'.*

## Los Datos
Los datos se obtuvieron de [Indeed](https://www.indeed.com.mx/about), un sitio web de busqueda de empleo cuya [API](https://www.indeed.com.mx/publisher) nos permite descargar la información relacionada con la publicación de una oferta de trabajo.

Con la ayuda del paquete desarrollado por **David Sheehan**, podemos acceder fácilmente a los datos requeridos. Una simple consulta con el siguiente código basta para obtener los datos de las solicitudes y sus respectivos sueldos:

```
# Obtenemos la información proporcionada por la empresa reclutadora
actuarios <- jobSearch(publisher = API Key,         # Contraseña obtenida para la API
                      query = "actuaria",           # Busqueda
                      country = 'mx',               # País
                      all = TRUE)                   # Regresa todos las solicitudes
                      
# Basados en la URL del puesto, registramos el salario ofrecido
salarios <- lapply(actuarios$results.url,               # URL de la solicitud
                   function(x) getSalary(x, "USD"))     # Extraemos el salario ofrecido
                   
# Cada salario obtenido lo guardamos en un data.frame
salarios <- do.call(rbind, salarios)

# Anexamos ambos conjunto de datos
actuarios <- cbind(actuarios, salarios)
```

Para este análisis se utlizaron 421 solicitudes de trabajo, desde el 30 Nov 2016 hasta el 02 Dec 2016 con las características de la consulta previa. El data set utilizado aquí puede ser descargado desde [aquí](https://raw.githubusercontent.com/carian2996/RCode/master/actuaryJobsMx/data.csv).

## Limpieza de los datos
Lo primero que haremos será una rápida limpieza de nuestros datos. Los datos en crudo contienen la siguiente información:


{% highlight text %}
##  [1] "version"                       "query"                        
##  [3] "location"                      "paginationPayload"            
##  [5] "dupefilter"                    "highlight"                    
##  [7] "totalResults"                  "start"                        
##  [9] "end"                           "pageNumber"                   
## [11] "results.jobtitle"              "results.company"              
## [13] "results.city"                  "results.state"                
## [15] "results.country"               "results.formattedLocation"    
## [17] "results.source"                "results.date"                 
## [19] "results.snippet"               "results.url"                  
## [21] "results.onmousedown"           "results.jobkey"               
## [23] "results.sponsored"             "results.expired"              
## [25] "results.indeedApply"           "results.formattedLocationFull"
## [27] "results.formattedRelativeTime" "results.stations"             
## [29] "status"                        "period"                       
## [31] "currency"                      "minSal"                       
## [33] "maxSal"
{% endhighlight %}

De las variables anteriores podemos notar que las primeras 10 columnas no tienen mayor relevancia, pues solo representan meta datos de nuestra consulta.


| version|query    |location |paginationPayload |dupefilter |highlight | totalResults| start| end| pageNumber|
|-------:|:--------|:--------|:-----------------|:----------|:---------|------------:|-----:|---:|----------:|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|



Eliminamos las columnas innecesarias y además, renombramos las columnas eliminando el prefijo 'results' para una compresión más sencilla y manejo más efectivo de las columnas. Las variables que tenemos para trabajar entonces son las siguientes:


{% highlight text %}
##  [1] "jobtitle"              "company"              
##  [3] "city"                  "state"                
##  [5] "country"               "formattedLocation"    
##  [7] "source"                "date"                 
##  [9] "snippet"               "url"                  
## [11] "onmousedown"           "jobkey"               
## [13] "sponsored"             "expired"              
## [15] "indeedApply"           "formattedLocationFull"
## [17] "formattedRelativeTime" "stations"             
## [19] "status"                "period"               
## [21] "currency"              "minSal"               
## [23] "maxSal"
{% endhighlight %}

Examinemos más a detalle que variables tenemos para trabajar. No incluimos 'snippet' porque es la variable que posee el texto original de las solicitudes, de igual manera 'url' pues solo contiene la dirección de la vacante.


{% highlight text %}
## 'data.frame':	421 obs. of  21 variables:
##  $ jobtitle             : chr  "ANALISTAS DE NEGOCIO" "DOCENTES" "Analista de Información (Inteligencia del negocio)" "Analista MIS Riesgo" ...
##  $ company              : chr  "Grupo Bimbo" "Universidad Latina,S.C." "Farmacias Similares" "Crédito Familiar" ...
##  $ city                 : chr  "Ciudad de México" "Ciudad de México" "Ciudad de México" "Ciudad de México" ...
##  $ state                : chr  "DIF" "DIF" "DIF" "DIF" ...
##  $ country              : chr  "MX" "MX" "MX" "MX" ...
##  $ formattedLocation    : chr  "Ciudad de México, D. F." "Ciudad de México, D. F." "Ciudad de México, D. F." "Ciudad de México, D. F." ...
##  $ source               : chr  "Grupo Bimbo" "Universidad Latina" "bumeran.com.mx" "bumeran.com.mx" ...
##  $ date                 : chr  "Sat, 31 Dec 2016 08:01:15 GMT" "Thu, 12 Jan 2017 12:21:48 GMT" "Fri, 20 Jan 2017 06:26:38 GMT" "Fri, 20 Jan 2017 06:26:00 GMT" ...
##  $ onmousedown          : chr  "indeed_clk(this,'6181');" "indeed_clk(this,'6181');" "indeed_clk(this,'6181');" "indeed_clk(this,'6181');" ...
##  $ jobkey               : chr  "57ad9f3bbcb615fb" "48f46e77f2650936" "567e12db3a84e957" "bfb75d03f35f6df2" ...
##  $ sponsored            : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ expired              : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ indeedApply          : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
##  $ formattedLocationFull: chr  "Ciudad de México, D. F." "Ciudad de México, D. F." "Ciudad de México, D. F." "Ciudad de México, D. F." ...
##  $ formattedRelativeTime: chr  "hace 20 días" "hace 8 días" "hace 19 horas" "hace 19 horas" ...
##  $ stations             : chr  "" "" "" "" ...
##  $ status               : Factor w/ 1 level "unknown": 1 1 1 1 1 1 1 1 1 1 ...
##  $ period               : Factor w/ 1 level "unknown": 1 1 1 1 1 1 1 1 1 1 ...
##  $ currency             : Factor w/ 1 level "USD": 1 1 1 1 1 1 1 1 1 1 ...
##  $ minSal               : num  15000 NA NA NA NA 12000 NA NA NA 23100 ...
##  $ maxSal               : num  17000 NA NA NA NA 12000 NA NA NA 23100 ...
{% endhighlight %}

Así se ve nuestros datos por el momento (sin la descripción del puesto ni url, pues son muy largas para mostrarse en una tabla):


---------------------------------------------------------------------------
         jobtitle                  company               city        state 
-------------------------- ----------------------- ---------------- -------
   ANALISTAS DE NEGOCIO          Grupo Bimbo       Ciudad de México   DIF  

         DOCENTES          Universidad Latina,S.C. Ciudad de México   DIF  

 Analista de Información     Farmacias Similares   Ciudad de México   DIF  
(Inteligencia del negocio)                                                 
---------------------------------------------------------------------------

Table: Table continues below

 
----------------------------------------------------
 country     formattedLocation          source      
--------- ----------------------- ------------------
   MX     Ciudad de México, D. F.    Grupo Bimbo    

   MX     Ciudad de México, D. F. Universidad Latina

   MX     Ciudad de México, D. F.   bumeran.com.mx  
----------------------------------------------------

Table: Table continues below

 
-----------------------------------------------------------------------
            date                    onmousedown             jobkey     
----------------------------- ------------------------ ----------------
Sat, 31 Dec 2016 08:01:15 GMT indeed_clk(this,'6181'); 57ad9f3bbcb615fb

Thu, 12 Jan 2017 12:21:48 GMT indeed_clk(this,'6181'); 48f46e77f2650936

Fri, 20 Jan 2017 06:26:38 GMT indeed_clk(this,'6181'); 567e12db3a84e957
-----------------------------------------------------------------------

Table: Table continues below

 
-----------------------------------------------------------
 sponsored   expired   indeedApply   formattedLocationFull 
----------- --------- ------------- -----------------------
   FALSE      FALSE       FALSE     Ciudad de México, D. F.

   FALSE      FALSE       FALSE     Ciudad de México, D. F.

   FALSE      FALSE       FALSE     Ciudad de México, D. F.
-----------------------------------------------------------

Table: Table continues below

 
---------------------------------------------------------------------------------
 formattedRelativeTime   stations   status   period   currency   minSal   maxSal 
----------------------- ---------- -------- -------- ---------- -------- --------
     hace 20 días                  unknown  unknown     USD      15000    17000  

      hace 8 días                  unknown  unknown     USD        NA       NA   

     hace 19 horas                 unknown  unknown     USD        NA       NA   
---------------------------------------------------------------------------------

## Compañías que más contratan actuarios
Una vez listos nuestros datos, podemos empezar a analizar y descubrir que hechos interesantes podemos obtener. Utilizando la información sobre la compañía que emite la vacante, veamos quienes son las empresas que más solicitan puestos para egresados de actuarios


{% highlight r %}
require(dplyr)

actuarios <- actuarios %>%
    mutate(company = tolower(company)) %>%
    mutate(company = gsub('[[:punct:]]+', ' ', company)) %>%
    mutate(company = gsub('[[:digit:]]+', ' ', company)) %>%
    mutate(company = iconv(company, to='ASCII//TRANSLIT')) %>%
    mutate(company = gsub('[[:punct:]]+', '', company))

# Generamos una tabla de frecuencias con las compañías que ofrecen los empleos
compañias <- sort(table(actuarios$company), decreasing = T)

# Removemos compañias con pocos puestos
dfCompañias <- data.frame(compañias[compañias / sum(compañias) > 0.009])   

# Cambiamos el nombre de nuestra columnas
colnames(dfCompañias) <- c('compañia', 'puestos')

# Recortamos el nombre de la compañia (para efectos de visualización)
dfCompañias$compañia <- substr(dfCompañias$compañia, 1, 15)                 

# Removemos compañias sin nombre
dfCompañias <- dfCompañias[dfCompañias$compañia != '', ]

dfCompañias$compañia <- factor(dfCompañias$compañia, 
                               levels=dfCompañias$compañia)
{% endhighlight %}


<img src="/../figs/actuaryJobsMx/plot1-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Podemos observar que entre las compañías con más puestos ofrecidos, se encuentras reclutadoras o compañías de 'head hunting', lo cual no deja entrevisto la verdadera empresa que solicita el puesto. Aunque por mucho, notamos que **Banamex** -ahora conocido como Citibanamex- es la institución con más vacantes relacionadas con la consulta 'actuaria'. 

Recordemos que cualquier análasis no debe ser tomado como verdad absoluta, por lo que podríamos hacer pensar que esto no necesariamente nos dice que Banamex ofrece más empleo para los actuarios, podemos considerar que esta institución financiera es muy grande comparada con muchas otras o incluso puede tener un convenio con Indeed para colocar más vacantes que otras empresas.

# El trabajo de actuario en alrededor del país
Desde que se ofreció por primera vez la licenciatura en Actuaría en la Ciudad de México (1947), dicha carrera profesional ha sido testigo de una divulgación alrededor del país; teniendo en cuenta que ahora se puede estudiar la carrera hasta en 10 ciudades de la república, podríamos esperar que el trabajo del actuario se ejerza en todo el país.

A continuación, analizaremos como se encuentran distribuidos los trabajos en la república Mexicana. El siguiente código preparará los datos de tal manera que con la ayuda del paquete de **Diego Valle** podremos graficar nuestros datos con un mapa de México utlizando dos lineas de código. 


{% highlight r %}
# Llamamos al paquete mxmaps para preparar la plantilla a utilizar
require(mxmaps)
data("df_mxstate")

# Creamos nuestra tabla de frecuencias por estado
mapa <- data.frame(table(actuarios$state))

# Adecuamos las abreviaturas de los estados y la unimos con la plantilla 
# necesaria para utlizar el paquete mxmaps
colnames(mapa) <- c('estado', 'puestos')
mapa <- mapa[mapa$estado != '', ]
mapa$estado <- c('BC', 'CHIH',  'CDMX', 'DGO', 'GTO', 'JAL', 'MEX', 'MICH', 'NL', 
                 'PUE', 'QRO', 'QROO', 'SIN', 'SON', 'TAB', 'TAM', 'YUC')

mapa <- merge(x=df_mxstate,y=mapa, by.x="state_abbr", by.y="estado", all.x = TRUE)
mapa$value <- mapa$puestos

# Reemplazamos los valores nulos por el valor 0
mapa$value[is.na(mapa$value)] <- 0
{% endhighlight %}

El siguiente mapa muestra la relación que existe entre los estados que poseen alguna universidad (pública o privada) y el número de empleos que se ofrece en dicha entidad o sus alrededores. 

<img src="/../figs/actuaryJobsMx/mapa2-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Por supuesto, la Ciudad de México, el Estado de México y Nuevo León encabezan la lista de estados de la republica dónde un actuario puede ejercer su labor. Aunque cabe resaltar los estados de Jalisco, Yucatán, y Puebla que apesar de tener menor tiempo con alguna universidad instaurando la carrera de Actuaría, ya comienzan a destacar entre las entidades que requieren este tipo de profesionista.

Quisiera destacar el dato del estado de Coahuila. En mi experiencia personal, nunca he conocido empresas que requieran actuarios en aquella entidad, ni de conocidos que hayan recibido ofertas en esa parte del país. Si ustedes tienen alguna explicación sobre este dato atípico (atípico a mi juicio) que nos pueda aclarar más la situación no estaría de más comenarlo.

# Algo de Minería de Texto
Me gustaría analizar las descripciones de las vacantes ofrecidas y poder vislumbrar un poco cuáles son los requisitos que más se le pide a una persona que quiera trabajar como actuario. Qué palabras son las más comunes a la hora de solicitar una actuaria o que habilidades están relacionadas con puestos actuariales de nivel dirección o gerencial.

Primero que nada, debemos preparar nuestros textos, juntarlos y realizar un procesamientos para poder anaizarlos. Con el siguiente código realizamos dicha tarea.


{% highlight r %}
require(tm)
# Cargamos y preparamos el corpus de datos

# Asociamos cada documentos con su id única de vacante
reader <- readTabular(mapping = list(id = "jobkey", content = "snippet"))

# Preparamos el corpus y definimos el lenguaje del texo
corpus <- Corpus(DataframeSource(actuarios), 
                 readerControl = list(reader = reader, language = 'es'))
{% endhighlight %}

Una vez creado el corpus con las siguientes características:


{% highlight r %}
corpus
{% endhighlight %}



{% highlight text %}
## <<VCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 421
{% endhighlight %}


{% highlight r %}
inspect(corpus[1])
{% endhighlight %}



{% highlight text %}
## <<VCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 1
## 
## [[1]]
## <<PlainTextDocument>>
## Metadata:  2
## Content:  chars: 150
{% endhighlight %}

Realizamos la limpieza del texto:



Una vez hecho el procesamiento y transformación sobre nuestros datos, el resultado final es els siguiente:


{% highlight r %}
c_corpus[[400]]['content']
{% endhighlight %}



{% highlight text %}
## $content
## [1] "importante empresa seguros solicita lic actuaria  objetivo  responsable suscripcion seleccion riesgos ajuste normat"
{% endhighlight %}

# Palabras más frecuentas en la busqueda de un actuario
Para realizar todos nuestros análisis debemos de construir la llamada matriz de términos del documentos. Dicha matriz relaciona todas las palabras registradas en los textos y sus apariciones dentro del mismo. Con el siguiente código creamos dicha matriz.


{% highlight text %}
## <<DocumentTermMatrix (documents: 421, terms: 1175)>>
## Non-/sparse entries: 4916/489759
## Sparsity           : 99%
## Maximal term length: 44
## Weighting          : term frequency (tf)
{% endhighlight %}

Más adelantes, removeremos las palabras menos frecuentes utilizando la función 'removeSparseTerms'. Esta parte del análisis es de gran sensibilidad, pues al eliminar las palabras menos frecuentes podríamos estar sesgando el significado de éstas de acuerdo al contexto que incluye el documento.

Una gran explicación acerca de 'escasez' de palabras en la matriz de términos puede ser vista [aquí](http://stackoverflow.com/a/33830637).

Con el siguiente código podemos ver las palabras más frecuentes en nuestro corpus


{% highlight r %}
freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
head(freq)
{% endhighlight %}



{% highlight text %}
##       actuaria   licenciatura       economia administracion    matematicas 
##            303            134            122            110             96 
##           afin 
##             92
{% endhighlight %}

Las cuales son palabras esperadas, obviamente, 'actuaria' es la palabra más común pues nuestra busqueda fue esa palabra precisamente.

Para comprender más acerca de la escasez en los documentos, analicemos que tan seguido se repiten las frecuencias de los términos en nuestra matriz.


{% highlight r %}
table(freq)
{% endhighlight %}



{% highlight text %}
## freq
##   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18 
## 626 201 110  44  38  26  22   6   9   9   6   5   7  10   4   3   1   5 
##  19  20  21  24  25  26  27  29  32  33  34  35  39  45  49  53  72  82 
##   1   4   2   4   2   3   2   3   1   1   1   4   1   1   2   1   1   1 
##  86  87  92  96 110 122 134 303 
##   1   1   1   1   1   1   1   1
{% endhighlight %}
Lo anterior quiere decir que existen 626 términos que se encuentran solo en un texto de una vacante; 201 términos que se encuentran solamente en dos descripciones de vacantes y así consecutivamente. Así, podemos decir que entre más términos que solo aparecen esporádicamente en los textos, más alta será el índice de escazes de términos.

Por el momento, por tener demasiada escazes de términos, conservaremos todos y después los removeremos para comparar resultados. La siguiente gráfica muestra las palabras más frecuentes sin remover palabra alguna.

<img src="/../figs/actuaryJobsMx/unnamed-chunk-10-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Removiendo las palabras menos escazas veamos que palabras más frecuentes obtenemos.


{% highlight text %}
## <<DocumentTermMatrix (documents: 421, terms: 3)>>
## Non-/sparse entries: 554/709
## Sparsity           : 56%
## Maximal term length: 12
## Weighting          : term frequency (tf)
{% endhighlight %}
<img src="/../figs/actuaryJobsMx/unnamed-chunk-12-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Podemos observar que disminuyendo casi la mitad el índice de escazes se elimina más del 99% de nuestros términos. Por lo tanto, seguiremos utilizando nuestra matriz de términos con todas las palabras.

Por último, veamos que palabras están más relacionas con otras. Por ejemplo, buscaremos las palabras más asociadas con los términos 'titulado', 'gerente', 'seguros'. 


{% highlight r %}
findAssocs(x = dtm, terms = "titulado", corlimit = 0.15)
{% endhighlight %}



{% highlight text %}
## $titulado
##       pasante indispensable        tercer      conjunto      distrito 
##          0.56          0.33          0.23          0.19          0.19 
##  industriales           mex         monte          pied    titulacion 
##          0.19          0.19          0.19          0.19          0.19 
## investigacion    licenciado      actuaria 
##          0.17          0.17          0.15
{% endhighlight %}



{% highlight r %}
findAssocs(x = dtm, terms = "gerente", corlimit = 0.3)
{% endhighlight %}



{% highlight text %}
## $gerente
##            comercio                 tdc             acordar 
##                0.47                0.47                0.33 
## actuariamatematicas            agencias                back 
##                0.33                0.33                0.33 
##            bancario                 btl          cecoaching 
##                0.33                0.33                0.33 
##           conciliar                cuya             definir 
##                0.33                0.33                0.33 
##               equip        factibilidad        intelligence 
##                0.33                0.33                0.33 
##               mezcl             obtener          preferible 
##                0.33                0.33                0.33 
##                 rcb     recomendaciones        reingenieria 
##                0.33                0.33                0.33 
##          requeridos               sueñe           ubicacion 
##                0.33                0.33                0.33
{% endhighlight %}



{% highlight r %}
findAssocs(x = dtm, terms = "datos", corlimit = 0.3)
{% endhighlight %}



{% highlight text %}
## $datos
##      base    resolu validador  analisis 
##      0.42      0.37      0.37      0.33
{% endhighlight %}



{% highlight r %}
findAssocs(x = dtm, terms = "seguros", corlimit = 0.3)
{% endhighlight %}



{% highlight text %}
## $seguros
##    becarios  participar   colaborar   integrate      latino    positiva 
##        0.41        0.39        0.38        0.38        0.38        0.38 
## trayectoria    programa   corretaje     fianzas        life     mexican 
##        0.38        0.35        0.31        0.31        0.31        0.31 
##         new   reaseguro      siendo    universe        york 
##        0.31        0.31        0.31        0.31        0.31
{% endhighlight %}

Para el término 'titulado' no hay ninguna sorpresa, la mayoría de las palabras hacen alución a la situación final de la carrera ('pasante'), a los requisitos para trabajar ('indispensable'). 

El término 'gerente' me pareció más interesante, pues muestra términos relacionados con soft skills ('conciliar', 'coaching', 'acordar', 'obtener'). Lo cual podría sugerir un desarrollo más allá del técnico en alguien que pretenda un puesto de gerencia.

Si un actuario quisiera terminar en el ramo de seguros podría esperar muchos puestos de becarios, pues la correlación entre la palabra seguros y 'becario' es de 0.41%. Le seriviría investigar términos como 'corretaje' o 'reaseguro'.

Si quisieramos agrupar los términos más relacionados en todas las vacantes podríamos utilizar un análisis sencillo de conglomerados con un método Euclidiano. El siguiente código muestra la manera de hacerlo:


{% highlight r %}
# Para este análisis si removemos los términos más escazos para utilizar un modelo
# sencillo de conglomerados utlizando una medida euclidiana
dtmss <- removeSparseTerms(dtm, 0.9)

d <- dist(t(dtmss), method="euclidian")   
fit <- hclust(d=d, method="ward.D")   

plot.new()
plot(fit, hang=-1, xlab = "", ylab = "", sub = "")

# Agrupamos con 4 clusters
groups <- cutree(fit, k=4)   
rect.hclust(fit, k=4, border="red")
{% endhighlight %}

<img src="/../figs/actuaryJobsMx/unnamed-chunk-14-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Podemos notar que los grupos de palabras se relacionan respecto a las diferentes áreas en las que un actuario se puede desempeñar. 'Economía', 'finanzas' y 'administración' se muestran claramente en un grupo, mientras que 'ingenieria', 'sistemas' e 'industrial' se agrupan en otro conglomerado.

Aquí podemos interpretar el resultado de diferentes maneras. Regularmente, una vacante de actuaria no es específicamente para alguien egresado solamente de esa licenciatura. Por llas características en la formación de un actuario, podemos suponer que el profesionista puede desempeñar labores que abarcan desde la Economía, hasta alguna ingeniería.

# ¿Cuánto gana un actuario en México?

Finalmente, analicemos el salario promedio de un Actuario en México. Con los datos recabados podemos calcular el salario promedio ofrecido en las vacantes. Removiendo valores atípicos en nuestra muestra podemos representar los salarios ofrecidos en la siguiente gráfica:



<img src="/../figs/actuaryJobsMx/unnamed-chunk-16-1.png" title="center" alt="center" style="display: block; margin: auto;" />

En la gráfica anterior podemos observar que a pesar de que la media de los salarios ofrecidos es de apenas $13,000 MXN al mes, un 50% de los trabajos ofrecen un sueldo promedio bastante alentador si tomamos en cuenta otras carreras.

Podemos observar más a detalle estos datos con la siguiente instrucción:


{% highlight r %}
summary(actSalarios$avg_salario)
{% endhighlight %}



{% highlight text %}
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##    2000   10000   13000   15700   20000   42500      10
{% endhighlight %}

# Conclusiones

El trabajo del actuario en México ha venido en aumento durante los últimos años en México, cada día más compañías se ven beneficiadas con las habilidades y conocimientos que un actuario puede ofrecer. Aunque al día de hoy, las compañias tradicionales (bancos, asegurados y financieras) son las responsables de contratar en su mayoria a los actuarios, podemos observar que poco a poco el actuario gana terreno en otras partes de la republica y cada día se diversifica más las responsabilidades de un actuario.

Una apuesta favorable es la de estudiar una licenciatura en Actuaria pues los sueldos promedios obtendios superan en buena medida los promedios nacionales de cualquier otra carrera. Aunque la demanda por nuevas herramientas y conocimientos hace de la Actuaría una carrera demandante, con una amplia variedad de temas a dominar, parece que siempre es bien recompezada.

