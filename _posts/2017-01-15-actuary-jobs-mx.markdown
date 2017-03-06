---
title: "Actuarial Science Jobs in Mexico"
layout: post
date:   2017-01-15 12:00
---

The present writing is based on the work of David Sheehan published [here](http://dashee87.github.io/data%20science/data-scientists-vs-data-analysts-part-1/).

Likewise, the help of the following resources is appreciated:

* [**Basic Text Mining in R**](https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html) de *RStudio*
* [**jobbR**](https://github.com/dashee87/jobbR) de *David Sheehan*
* [**mxmaps**](https://github.com/diegovalle/mxmaps) de *Diego Valle*
* [**outlierKD**](https://datascienceplus.com/rscript/outlier.R) de *Klodian Dhana*

## Goal
This small analysis presents the current situation regarding the works offered in Mexico for the people graduated from the actuary career.

According to the article published by El Universal (2015) in its note [Matemáticas vs desempleo](http://www.eluniversal.com.mx/articulo/periodismo-de-datos/2015/08/3/matematicas-vs-desempleo), one of the best paid careers belongs to actuaries, with an average salary of $21k pesos (MXN) a month and with a unemployment rate of 0%. Its analysis is based on the [Encuesta Nacional de Ocupación y Empleo](http://www.beta.inegi.org.mx/proyectos/enchogares/regulares/enoe/) and the data correspond to the first quarter of 2015.

In this brief publication we will analyze job request focused on the people graduated from the degree in Actuarial Science<sup>*</sup>.

The data, source code and report can be found directly [here](https://github.com/carian2996/RCode/tree/master/actuaryJobsMx).

\* *We will assume that when making a query in the job portal Indeed with the query 'actuaria', the data thrown are related to the labor supply for actuaries. The query is done in order of 'Relevance'.*

## The Data
The data were obtained from [Indeed](https://www.indeed.com.mx/about), a job search website whose [API](https://www.indeed.com.mx/publisher) allows us to download the information related to the publication of a job offer.

With the help of the package developed by **David Sheehan**, we can easily access the required data. A simple query with the following code is enough to obtain the data of the requests and their respective salaries:

```
# We obtain the information provided by the recruiting company
actuarios <- jobSearch(publisher = API Key,         # Password obtained for API
                      query = "actuaria",           # Search
                      country = 'mx',               # Country
                      all = TRUE)                   # Returns all posible data
                      
# Based on the job URL, we record the salary offered
salarios <- lapply(actuarios$results.url,               # query URL
                   function(x) getSalary(x, "USD"))     # We extract the salary offered
                   
# Each salary obtained is stored in a data.frame
salarios <- do.call(rbind, salarios)

# We append both dataset
actuarios <- cbind(actuarios, salarios)
```

For this analysis 421 job requests are used, since 30 Nov 2016 to 02 Dec 2016 with the characteristics of the previous query. The dataset used here can be downloaded from [here](https://raw.githubusercontent.com/carian2996/RCode/master/actuaryJobsMx/data.csv).

## Cleaning Data
The first thing we will do will be a quick cleaning of our data. The raw data contains the following information:


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

From the above variables we can note that the first 10 columns are not relevant, since they only represent meta data of our query.


| version|query    |location |paginationPayload |dupefilter |highlight | totalResults| start| end| pageNumber|
|-------:|:--------|:--------|:-----------------|:----------|:---------|------------:|-----:|---:|----------:|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|
|       2|actuaria |         |                  |TRUE       |TRUE      |          421|     1|  25|          0|



We remove the unnecessary columns and also, rename the columns eliminating the prefix 'results' for a simpler compression and more effective handling of the columns. The variables that we have to work then are the following:


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

Let's examine more in detail what variables we have to work with. We do not include 'snippet' because it is the variable that has the original text of the requests, likewise 'url' as it only contains the address of the vacancy.


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

## Companies that Most Employ Actuaries
Once we have ready our data, we can begin to analyze and discover what interesting facts we can obtain. Using the information on the company that issues the vacancy, let's see who are the companies that most request positions for graduates of actuaries.


{% highlight r %}
require(dplyr)

actuarios <- actuarios %>%
    mutate(company = tolower(company)) %>%
    mutate(company = gsub('[[:punct:]]+', ' ', company)) %>%
    mutate(company = gsub('[[:digit:]]+', ' ', company)) %>%
    mutate(company = iconv(company, to='ASCII//TRANSLIT')) %>%
    mutate(company = gsub('[[:punct:]]+', '', company))

# We generate a frequencies table with the companies that offer the jobs
compañias <- sort(table(actuarios$company), decreasing = T)

# We remove companies with few positions
dfCompañias <- data.frame(compañias[compañias / sum(compañias) > 0.009])   

# We change the name of our columns
colnames(dfCompañias) <- c('compañia', 'puestos')

# We cut the name of the company (for visualization purposes)
dfCompañias$compañia <- substr(dfCompañias$compañia, 1, 15)                 

# We remove companies with no name
dfCompañias <- dfCompañias[dfCompañias$compañia != '', ]

dfCompañias$compañia <- factor(dfCompañias$compañia, 
                               levels=dfCompañias$compañia)
{% endhighlight %}


<img src="/../figs/actuary-jobs-mx/plot1-1.png" title="center" alt="center" style="display: block; margin: auto;" />

We can see that among the companies with the most jobs offered, there are recruiters or head hunting companies, which does not leave a glimpse of the real company applying for the position. Although by far, we note that **Banamex** - now known as Citibanamex - is the institution with the most vacancies related to the 'actuaria' consultation.

Recall that any analysis should not be taken as absolute truth, so we might think that this does not necessarily tell us that Banamex offers more employment for actuaries, we can consider that this financial institution is very large compared to many others or may even have An agreement with Indeed to place more vacancies than other companies.

# The Actuary Job in the Mexico
Since the first generation, the degree in Actuarial Science in Mexico City (1947), such degree has witnessed an outreach around the country. Taking into account that you can now study the career in up to 10 cities of the republic, we could expect the work of the actuary to be exercised throughout the country.

Next, we will analyze how they are distributed the works in Mexico. The following code will prepare the data in such a way that with the help of the package of **Diego Valle** we will be able to graph our data with a map of Mexico using two lines of code.


{% highlight r %}
# We call the package mxmaps to prepare the template to use
require(mxmaps)
data("df_mxstate")

# We create our table of frequencies by state
mapa <- data.frame(table(actuarios$state))

# We adapt the abbreviations of the states and join it with the template
colnames(mapa) <- c('estado', 'puestos')
mapa <- mapa[mapa$estado != '', ]
mapa$estado <- c('BC', 'CHIH',  'CDMX', 'DGO', 'GTO', 'JAL', 'MEX', 'MICH', 'NL', 
                 'PUE', 'QRO', 'QROO', 'SIN', 'SON', 'TAB', 'TAM', 'YUC')

mapa <- merge(x=df_mxstate,y=mapa, by.x="state_abbr", by.y="estado", all.x = TRUE)
mapa$value <- mapa$puestos

# We replace the null values by the value 0
mapa$value[is.na(mapa$value)] <- 0
{% endhighlight %}

The following map shows the relationship between the states that have a university (public or private) and the number of jobs offered in that entity or its surroundings.
<img src="/../figs/actuary-jobs-mx/mapa2-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Of course, Mexico City, the State of Mexico, and Nuevo Leon top the list of states in the country where an actuary can exercise his or her job. Although it is worth noting the states of Jalisco, Yucatan, and Puebla that despite having less time with some university instituting the Actuarial career, are already beginning to stand out among the entities that require this type of professional.

I would like to emphasize the data of the state of Coahuila. In my personal experience, I have never known companies that require actuaries in that entity, nor of acquaintances who have received offers in that part of the country. If you have any explanation on this atypical (atypical in my opinion) data that can clarify the situation, it would not hurt to comment.

# (A litte bit of) Text Mining
I would like to analyze the descriptions of the vacancies offered and be able to glimpse some of the requirements that are most asked of a person who wants to work as an actuary. What words are the most common when applying for an actuary or which skills are related to actuarial positions at management or managerial level.

First of all, we must prepare our texts, put them together and carry out a process to be able to anaize them. With the following code we perform this task.


{% highlight r %}
require(tm)
# We load and prepare the data corpus

# We associate each document with its unique vacancy id
reader <- readTabular(mapping = list(id = "jobkey", content = "snippet"))

# We prepare the corpus and define the language of the text
corpus <- Corpus(DataframeSource(actuarios), 
                 readerControl = list(reader = reader, language = 'es'))
{% endhighlight %}

Once created the corpus with the following characteristics:


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

We clean the text:



After the processing and transformation of our data, the final result is as follows:


{% highlight r %}
c_corpus[[400]]['content']
{% endhighlight %}



{% highlight text %}
## $content
## [1] "importante empresa seguros solicita lic actuaria  objetivo  responsable suscripcion seleccion riesgos ajuste normat"
{% endhighlight %}

# More Frequent Words
To perform all of our analyzes we must construct the so-called matrix of terms of the documents. This matrix lists all the words registered in the texts and their occurrences within it. With the following code we create this matrix.


{% highlight text %}
## <<DocumentTermMatrix (documents: 421, terms: 1175)>>
## Non-/sparse entries: 4916/489759
## Sparsity           : 99%
## Maximal term length: 44
## Weighting          : term frequency (tf)
{% endhighlight %}

Later on, we'll remove less frequent words using the 'removeSparseTerms' function. This part of the analysis is very sensitive, because by eliminating the less frequent words we could be skewing the meaning of these according to the context that includes the document.

A great explanation of word 'sparse' in the term matrix can be seen [here](http://stackoverflow.com/a/33830637).

With the following code we can see the most frequent words in our corpus:


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

Obviously, 'actuaria' turns out to be the most common word because our search was precisely that word.

To understand more about the sparse in documents, let us analyze how often the terms are repeated in our matrix.


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
This means that there are 626 terms that are found only in a text of a vacancy. 201 terms that are found only in two job descriptions and so on. Thus, we can say that among the more terms that only appear sporadically in the texts, the higher the index of sentences of terms.

For the moment, by having too many terms, we will keep all of them and then remove them to compare results. The following graph shows the most frequent words without removing any words.

<img src="/../figs/actuary-jobs-mx/unnamed-chunk-10-1.png" title="center" alt="center" style="display: block; margin: auto;" />

Removing the sparce words we see that more frequent words we obtain.


{% highlight text %}
## <<DocumentTermMatrix (documents: 421, terms: 3)>>
## Non-/sparse entries: 554/709
## Sparsity           : 56%
## Maximal term length: 12
## Weighting          : term frequency (tf)
{% endhighlight %}
<img src="/../figs/actuary-jobs-mx/unnamed-chunk-12-1.png" title="center" alt="center" style="display: block; margin: auto;" />

We can observe that decreasing almost half the sparce rate we eliminate more than 99% of our terms. Therefore, we will continue to use our array of terms with all words.

Finally, let's see which words are more related to others. For example, we will look for the words most associated with the terms 'titulado' (degree obtained), 'gerente' (manager), 'datos' (data), 'seguros' (insurance).


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

For the term 'titulado' (degree obtained) there is no surprise, most words make reference to the final situation of the career ('intern'), to the requirements to work ('indispensable').

The term 'manager' (manager) seemed to me to be more interesting, since it shows terms related to soft skills ('conciliate', 'coaching', 'agree', 'obtain'). This may suggest a development beyond the technician in someone seeking a management position.

If an actuary would like to end up in the insurance business, he could expect a lot of intern positions, as the correlation between the word insurance and 'becario' (intern) is 0.41%. It would be useful to investigate terms such as 'brokerage' or 'reinsurance'.

If we wanted to group the most related terms in all the vacancies we could use a simple analysis of conglomerates with an Euclidean method. The following code shows how to do this:


{% highlight r %}
# For this analysis if we remove the most scarce terms to use a simple model 
# of clusters using a Euclidean measure
dtmss <- removeSparseTerms(dtm, 0.9)

d <- dist(t(dtmss), method="euclidian")   
fit <- hclust(d=d, method="ward.D")   

plot.new()
plot(fit, hang=-1, xlab = "", ylab = "", sub = "")

# Grouped with 4 clusters
groups <- cutree(fit, k=4)   
rect.hclust(fit, k=4, border="red")
{% endhighlight %}

<img src="/../figs/actuary-jobs-mx/unnamed-chunk-14-1.png" title="center" alt="center" style="display: block; margin: auto;" />

We can notice that groups of words are related to the different areas in which an actuary can perform. 'Economics', 'finance' and 'management' are clearly shown in a group, while 'engineering', 'systems' and 'industrial' are grouped together in another conglomerate.

Here we can interpret the result in different ways. Regularly, an actuarial vacancy is not specifically for someone graduating from that bachelor's degree alone. For the characteristics in the formation of an actuary, we can assume that the professional can perform tasks ranging from the Economy, to some engineering.

# How much does an actuary earn in Mexico?

Finally, let us analyze the average salary of an Actuary in Mexico. With the data collected we can calculate the average salary offered in the vacancies. Removing atypical values in our sample we can represent the salaries offered in the following graph:



<img src="/../figs/actuary-jobs-mx/unnamed-chunk-16-1.png" title="center" alt="center" style="display: block; margin: auto;" />

In the graph above we can see that although the average salary offered is only $13,000 MXN per month, 50% of jobs offer a fairly encouraging average salary if we take into account other careers.

We can observe these data in more detail with the following instruction:


{% highlight r %}
summary(actSalarios$avg_salario)
{% endhighlight %}



{% highlight text %}
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##    2000   10000   13000   15700   20000   42500      10
{% endhighlight %}

# Conclusion

The work of the actuary in Mexico has been increasing during the last years in Mexico, every day more companies are benefited with the skills and knowledge that an actuary can offer. Although today, traditional companies (banks, insured and financial) are responsible for hiring actuaries for the most part, we can observe that little by little the actuary gains ground in other parts of the country and every day is more diversified responsibilities of an actuary

A favorable bet is to study a bachelor's degree in Actuarial Science as the average salaries obtained exceed in good measure the national averages of any other career. Although the demand for new tools and knowledge makes Actuarial Science a demanding career, with a wide variety of topics to master, it seems that it is always well recomposed.

**You can also reproduce this exercise by changing the query for your career and discover something unique!**

Have fun!

