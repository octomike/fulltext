

```
  _____     .__  .__   __                   __
_/ ____\_ __|  | |  |_/  |_  ____ ___  ____/  |_
\   __\  |  \  | |  |\   __\/ __ \\  \/  /\   __\
 |  | |  |  /  |_|  |_|  | \  ___/ >    <  |  |
 |__| |____/|____/____/__|  \___  >__/\_ \ |__|
                                \/      \/
```

__Get full text across all da (open access) journals__

[![Build Status](https://api.travis-ci.org/ropensci/fulltext.png)](https://travis-ci.org/ropensci/fulltext)
[![Build status](https://ci.appveyor.com/api/projects/status/y487h3ec5wc2s20m/branch/master?svg=true)](https://ci.appveyor.com/project/sckott/fulltext/branch/master)

rOpenSci has a number of R packages to get either full text, metadata, or both from various publishers. The goal of `fulltext` is to integrate these packages to create a single interface to many data sources.

Data sources in `fulltext`:

* [Crossref](http://www.crossref.org/) - via the `rcrossref` package
* [Public Library of Science (PLOS)](https://www.plos.org/) - via the `rplos` package
* [Biomed Central](http://www.biomedcentral.com/)
* [arXiv preprints](https://arxiv.org) - via the `aRxiv` package
* [bioRxiv preprints](http://biorxiv.org/) - via the `biorxivr` package
* [NCBI via Entrez](http://www.ncbi.nlm.nih.gov/) - via the `rentrez` package
* We __will__ add more, as publishers open up, and as we have time...See the [master list here](https://github.com/ropensci/fulltext/issues/4#issuecomment-52376743)

We'd love your feedback. Let us know what you think at info@ropensci.org, or in [the issue tracker](https://github.com/ropensci/fulltext/issues).

Article full text formats by publisher:

* [https://github.com/ropensci/fulltext/wiki/Full-text-formats](https://github.com/ropensci/fulltext/wiki/Full-text-formats)

## Installation

Install `fulltext`


```r
devtools::install_github("ropensci/fulltext")
```


```r
library('fulltext')
```

## fulltext interface

Most major functions are prefixed with `ft_`.

## Search

`ft_search()` - get metadata on a search query.


```r
ft_search(query = 'ecology', from = 'plos')
#> Query:
#>   [ecology] 
#> Found:
#>   [PLoS: 28471; BMC: 0; Crossref: 0; Entrez: 0; arxiv: 0; biorxiv: 0] 
#> Returned:
#>   [PLoS: 10; BMC: 0; Crossref: 0; Entrez: 0; arxiv: 0; biorxiv: 0]
```

## Get full text

`ft_get()` - get full or partial text of articles.


```r
ft_get('10.1371/journal.pone.0086169', from = 'plos')
#> [Docs] 1 
#> [Source] R session  
#> [IDs] 10.1371/journal.pone.0086169 ...
```

## Cache

__in development__

When dealing with full text data, you can get a lot quickly, and it can take a long time to get. That's where caching comes in. And after you pull down a bunch of data, if you do so within the R session, you don't want to lose that data if the session crashes, etc. When you search you _will be able to_ (i.e., not ready yet) optionally cache the raw JSON/XML/etc. of each request locally - when you do that exact search again we'll just give you the local data - unless of course you want new data, which you can do.


```r
ft_get(ids='10.1371/journal.pone.0086169', from='plos', cache=TRUE)
```

## pdf to text

There are going to be cases in which some results you find in `ft_search()` have full text available in text, xml, or other machine readable formats, but some may be open access, but only in pdf format. We have a series of convenience functions in this package to help extract text from pdfs, both locally and remotely.

Locally, using code adapted from the package `tm`, and various pdf to text parsing backends


```r
pdf1 <- system.file("examples", "example1.pdf", package = "fulltext")
```

Using `ghostscript`


```r
(res_gs <- ft_extract(pdf1, "gs"))
#> <document>/Library/Frameworks/R.framework/Versions/3.2/Resources/library/fulltext/examples/example1.pdf
#>   Title: ecsp-04-08-07 1..16
#>   Producer: Acrobat Distiller 10.1.5 (Windows)
#>   Creation date: 2013-08-16
```

Using `xpdf`


```r
(res_xpdf <- ft_extract(pdf1, "xpdf"))
#> <document>/Library/Frameworks/R.framework/Versions/3.2/Resources/library/fulltext/examples/example1.pdf
#>   Pages: 16
#>   Title: ecsp-04-08-07 1..16
#>   Producer: Acrobat Distiller 10.1.5 (Windows)
#>   Creation date: 2013-08-16
```

Or extract directly into a `tm` Corpus


```r
paths <- sapply(paste0("example", 2:5, ".pdf"), function(x) system.file("examples", x, package = "fulltext"))
(corpus_xpdf <- ft_extract_corpus(paths, "xpdf"))
#> $meta
#>           names                           class
#> 1 content, meta PlainTextDocument, TextDocument
#> 2 content, meta PlainTextDocument, TextDocument
#> 3 content, meta PlainTextDocument, TextDocument
#> 4 content, meta PlainTextDocument, TextDocument
#> 
#> $data
#> <<VCorpus>>
#> Metadata:  corpus specific: 0, document level (indexed): 0
#> Content:  documents: 4
#> 
#> attr(,"class")
#> [1] "xpdf"
```

Extract pdf remotely on the web, using a service called `PDFX`


```r
pdf5 <- system.file("examples", "example5.pdf", package = "fulltext")
pdfx(file = pdf5)
```


```r
#> $meta
#> $meta$job
#> [1] "34b281c10730b9e777de8a29b2dbdcc19f7d025c71afe9d674f3c5311a1f2044"
#>
#> $meta$base_name
#> [1] "5kpp"
#>
#> $meta$doi
#> [1] "10.7554/eLife.03640"
#>
#>
#> $data
#> <?xml version="1.0" encoding="UTF-8"?>
#> <pdfx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://pdfx.cs.man.ac.uk/static/article-schema.xsd">
#>   <meta>
#>     <job>34b281c10730b9e777de8a29b2dbdcc19f7d025c71afe9d674f3c5311a1f2044</job>
#>     <base_name>5kpp</base_name>
#>     <doi>10.7554/eLife.03640</doi>
#>   </meta>
#>    <article>
#>  .....
```

## TODO

* `ft_plot()` - vizualize metadata or full text data

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/fulltext/issues).
* License: MIT
* Get citation information for `fulltext`: `citation(package = 'fulltext')`

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
